#!/usr/bin/perl
use warnings;
use strict;
use CGI;
use cgidec;

my $q = new CGI;
my %query = &cgidec::getline($ENV{'QUERY_STRING'});
print $q->header( -charset => "utf-8");
print $q->start_html( -title => "HaTeX", -BGCOLOR => '#ffffff');

{
	print $query{"title"};
	print $query{"authro"};
	print $query{"body"};
	print $query{"refference"};
}

print $q->end_html;

