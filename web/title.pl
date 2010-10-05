sub title {
	my $subject = shift;
	my $author = shift;
	my $flag_printdate = shift;

	if(!$subject && !$author && !$flag_printdate) {
		return '';
	}

	$author =~ s/\n/\\\\/g;
	$subject = '' unless $subject;
	$author = '' unless $author;
	my $date = '\date{}';
	if($flag_printdate) {
		$date = '\date{\today}';
	}

	return
'\title{' . $subject . '}' .
$date .'
\author{' . $author . '}
\maketitle
';

}

1;
