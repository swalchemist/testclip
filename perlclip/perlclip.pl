#!/usr/bin/perl

use strict;
use warnings;

my $clip;
if ($^O eq "MSWin32" or $^O eq "cygwin") {
	# Windows-specific
	eval "use Win32::Clipboard" and die $@; 
	$clip=Win32::Clipboard(); 
}

my $prompt = <<PROMPT;
Perlclip for Testers, v1.3
by James Bach and Danny Faught
This program is released under the GPL 2.0 license.
PROMPT
print $prompt;
print "Type \"help\" for instructions.\n";

my $bisectedbefore = 0;
my $upper = 0;
my $lower = 0;
my $pip = "";
local $userCode::allchars = "";
my @cs = ();
for (my $t=1;$t<256;$t++) {$userCode::allchars .= chr($t)}

TOP:
{
	print "\nPattern:\n";
	my $text = "";
	
	my $pattern = <STDIN>;
	last if (! defined $pattern);
	chomp $pattern;
	
	if ($pattern =~ /\s*help/) 
	{
		help("\n$prompt\n");
		redo TOP;
	}
	elsif ($pattern =~ /counterstring\s+?(\d+)/i)
	{
		my $pos = $1;
		if ($bisectedbefore) {@cs = (); $bisectedbefore = 0 }
		push @cs, $1;
		$pip = "*";
		if ($pattern =~ /counterstring\s+\d+?\s+(.)/) {$pip = $1}
		make_cs($pos, $pip);
		redo TOP;
	}
	elsif ($pattern =~ /textfile (\S+)/i)
	{
		if (open (FILE,$1))
		{
			foreach (<FILE>) {$text .= $_}
		}
		else
		{
			print "Can't open file $1\n";
			redo;
		}
	}
	elsif ($pattern =~ /^u$/i)
	{
		(print "Before using 'U' you must give two counterstring commands.\n" and redo TOP) if (!goodbi(\@cs));
		if ($bisectedbefore)
		{
			$lower += int(($upper-$lower)/2);
			(print "The lower bound equals the upper bound... No bisection necessary.\n" and redo TOP) if ($upper == $lower);
			print "Creating counterstring of length ",$upper-int(($upper-$lower)/2),".\n";
			make_cs($upper-int(($upper-$lower)/2), $pip);
			redo TOP;
		}
		else
		{
			$bisectedbefore++; 
			($lower, $upper) = sort {$a <=> $b} @cs[-1, -2];
			(print "The lower bound equals the upper bound... No bisection necessary.\n" and redo TOP) if ($upper == $lower);
			print "Creating counterstring of length ",$upper-int(($upper-$lower)/2),".\n";
			make_cs($upper-int(($upper-$lower)/2), $pip);
			redo TOP;
		}
	}
	elsif ($pattern =~ /^d$/i)
	{
		(print "Before using 'D' you must give two counterstring commands.\n" and redo TOP) if (!goodbi(\@cs));
		if ($bisectedbefore)
		{
			$upper -= int(($upper-$lower)/2);
			(print "The lower bound equals the upper bound... No bisection necessary.\n" and redo TOP) if ($upper == $lower);
			print "Creating counterstring of length ",$lower+int(($upper-$lower)/2),".\n";
			make_cs($lower+int(($upper-$lower)/2), $pip);
			redo TOP;
		}
		else
		{
			$bisectedbefore++; 
			($lower, $upper) = sort {$a <=> $b} @cs[-1, -2];
			(print "The lower bound equals the upper bound... No bisection necessary.\n" and redo TOP) if ($upper == $lower);
			print "Creating counterstring of length ",$lower+int(($upper-$lower)/2),".\n";
			make_cs($lower+int(($upper-$lower)/2), $pip);
			redo TOP;
		}
	}
	else
	{
		for(1..1){ 
		# useless for loop is just to initialize $_ so that a certain untrappable error won't occur in typed-in code.
		# - would a "local $_" accomplish the same thing?

		{
		  # Anonymous block where we can allow sloppy code in
		  # the eval.  Also isolate user code to a package.
			package userCode;
		  no strict;
		  no warnings;
		  $text = eval($pattern);
		}
                if ($@)
                {
			print "$@\n";
			print "Can't interpret that pattern. Try a different one.\n";
			redo TOP;
                }
		else
		{
			if (!$text) {$text = $pattern}
		}
		
		}
	}
	&clipSet($text);
	print "*** Ready to Paste!\n";
	$text = "";
	redo;
}

sub make_cs
{
	my ($pos, $pip) = @_;

	my $target = $pos;
	my $text = "";
	
	{
		if (length($text)+length($pos)+1 > $target)
		{
			$text .= $pip x ($target - length($text));
			last;
		}
		$text .= $pip.reverse($pos);
		$pos -= length($pos)+1;
		redo;
	}
	$text = scalar(reverse($text));
	&clipSet($text);
	print "*** Ready to Paste!\n";
	return 1;
}

sub goodbi
{
	my $csref = shift @_;
	(@$csref < 2) ? 0 : 1;
}

sub clipSet
{
	my $text = shift @_;
	if ($^O eq "darwin") {
		# MacOS X
        	open (PIPE, "|pbcopy") or die "pipe open: $!";
        	print PIPE $text;
        	close PIPE or die "pipe close: $!";
	}
	else {
		# Windows
		$clip->Set($text);
	}
	return 1;
}

sub help 
{
	my $foreword = shift @_;
	print $foreword if defined $foreword;
	print <<EOF;
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
}
