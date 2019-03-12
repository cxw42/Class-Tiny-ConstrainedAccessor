#!perl

=head1 NAME

SampleClassTests - run tests on a given class

=cut

package SampleClassTests;

use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Fatal;

=head1 FUNCTIONS

=head2 run

Run the tests.  Call as C<run $instance_of_class_to_test>.

=cut

sub run {
    my $dut = shift;
    die "Need a class" unless ref $dut;

    cmp_ok($dut->medint, '==', 15, 'medint stored OK by ctor');
    cmp_ok($dut->med_with_default, '==', 12, 'med_with_default has default value');
    is($dut->regular, 'hello', 'regular stored OK by ctor');
    is($dut->lazy_default, '1337', 'lazy has default value');

    # The non-constrained accessor accepts everything
    is(
        exception { $dut->regular($_) },
        undef,
        'Regular accepts ' . ($_ // 'undef')
    ) foreach (0, 9, 10, 19, 20, 'some string', undef, \*STDOUT);

    # The constrained accessors accept 10..19
    is(
        exception { $dut->medint($_) },
        undef,
        'medint accepts ' . ($_ // 'undef')
    ) foreach (10..19, "10".."19");

    is(
        exception { $dut->med_with_default($_) },
        undef,
        'med_with_default accepts ' . ($_ // 'undef')
    ) foreach (10..19, "10".."19");

    # The constrained accessors reject numbers outside that range
    like(
        exception { $dut->medint($_) },
        qr/./,
        'medint rejects ' . ($_ // 'undef')
    ) foreach (0..9, "0".."9", 20..29, "20".."29");

    like(
        exception { $dut->med_with_default($_) },
        qr/./,
        'med_with_default rejects ' . ($_ // 'undef')
    ) foreach (0..9, "0".."9", 20..29, "20".."29");

    # The constrained accessors reject random stuff
    like(
        exception { $dut->medint($_) },
        qr/./,
        'medint rejects ' . ($_ // 'undef')
    ) foreach ('some string', undef, \*STDOUT);

    like(
        exception { $dut->med_with_default($_) },
        qr/./,
        'med_with_default rejects ' . ($_ // 'undef')
    ) foreach ('some string', undef, \*STDOUT);
} #run()

1;
