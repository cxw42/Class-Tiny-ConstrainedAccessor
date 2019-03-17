#!perl
use 5.006;
use lib::relative '.';
use MY::Kit;
use MY::Tests;

use MY::Class::TypeTiny;

Tests::test_accessors(
    MY::Class::TypeTiny->new(medint=>15, regular=>'hello')
);

Tests::test_accessors(
    MY::Class::TypeTiny->new(medint=>15, regular=>'hello'),
    1
);

Tests::test_construction 'MY::Class::TypeTiny';

done_testing();
