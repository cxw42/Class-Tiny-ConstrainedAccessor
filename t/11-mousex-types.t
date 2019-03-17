#!perl
use 5.006;
use lib::relative 'lib';
use Kit;
use Tests;

BEGIN {
    plan skip_all => 'Could not load MouseX::Types' unless
        eval { require MouseX::Types; 1; };
}

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
