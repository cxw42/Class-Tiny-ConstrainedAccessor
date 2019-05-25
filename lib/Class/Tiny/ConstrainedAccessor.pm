package Class::Tiny::ConstrainedAccessor;

use 5.006;
use strict;
use warnings;
use Class::Tiny;

our $VERSION = '0.000009'; # TRIAL

# Docs {{{1

=head1 NAME

Class::Tiny::ConstrainedAccessor - Generate Class::Tiny accessors that apply type constraints

=head1 SYNOPSIS

L<Class::Tiny> uses custom accessors if they are defined before the
C<use Class::Tiny> statement in a package.  This module creates custom
accessors that behave as standard C<Class::Tiny> accessors except that
they apply type constraints (C<isa> relationships).  Type constraints
can come from L<Type::Tiny>, L<MooseX::Types>, L<MooX::Types::MooseLike>,
L<MouseX::Types>, or L<Specio>.  Alternatively, constraints can be applied
using the technique described in
L<"Constraints without a type system"|/CONSTRAINTS WITHOUT A TYPE SYSTEM>.

Example of a class using this package:

    package SampleClass;
    use Scalar::Util qw(looks_like_number);

    use Type::Tiny;

    # Create the type constraint
    use vars::i '$MediumInteger' = Type::Tiny->new(
        name => 'MediumInteger',
        constraint => sub { looks_like_number($_) and $_ >= 10 and $_ < 20 }
    );

    use Class::Tiny::ConstrainedAccessor {
        medint => $MediumInteger,           # create accessor sub medint()
        med_with_default => $MediumInteger,
    };

    # After using ConstrainedAccessor, actually define the class attributes.
    use Class::Tiny qw(medint regular), {
        med_with_default => 12,
    };

=head1 CONSTRAINTS WITHOUT A TYPE SYSTEM

If you don't want to use L<Type::Tiny> or one of the other type systems listed
above, you can create your own constraints as two-element arrayrefs.  Example:

    use Class::Tiny::ConstrainedAccessor
        'field' => [ \&checker_sub, \&message_sub ];

C<checker_sub> and C<message_sub> are used as follows to check C<$value>:

    checker_sub($value) or die get_message($value);

Therefore, C<checker_sub> must return truthy if C<$_[0]> passes the constraint,
or else falsy.  C<get_message> must return something that can be passed to
C<die()>, when given a C<$_[0]> that has failed the constraint.

If your profile ever tells you that constraint-checks are on the critical
path, try custom constraints.  They may give you more control or opportunity
for optimization than general-purpose type systems.

=head1 SUBROUTINES

=head2 import

Creates the accessors you have requested.  Basic usage:

    use Class::Tiny::ConstrainedAccessor
        name => constraint
        [, name => constraint ...]; # ... any number of name=>constraint pairs

This also creates a L<BUILD()|Class::Tiny/BUILD> subroutine to check the
constructor parameters, if a C<BUILD()> doesn't already exist.

If a C<BUILD()> does exist (e.g., you said C<use subs 'BUILD';>), this package
will create the same function, taking the same parameters as C<BUILD()> would,
but call it C<_check_all_constraints()>.   You can call this checker from your
own C<BUILD()> if you want to.

=head1 OPTIONS

To specify options, pass an B<arrayref> as the first argument on the `use`
line.  This is to leave room for someday carrying attributes and constraints in
a hashref.  For example:

    use Class::Tiny::ConstrainedAccessor [ OPTION=>value ],
        name => constraint ...;

Valid options are:

=over

=item NOBUILD

If C<< NOBUILD => 1 >> is given, the constructor-parameter-checker
is created as C<_check_all_constraints> regardless of whether C<BUILD()>
exists or not.  Example:

    package MyClass;
    use Class::Tiny::ConstrainedAccessor
        [NOBUILD => 1],
        foo => SomeConstraint;
    # Now $object->_check_all_constraints($args) exists, but not BUILD().

=back

=cut

# }}}1

sub import {
    my $target = caller;
    my $package = shift;

    my %opts = ();
    %opts = @{+shift} if ref $_[0] eq 'ARRAY';

    die "Need 'name => \$Constraint' pairs" if @_%2;

    my %constraints = @_;

    # --- Make the accessors ---
    my %accessors;  # constraint => [checker, get_message]
    foreach my $k (keys(%constraints)) {
        my $constraint = $constraints{$k};

        my ($checker, $get_message) =
                _get_constraint_sub($k, $constraint); # dies on failure

        my $accessor = _make_accessor($k, $checker, $get_message);
        $accessors{$k} = [$checker, $get_message];      # Save for BUILD()

        { # Install the accessor
            no strict 'refs';
            *{ "$target\::$k" } = $accessor;
        }
    } #foreach constraint

    # --- Make BUILD ---
    my $has_build =
        do { no warnings 'once'; no strict 'refs'; *{"$target\::BUILD"}{CODE} }
        || $opts{NOBUILD};  # NOBUILD => pretend BUILD() already exists.
    my $build = _make_build(%accessors);
    {
        no strict 'refs';
        *{ $has_build ? "$target\::_check_all_constraints" :
                        "$target\::BUILD" } = $build;
    }

} #import()

# _get_constraint_sub: Get the subroutine for a constraint.
# Takes the constraint name (for debug messages) and the constraint.
# Returns two coderefs: checker and get_message.
sub _get_constraint_sub {
    my ($type_name, $type) = @_;
    my ($checker, $get_message);

    # Handle the custom-constraint format
    if(ref $type eq 'ARRAY') {
        die "Custom constraint $type_name must have two elements: checker, get_message"
            unless scalar @$type == 2;
        die "$type_name: checker must be a subroutine" unless ref($type->[0]) eq 'CODE';
        die "$type_name: get_message must be a subroutine" unless ref($type->[1]) eq 'CODE';
        return @$type;
    }

    # Get type's name, if any
    my $name = eval { $type->can('name') || $type->can('description') };
    $name = $type->$name() if $name;

    # Set default message
    $name = $type_name unless $name;
    $get_message = sub { "Value is not a $name" };

    # Try the different types of constraints we know about
    DONE: {

        if (ref($type) eq 'CODE') { # MooX::Types::MooseLike
            $checker = sub { eval { $type->(@_); 1 } };
                # In profiling, seems to be about on par with `&$type;`.
            last DONE;
        }

        die "I don't know how to handle non-reference constraint $type_name"
            unless ref $type;   # All the rest of the checks use $type->can()

        if ( my $method = eval { $type->can('compiled_check') }) { # Type::Tiny
            $checker = $type->$method();
            $get_message = sub { $type->get_message($_[0]) };
            last DONE;
        }

        if (my $method = eval { $type->can('inline_check') || $type->can('_inline_check') }) { # Specio::Constraint::Simple
            $checker = eval {
                my $text = $type->$method('$value');
                    # $method() will fail if type cannot be inlined.
                local $SIG{__WARN__} = sub { };     # Eval failure => silent
                eval "sub { my \$value = shift; $text }"
            };
            last DONE if $checker;
        }

        if (my $method = eval { $type->can('check') } ) { # Moose, Mouse
            $checker = sub { unshift @_, $type; goto &$method; };
                # Like $type->check(@_), but profiles as much faster on my
                # test system.
            last DONE;
        }

        if(eval { $type->can('value_is_valid') }) { # Specio::Constraint::Simple
            $checker = sub { $type->value_is_valid(@_) };
            last DONE;
        }

    } #DONE

    die "$type_name: I don't know how to use type " . ref($type)
        unless $checker;

    return ($checker, $get_message);
} #_get_constraint_sub()

# _make_accessor($name, \&checker, \&get_message): Make an accessor.
sub _make_accessor {
    my ($k, $checker, $get_message) = @_;

    # The accessor --- modified from the Class::Tiny docs based on
    # the source for C::T::__gen_accessor() and C::T::__gen_sub_body().
    return sub {
        my $self_ = shift;
        if (@_) {                               # Set
            $checker->($_[0]) or die $get_message->($_[0]);
            return $self_->{$k} = $_[0];

        } elsif ( exists $self_->{$k} ) {       # Get
            return $self_->{$k};

        } else {                                # Get default
            my $defaults_ =
                Class::Tiny->get_all_attribute_defaults_for( ref $self_ );

            my $def_ = $defaults_->{$k};
            $def_ = $def_->() if ref $def_ eq 'CODE';

            $checker->($def_) or die $get_message->($def_);
            return $self_->{$k} = $def_;
        }
    }; #accessor()
} #_make_accessor()

# _make_build(%accessors): Make a BUILD subroutine that will check
# the constraints from the constructor arguments.
# The resulting subroutine takes ($self, {args}).
sub _make_build {
    my %accessors = @_;

    return sub {
        my ($self, $args) = @_;
        foreach my $k (keys %$args) {
            next unless exists $accessors{$k};
            my ($checker, $get_message) = @{$accessors{$k}};
            $checker->($args->{$k}) or die $get_message->($args->{$k});
        }
    } #BUILD()
} #_make_build()

1; # End of Class::Tiny::ConstrainedAccessor
# Rest of the docs {{{1
__END__

=head1 AUTHORS

Created by Christopher White, C<< <cxwembedded at gmail.com> >>.  Thanks to
Toby Inkster for code contributions.

=head1 BUGS

Please report any bugs or feature requests through the GitHub Issues interface
at L<https://github.com/cxw42/Class-Tiny-ConstrainedAccessor/issues>.  I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Class::Tiny::ConstrainedAccessor

You can also look for information at:

=over 4

=item * GitHub (report bugs here)

L<https://github.com/cxw42/Class-Tiny-ConstrainedAccessor>

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
