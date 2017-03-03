
param(
    [string]$stack,
    [string]$resource
)


#
# Install Chrome and AWS CLI
#
echo ""
echo "Install Chocolatey"
$url = 'https://chocolatey.org/install.ps1'
iex ((new-object net.webclient).DownloadString($url))
echo "Install Chrome"
choco install --limit-output -y GoogleChrome
echo "Install awscli"
choco install --limit-output -y awscli
echo "Install blender"
choco install --limit-output -y blender
echo ""
echo "choco installs complete"


$workingDir = 'c:\Users\Administrator\Downloads'

#
# install GPU drivers
#
#       /s = silent
#       /n = no reboot
#
# http://nvidia.custhelp.com/app/answers/detail/a_id/2985/~/how-can-i-perform-a-silent-install-of-the-gpu-driver%3F
#

echo ""
echo "install GPU drivers"
date
Start-Process -FilePath "$($workingDir)\362.56-quadro-grid-desktop-notebook-win10-64bit-international-whql.exe" -ArgumentList "/s /n" -NoNewWindow -Wait
echo "complete: install GPU drivers"
date


#
# install teradici software
#
echo ""
echo "installing Teradici"
date
#
# /S for silent
#
#
# ProcessStartInfo is a way to try and trap the Exit 1 coming from the Teradici installer
#
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "$($workingDir)\PCoIP_agent_release_installer_2.7.0.4060_graphics.exe"
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.Arguments = "/S /nodeskside"
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
$p.WaitForExit()
$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()
echo "Teradici process stdout: $stdout"
echo "Teradici process stderr: $stderr"
echo "Teradici exit code: " + $p.ExitCode
#
# start-process using the method below gives exit code of 1 and
# causes CF to show a failed stack
#
# $obj = Start-Process -PassThru -FilePath "$($workingDir)\PCoIP_agent_release_installer_2.7.0.4060_graphics.exe" -ArgumentList "/S /nodeskside" -NoNewWindow -Wait
#
echo "complete: install Teradici"
date


echo "cfn-signal --success --stack $stack  --resource $resource"
cfn-signal --success true --stack $stack --resource $resource


#
# GPU drivers require reboot
#
Restart-Computer
