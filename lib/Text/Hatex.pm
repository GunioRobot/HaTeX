package Text::Hatex;
use strict;
use warnings;
use Carp;
use base qw(Class::Data::Inheritable);
use vars qw($VERSION);
use Parse::RecDescent;

my ($parser, $syntax);

sub new {
	my $class = shift;

	my $self = {};

	bless $self, $class;
	return $self;
}

__PACKAGE__->mk_classdata('syntax');

$Parse::RecDescent::skip = '';
$syntax = q(
	body       : section(s)
	section    : h3(?) block(s?)

	# Block Elements
	block      : h5
		| h4
		| blockquote
		| dl
		| list
		| super_pre
		| pre
		| table
		| cdata
		| p
	h3         : "\n*" inline(s)
	h4         : "\n**" inline(s)
	h5         : "\n***" inline(s)
	blockquote : "\n>" http(?) ">" block(s) "\n<<" ..."\n"
	dl         : dl_item(s)
	dl_item    : "\n:" inline[term => ':'](s) ':' inline(s)
	list       : list_item[level => $arg{level} || 1](s)
	list_item  : "\n" /[+-]{$arg{level}}/ inline(s) list[level => $arg{level} + 1](?)
	super_pre  : /\n>\|(\w*)\|/o text_line(s) "\n||<" ..."\n"
	text_line  : ...!"\n||<\n" "\n" /[^\n]*/o
	pre        : "\n>|" pre_line(s) "\n|<" ..."\n"
	pre_line   : ...!"\n|<" "\n" inline(s?)
	table      : table_row(s)
	table_row  : "\n|" td(s /\|/) '|'
	td         : /\*?/o inline[term => '\|'](s)
	cdata      : "\n><" /.+?(?=><\n)/so "><" ..."\n"
	p          : ...!p_terminal "\n" inline(s?)
	p_terminal : h3 | "\n<<\n"
	# Inline Elements
	inline     : /[^\n$arg{term}]+/
	http       : /https?:\/\/[A-Za-z0-9~\/._\?\&=\-%#\+:\;,\@\']+(?::title=[^\]]+)?/
);

sub parse {
	my $class = shift;
	my $text = shift or return;
	$text =~ s/\r//g;
	$text = "\n" . $text unless $text =~ /^\n/;
	$text .= "\n" unless $text =~ /\n$/;
	my $node = shift || 'body';
	my $html = $class->parser->$node($text);
	return $html;
}

sub parser {
	my $class = shift;
	unless (defined $parser) {
		$::RD_AUTOACTION = q|my $method = shift @item;| .
		$class . q|->$method({items => \@item});|;
		$parser = Parse::RecDescent->new($syntax);
		if ($class->syntax) {
			$parser->Replace($class->syntax);
		}
	}
	return $parser;
}

sub expand {
	my $class = shift;
	my $array = shift or return;
	ref($array) eq 'ARRAY' or return;
	my $ret = '';
	while (my $item = shift @$array) {
		if (ref($item) eq 'ARRAY') {
			my $c = $class->expand($item);
			$ret .= $c if $c;
		} else {
			$ret .= $item if $item;
		}
	}
	return $ret;
}

# Nodes
# Block Nodes
sub abstract {
	my $class = shift;
	my $items = shift->{items};
	return $class->expand($items);
}

*body = \&abstract;
*block = \&abstract;
*line = \&abstract;

sub section {
	my $class = shift;
	my $items = shift->{items};
	my $body = $class->expand($items) || '';
	$body =~ s/\n\n$/\n/;
	return $body ? $body : '';
}

sub h3 {
	my $class = shift;
	my $items = shift->{items};
	my $title = $class->expand($items->[1]);
	return if $title =~ /^\*/;
	return '\section' . "{$title}\n";
}

sub h4 {
	my $class = shift;
	my $items = shift->{items};
	my $title = $class->expand($items->[1]);
	return if $title =~ /^\*/;
	return '\subsection' . "{$title}\n";
}

sub h5 {
	my $class = shift;
	my $items = shift->{items};
	my $title = $class->expand($items->[1]);
	return '\subsubsection' . "{$title}\n";
}

sub blockquote {
	my $class = shift;
	my $items = shift->{items};
	my $body = $class->expand($items->[3]);
	my $http = $items->[1]->[0];
	my $ret = '';
	if ($http) {
		$ret = "\\begin{quotation}\n";
		#$ret = qq|<blockquote title="$http->{title}" cite="$http->{cite}">\n|;
	} else {
		#$ret = "<blockquote>\n";
		$ret = "\\begin{quotation}\n";
	}
	$ret .= $body;
	if ($http) {
		#$ret .= qq|<cite><a href="$http->{cite}">$http->{title}</a></cite>\n|;
	}
	$ret .= "\\end{quotation}\n";
	return $ret;
}

sub bq_block {
	my $class = shift;
	my $items = shift->{items};
	return $class->expand($items->[0]);
}

sub dl {
	my $class = shift;
	my $items = shift->{items};
	my $list = $class->expand($items->[0]);
	return "<dl>\n$list</dl>\n";
}

sub dl_item {
	my $class = shift;
	my $items = shift->{items};
	my $dt = $class->expand($items->[1]);
	my $dd = $class->expand($items->[3]);
	return "<dt>$dt</dt>\n<dd>$dd</dd>\n";
}

sub dt {
	my $class = shift;
	my $items = shift->{items};
	my $dt = $class->expand($items->[1]);
	return "<dt>$dt</dt>\n";
}

sub list {
	my $class = shift;
	my $items = shift->{items};
	my ($list,$tag);
	for my $li (@{$items->[0]}) {
		$tag ||= $li =~ /^\-/ ? 'itemize' : 'enumerate';
		$li =~ s/^[+-]+//;
		$list .= $li;
	}
	return '\begin{' . $tag . "}\n" . $list . '\end{' . $tag . "}\n";
}

sub list_item {
	my $class = shift;
	my $items = shift->{items};
	my $li = $class->expand($items->[2]);
	my $sl = $class->expand($items->[3]) || '';
	$sl = "\n" . $sl if $sl;
	return $items->[1] . "\\item $li$sl\n";
}

sub super_pre {
	my $class = shift;
	my $items = shift->{items};
	my $filter = $1 || ''; # todo
	my $texts = $class->expand($items->[1]);
	my $lang = 'c';
	{
		$items->[0] =~ /\>\|(.*)\|/;
		$lang = $1;
		$lang = 'C++' if($lang eq 'cpp');
	}
	return "\\begin{lstlisting}[language=$lang]" . "\n$texts" . '\end{lstlisting}' . "\n";
}

sub pre {
	my $class = shift;
	my $items = shift->{items};
	my $lines = $class->expand($items->[1]);
	return '\begin{verbatiam}' . "\n$lines" . '\end{verbatiam}' . "\n";
}

sub pre_line {
	my $class = shift;
	my $items = shift->{items};
	my $inlines = $class->expand($items->[2]);
	return "$inlines\n";
}

sub table {
	my $class = shift;
	my $items = shift->{items};
	my $trs = $class->expand($items->[0]);
	return "<table>\n$trs</table>\n";
}

sub table_row { # we can't use tr!
	my $class = shift;
	my $items = shift->{items};
	my $tds = $class->expand($items->[1]);
	return "<tr>\n$tds</tr>\n";
}

sub td {
	my $class = shift;
	my $items = shift->{items};
	my $tag = $items->[0] ? 'th' : 'td';
	my $inlines = $class->expand($items->[1]);
	return "<$tag>$inlines</$tag>\n";
}

sub cdata {
	my $class = shift;
	my $items = shift->{items};
	my $data = $items->[1];
	return "<$data>\n";
}

sub p {
	my $class = shift;
	my $items = shift->{items};
	my $inlines = $class->expand($items->[2]);
	return $inlines ? "$inlines\n" : "";
}

sub text_line {
	my $class = shift;
	my $text = shift->{items}->[2];
	return "$text\n";
}

# Inline Nodes
sub inline {
	my $class = shift;
	my $items = shift->{items};
	my $item = $items->[0] or return;
	return $item;
}

sub http {
	my $class = shift;
	my $items = shift->{items};
	my $item = $items->[0] or return;
	$item =~ s/:title=([^\]]+)$//;
	my $title = $1 || $item;
	return {
		cite => $item,
		title => $title,
	}
}

1;
