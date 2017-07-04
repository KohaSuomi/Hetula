#!/usr/bin/env perl

# Copyright 2017 KohaSuomi
#
# This file is part of Koha.
#

use 5.22.0;
use Carp;
use autodie;
$Carp::Verbose = 'true'; #die with stack trace
use English; #Use verbose alternatives for perl's strange $0 and $\ etc.
use Getopt::Long qw(:config no_ignore_case);
use Try::Tiny;
use Scalar::Util qw(blessed);

my ($help, $dryRun);
my ($verbose, $gitTailLength) = (0, 0);
my ($clover, $tar, $junit);
my ($run);


GetOptions(
    'h|help'                      => \$help,
    'v|verbose:i'                 => \$verbose,
    'dry-run'                     => \$dryRun,
    'clover'                      => \$clover,
    'tar'                         => \$tar,
    'junit'                       => \$junit,
    'run'                         => \$run,
);

my $usage = <<USAGE;

Runs a ton of tests with other metrics if needed

  -h --help             This friendly help!

  -v --verbose          Integer, the level of verbosity

  --tar                 Create a testResults.tar.gz from all tests and deliverables

  --dry-run             Don't run tests or other metrics. Simply show what would happen.

  --clover              Run Devel::Cover and output Clover-reports.
                        Clover reports are stored to testResults/clover/clover.xml

  --junit               Run test via TAP::Harness::Junit instead of TAP::Harness. Junit xml results
                        are stored to testResults/junit/*.xml

  --run                 Actually run the tests. Without this flag, the script will simply compile and run
                        without doing any work or changes.
                        You can use this to test that this script is actually compilable.

EXAMPLE

  ks-test-harness.pl --tar --clover --junit --run

USAGE

if ($help) {
    print $usage;
    exit 0;
}

use File::Basename;
use TAP::Harness::JUnit;
use KSTestHarness;


run() if $run;
sub run {
    my (@tests, $tests);
    push(@tests, @{_getAllTests()});

    print "Selected the following test files:\n".join("\n",@tests)."\n" if $verbose;

    my $ksTestHarness = KSTestHarness->new(
        resultsDir => undef,
        tar        => $tar,
        clover     => $clover,
        junit      => $junit,
        testFiles  => \@tests,
        dryRun     => $dryRun,
        verbose    => $verbose,
        lib        => [$ENV{HETULA_HOME}.'/lib', $ENV{HETULA_HOME}],
    );
    $ksTestHarness->run();
}

sub _getAllTests {
    return _getTests('.', '*.t');
}
sub _getTests {
    my ($dir, $selector, $maxDepth) = @_;
    $maxDepth = 999 unless(defined($maxDepth));
    my $files = _shell("/usr/bin/find $dir -maxdepth $maxDepth -name '$selector'");
    my @files = split(/\n/, $files);
    return \@files;
}

###DUPLICATION WARNING Duplicates C4::KohaSuomi::TestRunner::shell
##Refactor this script to C4::KohaSuomi::TestRunner if major changes are needed.
sub _shell {
    my (@cmd) = @_;
    my $rv = `@cmd`;
    my $exitCode = ${^CHILD_ERROR_NATIVE} >> 8;
    my $killSignal = ${^CHILD_ERROR_NATIVE} & 127;
    my $coreDumpTriggered = ${^CHILD_ERROR_NATIVE} & 128;
    warn "Shell command: @cmd\n  exited with code '$exitCode'. Killed by signal '$killSignal'.".(($coreDumpTriggered) ? ' Core dumped.' : '')."\n  STDOUT: $rv\n"
        if $exitCode != 0;
    print "@cmd\n$rv\n" if $rv && $verbose > 0;
    return $rv;
}

