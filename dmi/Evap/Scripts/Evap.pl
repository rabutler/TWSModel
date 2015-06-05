#
# $Id: NFSinput.pl,v 1.2 2008/08/21 22:38:39 jprairie Exp $
# $Id: CCDemandsInput.pl, v 1.0 2012/03/21 abutler
# $Id: Evap.pl, v 1.0 2012/03/22 abutler
#

use strict;
use warnings;

open STDERR, ">$ENV{CRSS_DIR}/temp/dmiperl.err";
open STDOUT, ">$ENV{CRSS_DIR}/temp/dmiperl.out";

my $verbose = 1;

# ensure the $(TRACES) environment variable is set.
die "Error: \$(CRSS_DIR) isn't set.\n" unless defined $ENV{CRSS_DIR};
my $TRACES="$ENV{CRSS_DIR}/dmi/Evap";
print "Trace directory is: $TRACES\n" if $verbose;

# ensure the temp directory is writable.
#my $tempdir = "$TRACES/Temp";

my $tempdir = '';
if (defined $ENV{RW_DMI_TEMPDIR}) {
	$tempdir = $ENV{RW_DMI_TEMPDIR};
} else {
	$tempdir = "$TRACES/Temp";
}	

die "Error: $tempdir isn't writable: $!\n" if
    ! -w $tempdir && ! mkdir $tempdir;
print "Temp directory is: $tempdir\n" if $verbose;

# extract the trace number from the last parameter (-STrace=N).
die "Error: Cannot determine trace number.\n" unless
    $ARGV[-1] =~ /\-STrace=(\d+)/;
my $trace = $1;

if ( -s "$TRACES/initialoffset") {
  open INPUT, "< $TRACES/initialoffset";
  my $offset=<INPUT>;
  $trace+=$offset;
  close INPUT;
}

print "Trace number is: $trace\n" if $verbose;

my $tracedir = "$TRACES/Trace$trace";
print "Trace directory is: $tracedir\n" if $verbose;

opendir(DIR, $tracedir) || die "Cannot open trace directory: $!\n";
my @slots = grep { $_ !~ /^CVS$/ } grep { /^[^\.]/ } readdir(DIR);
closedir DIR;

foreach (@slots) {
    print "Processing slot: $_\n" if $verbose;
    my $input = "$tracedir/$_";
    my $output = "$tempdir/$_";

    # open the input and output files.
    open(INPUT, "< $input") || die "Cannot open $input for reading: $!\n";
    if (!open(OUTPUT, "> $output")) {
        close INPUT;
        die "Cannot open $output for writing: $!\n";
    }

    # read the data from the input file and write it to the output
    # file.
    map { print OUTPUT } <INPUT>;

    close INPUT;
    close OUTPUT;
}

exit 0;
