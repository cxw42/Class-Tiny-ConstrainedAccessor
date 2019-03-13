#!perl
use 5.006;
use lib::relative 'lib';
use Kit;

use SampleTypeTinyBadDefaults;

# Tests to run: description => [should die, arguments to use()]
my %tests = (
    'Dies with no express arguments' => [1],
    'Dies with only med_with_default' => [1, med_with_default => 14],
    'Dies with only lazy_default' => [1, lazy_default => 15],
    'Lives with both' => [0, med_with_default => 16, lazy_default => 17],
);

foreach my $test (keys %tests) {
    my $should_die = $tests{$test}->[0];
    shift @{$tests{$test}};
    my $action = sub {
        my $x = SampleTypeTinyBadDefaults->new(@{$tests{$test}});
        diag $x->med_with_default;  # Make sure the accessors run
        diag $x->lazy_default;
    };

    if($should_die) {
        &dies_ok($action, $test);
    } else {
        &lives_ok($action, $test);
    }
}

done_testing();
