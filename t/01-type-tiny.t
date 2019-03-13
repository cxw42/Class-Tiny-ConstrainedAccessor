#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Fatal;

use lib::relative 'lib';
use SampleTypeTiny;
use Tests;

Tests::test_accessors(
    SampleTypeTiny->new(medint=>15, regular=>'hello')
);

Tests::test_accessors(
    SampleTypeTiny->new(medint=>15, regular=>'hello'),
    1
);

Tests::test_construction 'SampleTypeTiny';

done_testing();
