#!perl
use 5.006;
use lib::relative 'lib';
use Kit;
use Tests;

use SampleSpecio;

Tests::test_accessors(
    SampleSpecio->new(medint=>15, regular=>'hello')
);

Tests::test_accessors(
    SampleSpecio->new(medint=>15, regular=>'hello'),
    1
);

Tests::test_construction 'SampleSpecio';

done_testing();
