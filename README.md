# GetiOSSimulatorsPerl

This script was created to show a parametrized option in a build job in Jenkis-CI.

----------
### Installation
Put the **listAvailableSims.pl** into $JENKINS_HOME folder and configure a Scriptler script.
```
/Users/Shared/Jenkins/Home/listAvailableSims.pl
```
----------
### Options
This script receives some parameters in order to parse the output from the ```xcrun simctl list``` command.

Name                  | Type     | Expected value
--------------------- | ---------| ------------------
deviceType (optional) | String   | iPhone or iPad
deviceName            | String   | Any possible name like *'iPhone 6s'* (without quotes)
sdk                   | String   | Any possible iOS version in the form of *9.0*
xcodeBeta (optional)  | Flag     | No value expected

To know the possible values for the deviceName and sdk, run ``` xcrun simctl list ``` in Terminal.

If you would like to list the simulators available in the Xcode-beta, specify *xcodeBeta* flag.

If the **deviceName** and **sdk** parameters match a configuration available, a ```:selected``` will be appended at the end of that line. The ```:selected``` text appended at the end of the match is used by the Active Choice Jenkins plugin to select the default iOS Simulator in the list.

----------
### Usage

Executing this:
```bash
$ cd /Users/Shared/Jenkins/Home
$ perl -w listAvailableSims.pl -deviceType=iPad -sdk=8.4 -deviceName=iPad Air -xcodeBeta
```
Could output this:
```

iOS 9.0 - iPad 2 - (38F1D37E-4B5B-40B5-9F17-FDAE7010490B)
iOS 9.0 - iPad Retina - (64010687-2F15-42A5-89EE-DF267D4D25E3)
iOS 9.0 - iPad Air - (0489B01C-6565-4EAF-B4F3-1F2385D1DC8B)
iOS 9.0 - iPad Air 2 - (07168067-B41C-43B2-8CF7-708325BBB42C)
```


Executing this:
```bash
$ perl -w listAvailableSims.pl -deviceType=iPad -sdk=8.4 -deviceName=iPad Air
```
Could output this:
```

iOS 9.0 - iPad 2 - (38F1D37E-4B5B-40B5-9F17-FDAE7010490B)
iOS 9.0 - iPad Retina - (64010687-2F15-42A5-89EE-DF267D4D25E3)
iOS 9.0 - iPad Air - (0489B01C-6565-4EAF-B4F3-1F2385D1DC8B)
iOS 9.0 - iPad Air 2 - (07168067-B41C-43B2-8CF7-708325BBB42C)
```
> **Note:**
 - There is no match on the **deviceName** and **sdk** options and ```:selected``` is not present on any of the lines.

----------
### Groovy script
In Jenkins add a Scriptler script with the next content:
```Groovy
def scriptPath = "/Users/Shared/Jenkins/Home/listAvailableSims.pl"
def command = "perl -w $scriptPath -deviceType=iPhone -sdk=9.0 -deviceName=iPhone 6 -xcodeBeta"

Process process = command.execute()

def out = new StringBuffer()
def err = new StringBuffer()

process.consumeProcessOutput( out, err )
process.waitFor()

if( err.size() > 0 ) println err
if( out.size() > 0 ) {
  return out.readLines()
}
```
----------
### Job configuration
In the job configuration, use the **Active Choices Parameter** to choose the Scriptler Script.
