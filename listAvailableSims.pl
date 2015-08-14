#!/usr/bin/perl -w
# Put this file into JENKINS_HOME folder and configure a Scriptler script.
# This is intended to be used to show a parametrized option in a build job.
#
# For example the next Groovy script will print a list of available iPad simulators.
#
# def scriptPath = "/Users/Shared/Jenkins/Home/listAvailableSims.pl"
# def command = "perl -w $scriptPath iPad"
#
# Process process = command.execute()
#
# def out = new StringBuffer()
# def err = new StringBuffer()
#
# process.consumeProcessOutput( out, err )
# process.waitFor()
#
# if( err.size() > 0 ) println err
# if( out.size() > 0 ) {
#   return out.readLines()
# }

use strict;
# use Getopt::Mixed::init( 'd=s s=s n=s deviceType>d sdk>s deviceName>n');
use warnings;
use Getopt::Long; # Released with Perl 5.005

my($devicesDetected) = 0;
my($unavailable) = 0;
my $sdk = "";
my $jenkinsHome = $ENV{"JENKINS_HOME"};
my $folder = "$jenkinsHome/temp";
my $filePath = "$folder/simList.txt";
my $deviceType = "";
my $defaultDevice = "";
my @defaultDeviceParam;
my $defaultSDKVersion = "";
my $useXcodeBeta = 0;

GetOptions(
            "xcodeBeta"         => \$useXcodeBeta,
            "deviceType:s"      => \$deviceType,
            "deviceName=s{1,}"  => \@defaultDeviceParam,
            "sdk=s"             => \$defaultSDKVersion,
          )
          or die("Error in command line arguments\n");

$defaultDevice = trim(join(' ',@defaultDeviceParam));

my $newFilePath = "$folder/available" .  $deviceType . "SimList.txt";
my $defaultSimulatorFilePath = "$folder/default" .  $deviceType . ".txt";

if ($useXcodeBeta) {
  # if xcodeBeta flag was specified it will point to the Xcode beta by overriding the DEVELOPER_DIR variable.
  $ENV{DEVELOPER_DIR} = '/Applications/Xcode-beta.app/Contents/Developer';
}

system("mkdir -p $folder");
system("xcrun simctl list > $filePath");  # Gets the raw list
system("rm -f $newFilePath");  # Deletes the file if exists.
system("rm -f $defaultSimulatorFilePath");  # Deletes the file if exists.

open FH, '<', $filePath or die ("Can't read file: $filePath\n $!");
open(my $FWH, '>', $newFilePath) or die "Could not open file '$newFilePath' $!";

print "\n"; # Inserts a blank line at the begining of the results.

while (<FH>) {
  # Good practice to store $_ value because
  # subsequent operations may change it.
  my($line) = trim($_);

  # Good practice to always trim.
  $line = trim($line);

  # If the line contains "Devices" turn on the flag and skip the line.
  if ($line =~ m|(.*?)Devices(.*?)|) {
    $devicesDetected = 1;
    next;
  }

  # Filtering simulators containing "unavailable".
  $unavailable = 0;
  if ($line =~ m|(.*?)[Uu]navailable(.*?)|) {
    $unavailable = 1;
    next;
  }

  # Skips lines with dash characters
  if ($line =~ /--([^-]+)-/) {
    $sdk = trim($1);
    next;
  }

  # If devices has been detected and the line doesn't contain "unavailable",
  #  we print the iOS version and the name of the device.
  if ($devicesDetected && $unavailable==0) {
    my($parsedLine) = trim( substr($line, 0, index($line, '(')) );

    # Retrieves the UDID
    my $udid = udid($line);

    my $composedLine = "";
    # If the device was specified as parameter, then verifies that it matches.
    if ($deviceType ne "") {
      if ($line =~ m|(.*?)$deviceType(.*?)|) {
        $composedLine = "$sdk - $parsedLine - ($udid)";
      }
    } else {
      $composedLine = "$sdk - $parsedLine - ($udid)";
    }

    my $selected = "";
    if ($composedLine ne "") {
      $selected = (shouldBeSelected($composedLine) eq '1') ? ":selected" : "";
      # my $deviceName = deviceName($composedLine);
      if ($selected ne '') {
        my $deviceName = deviceName($composedLine);
        my $sdkVersion = sdkVersion($composedLine);
        system("echo 'DEFAULT_SIMULATOR=$composedLine' > $defaultSimulatorFilePath");
        system("echo 'UDID=$udid' >> $defaultSimulatorFilePath");
        system("echo 'DEVICE_NAME=$deviceName' >> $defaultSimulatorFilePath");
        system("echo 'SDK=$sdkVersion' >> $defaultSimulatorFilePath");
      }
      print "$composedLine$selected\n";
      print $FWH "$composedLine$selected,";
    }
  }
}

close ($FWH) or die "Could not close $newFilePath: $!";
close (FH) or die "Could not close $filePath: $!";
system("rm $filePath");

sub shouldBeSelected {
  my $composedLine = shift;

  my $selected;
  my $deviceName = trim(deviceName($composedLine));
  my $sdkVersion = trim(sdkVersion($composedLine));
  my $sameDeviceName = ($deviceName eq $defaultDevice ? 1 : 0);
  my $sameSDKVersion = ($sdkVersion eq $defaultSDKVersion ? 1 : 0);
  # print "Same DeviceName $sameDeviceName, Same SDK $sameSDKVersion\n";
  # print "Detected: '$sdkVersion' '$deviceName'\n";
  # print "'$deviceName' = '$defaultDevice'\n";
  $selected = ($sameDeviceName == 1 && $sameSDKVersion == 1) ? '1' : '0';
  return $selected;
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
