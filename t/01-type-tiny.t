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

done_testing();
