#!perl
use 5.006;
use strict;
use warnings;
use lib::relative '.';
use MY::Kit;
use MY::Tests;

BEGIN {
    plan skip_all => 'Could not load Specio' unless
        eval { require Type::Nano; 1; };
}

use MY::Class::TypeNano;

MY::Tests::test_accessors(
    MY::Class::TypeNano->new(medint=>15, regular=>'hello')
);

MY::Tests::test_accessors(
    MY::Class::TypeNano->new(medint=>15, regular=>'hello'),
    1
);

MY::Tests::test_construction 'MY::Class::TypeNano';

done_testing();
