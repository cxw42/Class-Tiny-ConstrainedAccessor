#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Fatal;

use lib::relative 'lib';
use SampleMooseXTypes;
use Tests;

Tests::test_accessors(
    SampleMooseXTypes->new(medint=>15, regular=>'hello')
);

Tests::test_accessors(
    SampleMooseXTypes->new(medint=>15, regular=>'hello'),
    1
);

Tests::test_construction 'SampleMooseXTypes';

done_testing();
