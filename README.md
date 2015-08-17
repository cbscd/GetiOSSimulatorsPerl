# GetiOSSimulatorsPerl

This script was created to show a parametrized option with available iOS Simulator in a build job in Jenkis-CI.

This is how it will look when you build your project:
<div style="align:center">
<img align="center" src="https://github.com/cbscd/GetiOSSimulatorsPerl/blob/master/Docs/JenkinsCI-BuildProjectSample.png?raw=true"/>
</div>

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
$ perl -w listAvailableSims.pl -deviceType=iPad -sdk=8.4 -deviceName=iPad Air
```
Could output this:
```
iOS 8.3 - iPad 2 - (1F5DBDD1-026F-46FB-9AB2-1D15EC9E5A2A)
iOS 8.3 - iPad Retina - (C9F9EC38-602E-4783-8B43-F732D743F3AD)
iOS 8.3 - iPad Air - (5EC9C557-3360-451E-B0A9-B99E4800BE1C)
iOS 8.3 - Resizable iPad - (BD6466DB-C95A-461B-B56F-1F9B0C0C4D24)
iOS 8.4 - iPad 2 - (FA1CEF97-A77E-47DA-AA59-8997561F2C3B)
iOS 8.4 - iPad Retina - (C2636E48-55A9-4F22-9B4A-CBC2902EF650)
iOS 8.4 - iPad Air - (0BA0375B-760C-4DB8-AF11-4232A7C3E01B):selected
iOS 8.4 - Resizable iPad - (44FF4304-758A-4C2D-9DF6-B8AB3E2A481D)
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

If you want to get the whole list of iPhone and iPad simulators, just ommit the ```deviceType``` option:
```bash
$ jenkins$ perl -w listAvailableSims.pl -sdk=8.3 -deviceName=iPad Retina
```
Could output this:
```

iOS 8.3 - iPhone 4s - (F472FFE7-7897-4404-BFA5-17FB535C42B6)
iOS 8.3 - iPhone 5 - (3CB9BA5F-B4D7-4D66-AB48-AB53F837742A)
iOS 8.3 - iPhone 5s - (725993D1-0EE2-4CCE-9DA3-CD38FC2182B4)
iOS 8.3 - iPhone 6 Plus - (E79F891B-48E3-428C-8770-1178B5D24A9C)
iOS 8.3 - iPhone 6 - (13DB6E18-6D51-43A6-9A21-AC30B71832D5)
iOS 8.3 - iPad 2 - (1F5DBDD1-026F-46FB-9AB2-1D15EC9E5A2A)
iOS 8.3 - iPad Retina - (C9F9EC38-602E-4783-8B43-F732D743F3AD):selected
iOS 8.3 - iPad Air - (5EC9C557-3360-451E-B0A9-B99E4800BE1C)
iOS 8.3 - Resizable iPhone - (061A178A-94AB-45CB-9D39-1AD6D151064F)
iOS 8.3 - Resizable iPad - (BD6466DB-C95A-461B-B56F-1F9B0C0C4D24)
iOS 8.4 - iPhone 4s - (D74AC053-D7C5-41A4-AC3C-7D5C97895A9E)
iOS 8.4 - iPhone 5 - (3797B959-63AA-4D6F-8A3A-F0D4B5BD541E)
iOS 8.4 - iPhone 5s - (069D193B-B340-4745-9A5E-7D510853FBD1)
iOS 8.4 - iPhone 6 Plus - (6650D1CB-2749-4032-BE56-27F0A28CD50F)
iOS 8.4 - iPhone 6 - (7C63D73A-FF42-4C8E-BE6A-B92901523402)
iOS 8.4 - iPad 2 - (FA1CEF97-A77E-47DA-AA59-8997561F2C3B)
iOS 8.4 - iPad Retina - (C2636E48-55A9-4F22-9B4A-CBC2902EF650)
iOS 8.4 - iPad Air - (0BA0375B-760C-4DB8-AF11-4232A7C3E01B)
iOS 8.4 - Resizable iPhone - (2B4E84E3-C310-4A95-A56D-CACA9EA0405D)
iOS 8.4 - Resizable iPad - (44FF4304-758A-4C2D-9DF6-B8AB3E2A481D)
```

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
In the job configuration, use the [Active Choices Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Active+Choices+Plugin) to choose the Scriptler Script.

<div style="align:center">
<img align="center" src="https://github.com/cbscd/GetiOSSimulatorsPerl/blob/master/Docs/JenkinsCI-JobConfigSample.png?raw=true"/>
<img align="center" src="https://github.com/cbscd/GetiOSSimulatorsPerl/blob/master/Docs/JenkinsCI-JobConfigSample2.png?raw=true"/>
</div>
