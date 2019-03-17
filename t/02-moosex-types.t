#!perl
use 5.006;
use lib::relative '.';
use MY::Kit;
use MY::Tests;

use MY::Class::MooseXTypes;

Tests::test_accessors(
    MY::Class::MooseXTypes->new(medint=>15, regular=>'hello')
);

Tests::test_accessors(
    MY::Class::MooseXTypes->new(medint=>15, regular=>'hello'),
    1
);

Tests::test_construction 'MY::Class::MooseXTypes';

done_testing();
