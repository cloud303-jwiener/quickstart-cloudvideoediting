
param(
    [string]$stack,
    [string]$resource
)


#
# install GPU drivers
#
#       /s = silent
#       /n = no reboot
#
# http://nvidia.custhelp.com/app/answers/detail/a_id/2985/~/how-can-i-perform-a-silent-install-of-the-gpu-driver%3F
#
echo "install GPU drivers"
date
Start-Process -FilePath "c:\Users\Administrator\Downloads\369.26-quadro-tesla-grid-winserv2008-2008r2-2012-64bit-international-whql.exe" -ArgumentList "/s /n" -NoNewWindow -Wait
echo "complete: install GPU drivers"
date


#
# install teradici software
#
echo "installing Teradici"
date
Start-Process -FilePath "c:\Users\Administrator\Downloads\PCoIP_agent_release_installer_2.5.1.908_graphics.exe" -ArgumentList "/S /nodeskside" -NoNewWindow -Wait
echo "complete: install Teradici"
date


$url = 'https://chocolatey.org/install.ps1'
iex ((new-object net.webclient).DownloadString($url))
choco install --limit-output -y GoogleChrome
choco install --limit-output -y awscli


#
# install windows media player, requirement for premiere
#
echo "Install windows media player"
import-module servermanager
Add-WindowsFeature Desktop-Experience


#
# GPU drivers require reboot
#
Restart-Computer


echo "cfn-signal --success --stack $stack  --resource $resource"
cfn-signal --success true --stack $stack --resource $resource