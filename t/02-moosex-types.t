#!perl
use 5.006;
use lib::relative 'lib';
use Kit;
use Tests;

use SampleMooseXTypes;

Tests::test_accessors(
    SampleMooseXTypes->new(medint=>15, regular=>'hello')
);

Tests::test_accessors(
    SampleMooseXTypes->new(medint=>15, regular=>'hello'),
    1
);

Tests::test_construction 'SampleMooseXTypes';

done_testing();
