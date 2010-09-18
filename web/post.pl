#!/usr/bin/perl
use lib qw( ../lib );
use warnings;
use strict;
use CGI;
use Text::Hatex;
require 'header.pl';
require 'hooter.pl';

my $q = new CGI;
print $q->header( -charset => "utf-8");
print $q->start_html( -title => "HaTeX", -BGCOLOR => '#ffffff');

my $title = $q->param('title');
my $author = $q->param('author');
my $body = $q->param('body');
my $refference = &mkreftable( $q->param('refference'));

&sanitize( \$title, \$author, \$body);

my $name = int(rand(10000000000));
my $tex_log = &make($name, \$body);

print "<pre>" . $tex_log . "</pre>" . "
<p>
<a href=\"tmp/$name.tex\">$name.tex</a><br>
<a href=\"tmp/$name.pdf\">$name.pdf</a><br>
</p>
";

print $q->end_html;
exit;

#
# arg1: output file name
# arg2: refference to string of hatena-syntax
sub make {
	my $name = shift;
	my $body = shift;

	chdir 'tmp';
	`make clean TARGET=$name`;

	my $tex = Text::Hatex->parse($$body);
	$tex = '' unless $tex;

	open FILE, ">$name.tex";
	print FILE &header($title, $author) . $tex . "\n" . $refference . &hooter();
	close FILE;

	`nkf -e $name.tex>${name}euc.tex; rm $name.tex; mv ${name}euc.tex $name.tex`;
	my $tex_output = `make TARGET=$name`;
	chdir '..';

	return $tex_output;
}



# sub routines
# args: the list of reffernces
sub sanitize {
	foreach (@_) {
		$$_ = '' unless $$_;
		$$_ =~ s/\\/{\\textbackslash}/g;
	}
}

sub mkreftable {
	my $input_data = shift;
	return '' unless $input_data;
	my $reftable = '';
	if($input_data ne '') {
		$reftable = '\begin{thebibliography}{99}' . "\n";
		foreach ($input_data) {
			&sanitize( \$_);
			$reftable .= "\\bibitem $_";
		}
		$reftable .= '\end{thebibliography}' . "\n";
	}
	return $reftable;
}

