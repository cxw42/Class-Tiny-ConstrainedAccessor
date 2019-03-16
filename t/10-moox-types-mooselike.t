#!perl
use 5.006;
use lib::relative 'lib';
use Kit;
use Tests;

my $could_load;
eval { require MooX::Types::MooseLike; $could_load = 1; };
plan skip_all => 'Could not load MooX::Types::MooseLike' unless $could_load;

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
