#!perl
# Specio type library.

package SpecioTypeLib;
use Scalar::Util qw(looks_like_number);

use parent 'Specio::Exporter';
use Specio::Declare;
use Specio::Library::Builtins;

declare('MediumInteger',
    parent => t('Int'),
    where => sub { $_ >= 10 and $_ < 20 },
);

1;
