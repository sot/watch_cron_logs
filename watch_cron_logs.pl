#!/usr/bin/env /proj/axaf/bin/perl

# Keep a 7-day daily archive of log outputs from cron jobs
# 
# Author:  T. Aldcroft
# Created: 29-July-2004

use warnings;
use File::Basename;
use Getopt::Long;
# use Mail::Send;

sub run($) {
  my $command = shift;
  print "$command\n" if $opt{loud};
  system($command) == 0 or die $!;
}

our %opt = (erase => 0,
	    loud => 1,
	    subject => 'TST ops cron outputs',
	    logs   => 'Logs',
	   );

GetOptions (\%opt,
	    'logs=s',
	    'recipients=s',
	    'subject=s',
	    'copy!',
	    'loud!',
	    'help!',
	   );

if ( $opt{help} )
{
  use lib '/proj/axaf/simul/lib/perl';
  require 'usage.pl';
  usage(0);
}

our $n_days = 7;
our $logs = $opt{logs};
our $MASTER_LOG = 'MASTER.log';

# Slide every daily directory up by one and delete 8th day if there
for $i (reverse (0 .. $n_days-1)) {
    $i1 = sprintf "%d", $i+1;
    run "mv $logs/daily.$i $logs/daily.$i1" if -e "$logs/daily.$i";
}

run "rm -rf $logs/daily.$n_days" if -e "$logs/daily.$n_days";

# Make directory for newest log data and grab all such log files

run "mkdir $logs/daily.0";
@files = glob("$logs/*");

# Concat log info into a single MASTER log file in the same directory

@ARGV = @files;
our $master_file = "$logs/daily.0/$MASTER_LOG";
open MASTER, "> $master_file" or die "Could not open $master_file";
select MASTER;
our $file = "";
while (<ARGV>) {
    # If the input ARGV file has changed then print header
    if ($ARGV ne $file) {
	print "\n\n" if $file;
	$file = $ARGV;
	printf "%s %s %s\n", "*"x20, basename($file), "*"x(30-length(basename($file)));
    }
    print;
}
close MASTER;
select STDOUT;

# Move all log files in $logs to $logs/daily.0 and touch to create
# new (empty) log files

foreach (@files) {
    next if /daily.\d\Z/;
    if ($opt{erase}) {
	run "mv $_ $logs/daily.0 ; touch $_";
    } else {
	run "cp $_ $logs/daily.0/";
    }
}

# Email "notifications", which is currently just a copy of the $MASTER_LOG file

# @ARGV = ($master_file);
# our $master = '';
# while (<ARGV>) { $master .= $_; }

if (defined $opt{recipients}) {
    open EMAIL, "$opt{recipients}" or die "Could not open recipients file $opt{recipients}";
    while (<EMAIL>) {
	chomp;
	next unless /\S/;
	s/\s//g;
	push @addr, $_;
    }
    close EMAIL;

    my $addr_list = join(',', @addr);
    run "mail -s \"$opt{subject}\" $addr_list < $master_file";
}

=head1 NAME

watch_cron_logs.pl - Watch output log files from a set of cron jobs
                     and collect outputs into daily archives.  This
                     tool should be run once daily.

=head1 SYNOPSIS

watch_cron_logs.pl [options]

=head1 OPTIONS

=over 8

=item B<-logs <log_file_directory>>

Look for log files in <log_file_directory>

=item B<-erase>

Erase contents of log files each day

=item B<-loud>

Show exactly what watch_cron_logs is doing

=item B<-recipients <recipients_list_file>>

Email notifications to addresses in <recipients_list_file>

=item B<-subject <email_subject>>

'Subject' of email notifications

=item B<--help>

print this usage and exit.

=back

=head1 DESCRIPTION

B<watch_cron_logs> is normally used as a cron job itself to monitor
the outputs of other cron tasks on a daily basis.  It collects the
task outputs into daily archives accumulate for a week.  It will
also do specific error detection and email notification, but not yet. 

=head2 EXAMPLE

 /proj/sot/ska/bin/watch_cron_logs.pl -logs /proj/sot/tst/ops

=head1 AUTHOR

Tom Aldcroft (taldcroft@cfa.harvard.edu)
