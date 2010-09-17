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

$body =~ s/\\/{\\textbackslash}/g;
$author =~ s/\\/{\\textbackslash}/g;
$body =~ s/\n/\\\\/g;
$author =~ s/\n/\\\\/g;

my $header =
'\documentclass{jarticle}
\setlength{\oddsidemargin}{-5mm}
\setlength{\textwidth}{17cm}
\setlength{\topmargin}{-5mm}
\setlength{\textheight}{254mm}
\pagestyle{empty}

\usepackage{here}
\usepackage{txfonts}
\usepackage{listings, jlisting}
\renewcommand{\lstlistingname}{リスト}
\lstset{language=c,
	basicstyle=\ttfamily\scriptsize,
	commentstyle=\textit,
	classoffset=1,
	keywordstyle=\bfseries,
	frame=single,
	showstringspaces=false,
	numberstyle=\tiny,
}

\begin{document}
\title{' . $title . '}
\date{\today}
\author{' . $author . '}
\maketitle' . "\n";
my $hooter = '\end{document}' . "\n";

# thebibliography environment
my $refference = '';
if($q->param('refference') ne '') {
	$refference = '\begin{thebibliography}{99}' . "\n";
	foreach ($q->param('refference')) {
		$refference .= "\\bibitem $_";
	}
	$refference .= '\end{thebibliography}' . "\n";
}

my $name = int(rand(1000000000000000));

chdir 'tmp';
`make clean TARGET=$name`;

my $tex =  Text::Hatex->parse($body) . "\n";
open FILE, ">$name.tex";
print FILE $header . $tex . $refference . $hooter;
close FILE;

`nkf -e $name.tex>${name}euc.tex; rm $name.tex; mv ${name}euc.tex $name.tex`;
print '<pre>' . `make TARGET=$name` . '</pre>';
#system "make TARGET=$name&";
chdir '..';

print "<p>
<a href=\"tmp/$name.tex\">$name.tex</a><br>
<a href=\"tmp/$name.pdf\">$name.pdf</a><br>
</p>
";

print $q->end_html;

