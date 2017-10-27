[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Source = 'https://fileshare.teradici.com/s/50MC5kGr3YoCjgG/download',

    [Parameter(Mandatory=$false)]
    [string]$Destination = 'C:\cfn\downloads\PCoIP_agent_release_installer_2.8.0.6123_graphics.exe'
)

try {
    $ErrorActionPreference = "Stop"

    $parentDir = Split-Path $Destination -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType directory -Force | Out-Null
    }

    Write-Verbose "Trying to download Teradici from $Source to $Destination"
    $tries = 5
    while ($tries -ge 1) {
        try {
            (New-Object System.Net.WebClient).DownloadFile($Source,$Destination)
            break
        }
        catch {
            $tries--
            Write-Verbose "Exception:"
            Write-Verbose "$_"
            if ($tries -lt 1) {
                throw $_
            }
            else {
                Write-Verbose "Failed download. Retrying again in 5 seconds"
                Start-Sleep 5
            }
        }
    }

    if ([System.IO.Path]::GetExtension($Destination) -eq '.exe') {
       Write-Verbose "Start install of Teradici ..."
       # '/NoPostReboot' - to prevent reboot
       #
       Start-Process -FilePath $Destination -ArgumentList '/S','/nodeskside', '/NoPostReboot'  -Wait

       Write-Verbose "Creating pcoip_control_panel.exe shortcut"
       # create shortcut to teradici control panel
       #
       $WshShell = New-Object -comObject WScript.Shell
       #
       # Write-Verbose "Home = $env:USERPROFILE"
       # for 2016 when run via cfn-init:
       #    $env:USERPROFILE returns 'C:\Windows\system32\config\systemprofile'
       #  when run in powershell, $HOME AND $env:USERPROFILE both return:
       #    C:\Users\Administrator
       #
       $desktopPath = "C:\Users\Administrator\Desktop\pcoip_control_panel.lnk"
       Write-Verbose "shortcut path = $desktopPath"
       $Shortcut = $WshShell.CreateShortcut($desktopPath)
       $Shortcut.TargetPath = "C:\Program Files (x86)\Teradici\PCoIP Agent\bin\pcoip_control_panel.exe"
       $Shortcut.Save()

       # we don't allow Teradici to reboot after install or else the above shortcut would get interrupted
       Restart-Computer
    } else {
        throw "Problem installing Teradici, not .exe extension"
    }
    Write-Verbose "Install Teradici complete"
}
catch {
    Write-Verbose "catch: $_"
    $_ | Write-AWSQuickStartException
}
