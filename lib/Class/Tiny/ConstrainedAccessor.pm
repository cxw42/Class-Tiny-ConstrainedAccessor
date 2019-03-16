package Class::Tiny::ConstrainedAccessor;

use 5.006;
use strict;
use warnings;
use Class::Tiny;

#use Data::Dumper;   #DEBUG

our $VERSION = '0.000002'; # TRIAL

# Docs {{{1

=head1 NAME

Class::Tiny::ConstrainedAccessor - Generate Class::Tiny accessors that apply type constraints

=head1 SYNOPSIS

L<Class::Tiny> uses custom accessors if they are defined before the
C<use Class::Tiny> statement in a package.  This module creates custom
accessors that behave as standard C<Class::Tiny> accessors except that
they apply type constraints (C<isa> relationships).  Type constraints
can come from TODO (e.g., L<Type::Tiny>).

Example of a class using this package:

    package SampleClass;
    use Scalar::Util qw(looks_like_number);

    use Type::Tiny;

    my $MediumInteger = Type::Tiny->new(
        name => 'MediumInteger',
        constraint => sub { looks_like_number($_) and $_ >= 10 and $_ < 20 }
    );

    use Class::Tiny::ConstrainedAccessor {
        medint => $MediumInteger,           # create accessor sub medint()
        med_with_default => $MediumInteger,
    };

    # After using ConstrainedAccessor
    use Class::Tiny qw(medint regular), {
        med_with_default => 12,
    };

=head1 SUBROUTINES

=head2 import

Creates the accessors you have requested.

=cut

# }}}1

sub import {
    my $target = caller;
    my $package = shift;
    die "Need 'name => \$Constraint' pairs" if @_%2;

    my %constraints = @_;

    foreach my $k (keys(%constraints)) {
        my $constraint = $constraints{$k};

        #print Dumper($constraint);
        # Make sure it's a type of constraint we can use
        die "Cannot use undefined or scalar constraint $k in package $target"
            unless(ref $constraint);

        # Type::Tiny and Moose::Meta::TypeConstraint
        my $av = eval { $constraint->can('assert_valid') };
        die "I don't know how to use the constraint object for $k" unless $av;

        # The accessor --- modified from the Class::Tiny docs based on
        # the source for C::T::__gen_accessor() and C::T::__gen_sub_body().
        #   Future TODO? use an accessor that is specific to the type of
        #   constraint object we have?
        my $accessor = sub {
            #print "Running accessor for $k\n"; # DEBUG
            my $self_ = shift;
            if (@_) {
                $av->($constraint, $_[0]);      # Validate the arg or die
                return $self_->{$k} = $_[0];

            } elsif ( exists $self_->{$k} ) {
                return $self_->{$k};

            } else {
                my $defaults_ =
                    Class::Tiny->get_all_attribute_defaults_for( ref $self_ );
                #print "# Defaults for $k in " . ref($self_) . ":\n"; # DEBUG
                #use Data::Dumper; my $x = Dumper($defaults_); $x =~ s/^/# /gm; print $x;  # DEBUG

                my $def_ = $defaults_->{$k};
                $def_ = $def_->() if ref $def_ eq 'CODE';

                $av->($constraint, $def_);      # Validate the default or die
                return $self_->{$k} = $def_;
            }
        }; #accessor()

        { # Install the accessor
            no strict 'refs';
            my $dest = $target . '::' . $k;
            #print "Installing into $dest\n";   # DEBUG
            *{ $dest } = $accessor;
        }

    } #foreach constraint
} #import()

# _get_constraint_sub: Get the subroutine for a constraint.
sub _get_constraint_sub {
    my ($type) = @_;
    my $compiled;
    if ($type->can('compiled_check')) { # Type::Tiny
        $compiled = $type->compiled_check;

    } elsif (my $method = $type->can('inline_check')||$type->can('_inline_check')) { # Specio, Moose
        $compiled = eval { eval sprintf 'sub { my $value = shift; %s }', $type->$method('$value') };
        # above will fail if type cannot be inlined, so next block isn't `elsif`
    }

    if (!$compiled) {
        if ($type->can('check')) { # Specio, Moose, Mouse
            $compiled = sub { $type->check(@_) };

        } elsif (ref($type) eq 'CODE') { # MooX::Types
            $compiled = sub { eval { $type->(@_); 1 } };

        } else {
            die "Dunno how to use this type";
        }
    }
    ...
} #_get_constraint_sub()

1; # End of Class::Tiny::ConstrainedAccessor
# Rest of the docs {{{1
__END__

=head1 AUTHOR

Christopher White, C<< <cxwembedded at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests through the GitHub Issues interface
at L<https://github.com/cxw42/Class-Tiny-ConstrainedAccessor>.  I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Class::Tiny::ConstrainedAccessor

You can also look for information at:

=over 4

=item * GitHub (report bugs here)

L<https://github.com/cxw42/Class-Tiny-ConstrainedAccessor>

=item * RT: CPAN's request tracker

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Class-Tiny-ConstrainedAccessor>

=item * Search CPAN

L<https://metacpan.org/release/Class-Tiny-ConstrainedAccessor>

=back

=head1 LICENSE

Copyright 2019 Christopher White.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Apache License (2.0). You may obtain a
copy of the full license at:

L<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut
# }}}1
# vi: set fdm=marker:
