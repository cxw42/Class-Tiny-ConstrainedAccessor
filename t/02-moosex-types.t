#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Fatal;

use lib::relative 'lib';
use SampleMooseXTypes;
use SampleClassTests;

SampleClassTests::run(
    SampleMooseXTypes->new(medint=>15, regular=>'hello')
);

SampleClassTests::run(
    SampleMooseXTypes->new(medint=>15, regular=>'hello'),
    1
);

done_testing();
