#!/usr/bin/perl

use strict;
use warnings;

package TestClip::EquivalenceClassifier;

sub new 
{
	my ($class) = @_;
	my $self = { };
	bless $self, $class;
	$self->reset;
	return $self;
}

sub reset {
	my ($self) = @_;
	$self->{bisectedbefore} = 0;
	$self->{upper} = 0;
	$self->{lower} = 0;
}

sub bisectUp
{
	my ($self) = @_;
	#(print "Before using 'U' you must give two counterstring commands.\n" and redo TOP) if (!$self->goodbi(\@cs));
	#if ($self->{bisectedbefore})
	#{
		#$self->{lower} += int(($self->{upper}-$self->{lower})/2);
		#(print "The lower bound equals the upper bound... No bisection necessary.\n" and redo TOP) if ($self->{upper} == $self->{lower});
		#print "Creating counterstring of length ",$self->{upper}-int(($self->{upper}-$self->{lower})/2),".\n";
		#$self->make_cs($self->{upper}-int(($self->{upper}-$self->{lower})/2), $pip);
		#redo TOP;
	#}
	#else
	#{
		#$self->{bisectedbefore}++; 
		#($self->{lower}, $self->{upper}) = sort {$a <=> $b} @cs[-1, -2];
		#(print "The lower bound equals the upper bound... No bisection necessary.\n" and redo TOP) if ($self->{upper} == $self->{lower});
		#print "Creating counterstring of length ",$self->{upper}-int(($self->{upper}-$self->{lower})/2),".\n";
		#$self->make_cs($self->{upper}-int(($self->{upper}-$self->{lower})/2), $pip);
		#redo TOP;
	#}
}

sub bisectDown
{
	my ($self) = @_;
	#(print "Before using 'D' you must give two counterstring commands.\n" and redo TOP) if (!$self->goodbi(\@cs));
	#if ($self->{bisectedbefore})
	#{
		#$self->{upper} -= int(($self->{upper}-$self->{lower})/2);
		#(print "The lower bound equals the upper bound... No bisection necessary.\n" and redo TOP) if ($self->{upper} == $self->{lower});
		#print "Creating counterstring of length ",$self->{lower}+int(($self->{upper}-$self->{lower})/2),".\n";
		#$self->make_cs($self->{lower}+int(($self->{upper}-$self->{lower})/2), $pip);
		#redo TOP;
	#}
	#else
	#{
		#$self->{bisectedbefore}++; 
		#($self->{lower}, $self->{upper}) = sort {$a <=> $b} @cs[-1, -2];
		#(print "The lower bound equals the upper bound... No bisection necessary.\n" and redo TOP) if ($self->{upper} == $self->{lower});
		#print "Creating counterstring of length ",$self->{lower}+int(($self->{upper}-$self->{lower})/2),".\n";
		#$self->make_cs($self->{lower}+int(($self->{upper}-$self->{lower})/2), $pip);
		#redo TOP;
	#}

}

1;
