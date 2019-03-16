#!perl
use 5.006;
use lib::relative 'lib';
use Kit;
use Tests;

use SampleMouseXTypes;

Tests::test_accessors(
    SampleMouseXTypes->new(medint=>15, regular=>'hello')
);

Tests::test_accessors(
    SampleMouseXTypes->new(medint=>15, regular=>'hello'),
    1
);

Tests::test_construction 'SampleMouseXTypes';

done_testing();
