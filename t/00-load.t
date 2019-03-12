#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Class::Tiny::ConstrainedAccessor' ) || print "Bail out!\n";
}

diag( "Testing Class::Tiny::ConstrainedAccessor $Class::Tiny::ConstrainedAccessor::VERSION, Perl $], $^X" );

# TODO replace the use_ok lines with the setup used in
# https://metacpan.org/source/TOBYINK/Type-Tiny-1.004004/t/01-compile.t
