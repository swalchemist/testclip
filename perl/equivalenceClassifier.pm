#!/usr/bin/perl

use strict;
use warnings;

package CounterString;

sub new 
{
	my ($class, $pip) = @_;
	$pip = "*" if ! defined $pip;
	my $self = 
	{
		pip => $pip
	};
	return bless $self, $class;
}

sub text
{
	my ($self, $pos) = @_;

	my $target = $pos;
	my $text = "";
	
	{
		if (length($text)+length($pos)+1 > $target)
		{
			$text .= $self->{pip} x ($target - length($text));
			last;
		}
		$text .= $self->{pip}.reverse($pos);
		$pos -= length($pos)+1;
		redo;
	}
	$text = scalar(reverse($text));
	return $text;
}

1;
