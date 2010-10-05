# args
# arg1 title
# args authors info
sub header {
	my $title = shift;
	my $author = shift;
	my $flag_printdate = shift;
	$author =~ s/\n/\\\\/g;

	$title = '' unless $title;
	$author = '' unless $author;
	my $date = '\date{}';
	if($flag_printdate) {
		$date = '\date{\today}';
	}

	return '\documentclass{jarticle}
\setlength{\oddsidemargin}{-5mm}
\setlength{\textwidth}{17cm}
\setlength{\topmargin}{-5mm}
\setlength{\textheight}{254mm}
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
\title{' . $title . '}' .
$date .'
\author{' . $author . '}
\maketitle' . "\n";
}

1;

