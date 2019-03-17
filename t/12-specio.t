#!perl
use 5.006;
use lib::relative 'lib';
use Kit;
use Tests;

BEGIN {
    plan skip_all => 'Could not load Specio' unless
        eval { require Specio; 1; };
}

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
