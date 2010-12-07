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
my $flag_printdate = $q->param('flag_printdate');
my $doccls_opt = $q->param('flag_titlepage') ? '[titlepage]' : '';

&sanitize( \$title, \$author, \$body);

my $name = int(rand(10000000000));
my $tex_log = &make($name, \$body);

print "<pre>" . $tex_log . "</pre>" . "
<p>
\$flag_printdate = '$flag_printdate'<br>
<a href=\"tmp/$name.tex\">$name.tex</a><br>
<a href=\"tmp/$name.pdf\">$name.pdf</a><br>
</p>
";

print $q->end_html;
exit;

#############################################################

#
# convert Hatena-syntax to tex, and create pdf
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
	print FILE &header($doccls_opt);
	print FILE &title($title, $author, $flag_printdate);
	print FILE $tex . "\n";
	print FILE $refference;
	print FILE &hooter();
	close FILE;

	`nkf -e $name.tex>${name}euc.tex; rm $name.tex; mv ${name}euc.tex $name.tex`;
	my $tex_output = `make TARGET=$name`;
	chdir '..';

	return $tex_output;
}

#
# Sanitizing input data
#
# sub routines
# args: the list of reffernces
sub sanitize {
	foreach (@_) {
		$$_ = '' unless $$_;
		Text::Hatex->encode( $_);
	}
}

#
# insert reference table
#
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

