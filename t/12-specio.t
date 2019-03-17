#!perl
use 5.006;
use lib::relative '.';
use MY::Kit;
use MY::Tests;

BEGIN {
    plan skip_all => 'Could not load Specio' unless
        eval { require Specio; 1; };
}

use MY::Class::Specio;

Tests::test_accessors(
    MY::Class::Specio->new(medint=>15, regular=>'hello')
);

Tests::test_accessors(
    MY::Class::Specio->new(medint=>15, regular=>'hello'),
    1
);

Tests::test_construction 'MY::Class::Specio';

done_testing();
