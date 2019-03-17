#!perl
# Specio type library.

package SpecioTypeLib;
use 5.006;
use strict;
use warnings;

use Scalar::Util qw(looks_like_number);

use parent 'Specio::Exporter';
use Specio::Declare;
use Specio::Library::Builtins;

declare('MediumInteger',
    parent => t('Int'),
    where => sub { $_[0] >= 10 and $_[0] < 20 },
);

# Sanity check
for(t('MediumInteger')) {
    $_->validate_or_die(15);
    die 'Unexpected validation success' if $_->value_is_valid(0);
}

1;
