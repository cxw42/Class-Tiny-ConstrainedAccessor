#!perl
# Mouse type library.  Mouse requires type-library packages to inherit from
# within Mouse, so we put it in a separate package from SampleMouseXTypes.

package MouseXTypeLib;
use Scalar::Util qw(looks_like_number);

use MouseX::Types -declare => [
    qw(MediumInteger),
];

use MouseX::Types::Mouse qw(Int);

BEGIN {
    subtype MediumInteger,
        as Int,
        where { $_ >= 10 and $_ < 20 },
        message { ($_ // 'undef') . ' is not an integer on [10,19]' };

    # Sanity check
    my $av = eval { MediumInteger->can('assert_valid') };
    die "cannot assert_valid: $@" unless $av;
}

1;
