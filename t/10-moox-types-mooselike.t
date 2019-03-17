#!perl
use 5.006;
use lib::relative 'lib';
use Kit;
use Tests;

BEGIN {
    plan skip_all => 'Could not load MooX::Types::MooseLike' unless
        eval { require MooX::Types::MooseLike; 1; };
}

use SampleMooXTypesMooseLike;

Tests::test_accessors(
    SampleMooXTypesMooseLike->new(medint=>15, regular=>'hello')
);

Tests::test_accessors(
    SampleMooXTypesMooseLike->new(medint=>15, regular=>'hello'),
    1
);

Tests::test_construction 'SampleMooXTypesMooseLike';

done_testing();
