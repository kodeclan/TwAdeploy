***********************************
Build machine prerequisites:

Build machine should have the following three packages installed:

1) Go programming language 1.12.4  ( https://dl.google.com/go/go1.12.4.windows-amd64.msi )

2) WiX toolkit version 3.14.0.2812 ( http://wixtoolset.org/releases/v3-14-0-2812/ )

3) MS Build: The current way of building the installer project is MSBuild.  MSBuild is included in every .NET framework instance so should already be there on your Windows machine.


***********************************
TwAdeploy WiX installer build instructions:

Step one: Build golang code used for WiX Toolset custom action

Navigate to directory LoadUbuntuIntoWSL\DownloadUbuntuCustomAction
and launch build_extension.bat. This will produce a "downloadUbuntu.exe" file in the same directory.

Step two - Build the WiX installer with MSBuild

First locate the MSBuild executable. It should be found 
on C:\Windows\Microsoft.NET\Framework\v4.0.XXXXX\MSBuild.exe

I do not know what differences there are between the 32 bit and 64 bit version of MSBuild.exe, but for simplicity, I always use the 32 bit one since it is the one most mentioned in various internet blogs etc.
XXXX numbers are exact version of .NET framework and can differ 
depending on Windows version. 

Add C:\Windows\Microsoft.NET\Framework\v4.0.XXXXX\ to your Windows system path.
Finally launch installer build by calling MSBuild on WSLUbuntuInstaller.sln
file in root project directory.
The command should look like this:

MSBuild.exe WSLUbuntuInstaller.sln /P:Configuration=Release

You should end up with complete installer bundle located in WSL-and-Ubuntu\bin\Release subdirectory.  The only file needed is:

WSL-and-Ubuntu\bin\Release\WSL_and_Ubuntu.exe

That's all required steps for the WiX installer build process.

Now simply copy "WSL_and_Ubuntu.exe" to any computer running either Windows 10 (version 1607 or later) or Windows Server 2019 (any version) and run the exectuable.  The installer will then install WSL and Unbuntu 18.04 onto that Windows 10/2019 computer.
