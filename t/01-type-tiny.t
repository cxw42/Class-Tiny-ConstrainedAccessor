#!perl
use 5.006;
use lib::relative 'lib';
use Kit;
use Tests;

use SampleTypeTiny;

Tests::test_accessors(
    SampleTypeTiny->new(medint=>15, regular=>'hello')
);

Tests::test_accessors(
    SampleTypeTiny->new(medint=>15, regular=>'hello'),
    1
);

Tests::test_construction 'SampleTypeTiny';

done_testing();
