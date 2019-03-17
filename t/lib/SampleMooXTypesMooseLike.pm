#!perl
package SampleMooXTypesMooseLike;
our @ISA;
use Scalar::Util qw(looks_like_number);

use Type::Tiny;

use MooXTypesMooseLikeTypeLib ':all';

use Class::Tiny::ConstrainedAccessor
    medint => MediumInteger,
    med_with_default => MediumInteger,
    lazy_default => MediumInteger,
;

# After using ConstrainedAccessor, we use this
use Class::Tiny qw(medint regular), {
    med_with_default => 12,
    lazy_default => sub { 19 },
};

1;
