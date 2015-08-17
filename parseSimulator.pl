#!/usr/bin/perl
use strict;
use warnings;

my $jenkinsHome = $ENV{"JENKINS_HOME"};
my $folder = "$jenkinsHome/temp";
my $filePath = "$folder/jobSimulatorProperties.txt";
my $composedLine = "";

if (defined($ARGV[0])) {
  $composedLine = "$ARGV[0]"; # This should be in the form of "iOS 8.3 - iPhone 4s - (F472FFE7-7897-4404-BFA5-17FB535C42B6)" without quotes.
}

if ( $composedLine ne "" ) {
  my $deviceName = deviceName($composedLine);
  my $sdkVersion = sdkVersion($composedLine);
  my $udid = udid($composedLine);

  system("echo 'UDID=$udid' > $filePath");
  system("echo 'DEVICE_NAME=\"$deviceName\"' >> $filePath");
  system("echo 'SDK=$sdkVersion' >> $filePath");
}


sub ltrim { my $s = shift; $s =~ s/^\s+//;       return $s };
sub rtrim { my $s = shift; $s =~ s/\s+$//;       return $s };
sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

sub deviceName {
  my $line = shift;
  my $deviceName = "";
  if ($line =~  /.*?-(.*?)-.*?/) {
    $deviceName = trim($1);
  }
  return $deviceName;
}

sub sdkVersion {
  my $line = shift;
  my $sdkVersion = "";
  if ($line =~  /^iOS(.*?)-.*?/) {
    $sdkVersion = trim($1);
  }
  return $sdkVersion;
}

sub udid {
  my $line = shift;
  my $udid = "";
  if ($line =~ /.*?\((.*?)\).*?/) {
    $udid = trim($1);
  }
  return $udid;
}
