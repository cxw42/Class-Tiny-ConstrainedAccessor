#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Class::Tiny::ConstrainedAccessor' ) || print "Bail out!\n";
}

diag( "Testing Class::Tiny::ConstrainedAccessor $Class::Tiny::ConstrainedAccessor::VERSION, Perl $], $^X" );
