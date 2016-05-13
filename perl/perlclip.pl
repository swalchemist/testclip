#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use commandProcessor;
use counterString;

my $clip;
if ($^O eq "MSWin32" or $^O eq "cygwin") {
	# Windows-specific
	eval "use Win32::Clipboard" and die $@; 
	$clip=Win32::Clipboard(); 
}

my $commandProcessor = TestClip::CommandProcessor->new;
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
		print $commandProcessor->helpText("\n$prompt\n");
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
	my $text = CounterString->new($pip)->text($pos);
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

