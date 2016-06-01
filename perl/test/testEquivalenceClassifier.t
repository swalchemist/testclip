package TestEquivalenceClassifier;

use strict;
use warnings FATAL => 'all';

use base qw(Test::Class);
use Test::More;
use lib "..";
use equivalenceClassifier;

sub test_reset : Tests {
    my $eq = TestClip::EquivalenceClassifier->new;
	$eq->{bisectedbefore} = 1;
	$eq->{upper} = 1;
	$eq->{lower} = 1;
	$eq->reset;
	is (0, $eq->{bisectedbefore}, "reset bisectedbefore");
	is (0, $eq->{upper}, "reset upper");
	is (0, $eq->{lower}, "reset lower");
}

Test::Class->runtests;
