package TestCommandProcessor;

use strict;
use warnings FATAL => 'all';

use base qw(Test::Class);
use Test::More;
use lib "..";
use commandProcessor;

sub test_help_bare : Tests {
	my $cp = TestClip::CommandProcessor->new();
	ok(length($cp->helpText()) > 0);
}

sub test_help_with_foreword : Tests {
	my $cp = TestClip::CommandProcessor->new();
	like($cp->helpText("FOREWORD HERE\n"), qr/FOREWORD HERE/);
}

Test::Class->runtests;
