#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use counterString;

package TestClip::CommandProcessor;

sub new 
{
	my ($class) = @_;
	my $self = {};
	return bless $self, $class;
}

sub helpText
{
	my ($self, $foreword) = @_;
	my $help;
	$help = $foreword if defined $foreword;
	$help .= <<EOF;
This program puts text into the clipboard based on a pattern you specify. 
Enter Perl code, 'allchars', 'file {name}', 'u', 'd', or 
'counterstring {num} [{char}]' to produce text.

Perl code examples:
	"james"		       # "james" (without quotes)
	"james" x 10           # "jamesjamesjamesjames..." (without quotes)
	"a" x (2 ** 16)        # string of "a" that is 65536 characters long
	chr(13) x 10           # ten carriage returns
	join "\r\n", (1..100)  # the number 1 through 100, each on its own line

\$allchars:
	Produces a string that includes all character codes from 1 to 255 
	(0 not included).

counterstring {num} [{char}]:
	Produces a special string of length {num} that counts its own 
	characters.
	
	"counterstring 10" would produce "*3*5*7*10*" which is a ten 
	character long string, such that each asterisk is at a position 
	in the string equal to the number that precedes it. This is 
	useful for pasting into fields that cut off text, so that you can
	tell how many characters were actually pasted.
	
	You can specify a separator other than asterisk. 
	"counterstring 15 A" would produce "A3A5A7A9A12A15A"

textfile {name}:
	loads the contents of a specified text file into the clipboard.

u: 
	("bisect up") if given after  two consecutive counterstring 
	commands it will return a counterstring that is half-way between 
	the two counterstring lengths. If given after another bisect 
	command, it will bisect the range between the most recent 
	bisection and the upper limit of the range of the earlier 
	bisection.
	
d:
	("bisect down") if given after  two consecutive counterstring 
	commands it will return a counterstring that is half-way between 
	the two counterstring lengths. If given after another bisect 
	command, it will bisect the range between the most recent 
	bisection and the lower limit of the range of the earlier 
	bisection.

help:
	Print these instructions.

EOF

	return $help;
}

1;
