#!/usr/bin/perl
use warnings;
use strict;
use lib qw( ../lib );
use Text::Hatex;

my $header =
'\documentclass{jarticle}

\setlength{\oddsidemargin}{-5mm}
\setlength{\textwidth}{17cm}
\setlength{\topmargin}{-5mm}
\setlength{\textheight}{254mm}
\pagestyle{empty}

\begin{document}
\title{Ttile}
\date{\today}
\author{Authro Name\\
学籍番号とか\\
\texttt{hogehoge@hogehoge.tsukuba.ac.jp}}
\maketitle
';

my $hooter = '\end{document}
';


my $buf = '';
foreach (<>) {
	$buf .= $_;
}
print $header . Text::Hatex->parse( $buf) . $hooter;

