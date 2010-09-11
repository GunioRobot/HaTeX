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
\maketitle
';
my $hooter = '\end{document}';

#未実装
#print $q->param('refference');

my $name = 'fuga';

chdir 'tmp';
`make clean TARGET=$name`;

my $tex =  Text::Hatex->parse($body);
open FILE, ">fuga.tex";
print FILE $header . $tex . "\n" . $hooter . "\n";
close FILE;

`nkf -e $name.tex>${name}euc.tex; rm $name.tex; mv ${name}euc.tex $name.tex`;
`make TARGET=$name`;
chdir '..';

print $q->end_html;

