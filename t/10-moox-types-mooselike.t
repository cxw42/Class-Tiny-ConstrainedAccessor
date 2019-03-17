#!perl
use 5.006;
use lib::relative '.';
use MY::Kit;
use MY::Tests;

BEGIN {
    plan skip_all => 'Could not load MooX::Types::MooseLike' unless
        eval { require MooX::Types::MooseLike; 1; };
}

use MY::Class::MooXTypesMooseLike;

Tests::test_accessors(
    MY::Class::MooXTypesMooseLike->new(medint=>15, regular=>'hello')
);

Tests::test_accessors(
    MY::Class::MooXTypesMooseLike->new(medint=>15, regular=>'hello'),
    1
);

Tests::test_construction 'MY::Class::MooXTypesMooseLike';

done_testing();
