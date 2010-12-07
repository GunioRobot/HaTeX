# args
# arg1 subject
# args authors info
require 'title.pl';

sub header {
	my $doccls_options = shift;
	return '\documentclass' . $doccls_options .'{jarticle}
\setlength{\oddsidemargin}{-5mm}
\setlength{\textwidth}{17cm}
\setlength{\topmargin}{-10mm}
\setlength{\textheight}{250mm}
\pagestyle{empty}

\usepackage{here}
\usepackage{txfonts}
\usepackage{listings, jlisting}
%\renewcommand{\lstlistingname}{リスト}
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
';
}

1;

