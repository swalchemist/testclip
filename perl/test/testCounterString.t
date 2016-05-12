package TestCounterString;

use strict;
use warnings FATAL => 'all';

use base qw(Test::Class);
use Test::More;
use lib "..";
use counterString;

sub test_length_0 : Tests {
    is(CounterString->new()->text(0), "", "length 0");
}

sub test_length_1 : Tests {
    is(CounterString->new()->text(1), "*", "length 1");
}

sub test_length_2 : Tests {
    is(CounterString->new()->text(2), "2*", "length 2");
}

sub test_length_3 : Tests {
    is(CounterString->new()->text(3), "*3*", "length 3");
}

sub test_pip_simple : Tests {
    is(CounterString->new("-")->text(3), "-3-", "non-default single-character pip");
}

sub test_pip_long : Tests {
TODO: {
	local $TODO = "Bug - multi-character pip is reversed";
    is(CounterString->new("{}")->text(3), "3{}", "two-character pip");
}
}

sub test_pip_too_long : Tests {
TODO: {
	local $TODO = "Bug - long pip is not properly truncated";
    is(CounterString->new("{}")->text(1), "}", "pip longer than counterstring");
}
}

sub test_double_pip_both_sides : Tests {
TODO: {
	local $TODO = "Bug - counterstring wrong length, pip reversed";
    is(CounterString->new("{}")->text(5), "{}5{}", "double pip both sides");
}
}

sub test_1000 : Tests {
	my $text = CounterString->new()->text(1000);
	like($text, qr/^[*0-9]{999}\*$/, "1000-character counterstring contains only digits and pips");
	unlike($text, qr/\*\*/, "1000-character counterstring contains no double pips");
}

Test::Class->runtests;
