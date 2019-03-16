#!perl
package SampleMooXTypesMooseLike;
our @ISA;
use Scalar::Util qw(looks_like_number);

use Type::Tiny;

use MooX::Types::MooseLike::Base qw(Int);

BEGIN {
    my $type_definitions = [
        {
            name => 'MediumInteger',
            subtype_of => 'Int',
            from => 'MooX::Types::MooseLike::Base',
            test => sub { $_ >= 10 and $_ < 20 },
            message => sub {
                return exception_message($_[0], 'an integer on [10,19]')
            },
        },
    ];

    MooX::Types::MooseLike::register_types($type_definitions, __PACKAGE__);

    # Sanity check
    my $av = eval { MediumInteger(15) };
    die "Unexpected sanity-check failure: $@" unless $av;
}

use Class::Tiny::ConstrainedAccessor
    medint => MediumInteger,
    med_with_default => MediumInteger,
    lazy_default => MediumInteger,
;

BEGIN { undef @ISA; }   # So we're not a Moose class
    # See https://metacpan.org/release/Class-Tiny/source/lib/Class/Tiny.pm#L27

# After using ConstrainedAccessor, we use this
use Class::Tiny qw(medint regular), {
    med_with_default => 12,
    lazy_default => sub { 19 },
};

1;
