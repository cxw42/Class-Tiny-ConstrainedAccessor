#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Fatal;

use lib::relative 'lib';
use SampleTypeTiny;
use SampleClassTests;

SampleClassTests::run(
    SampleTypeTiny->new(medint=>15, regular=>'hello')
);

SampleClassTests::run(
    SampleTypeTiny->new(medint=>15, regular=>'hello'),
    1
);

done_testing();
