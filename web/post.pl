#!/usr/bin/perl
use lib qw( ../lib );
use warnings;
use strict;
use CGI;
use Text::Hatex;
my $q = new CGI;

print $q->header( -charset => "utf-8");
print $q->start_html( -title => "HaTeX", -BGCOLOR => '#ffffff');

print $q->param('refference');

my $title = $q->param('title');
my $author = $q->param('author');
my $body = $q->param('body');

my $header =
'\documentclass{jarticle}
\setlength{\oddsidemargin}{-5mm}
\setlength{\textwidth}{17cm}
\setlength{\topmargin}{-5mm}
\setlength{\textheight}{254mm}
\pagestyle{empty}
\begin{document}
\title{' . $title . '}
\date{\today}
\author{' . $author . '}
\maketitle
';
my $hooter = '\end{document}';

#未実装
#print $q->param('refference');

my $tex =  Text::Hatex->parse($body);
print $tex;


open FILE, ">tmp/fuga.tex";
print FILE $header . $tex . "\n" . $hooter . "\n";
close FILE;

chdir 'tmp';
{
	my @gomi = qq(fuga.tex fuga.log fuga.aux fuga.dvi fuga.pdf);
	foreach (@gomi) {
		unlink if -e;
	}
}
print `nkf -e fuga.tex>fugaeuc.tex`;
print `platex --kanji=euc fugaeuc.tex`;
print `mv fugaeuc.dvi fuga.dvi`;
print `dvipdfm fuga.dvi`;
chdir '..';

print $q->end_html;

