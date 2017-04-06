[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Source = 'https://www.dropbox.com/s/ily0pzhn855y2zs/PCoIP_agent_release_installer_2.7.0.4060_graphics.exe?dl=1',

    [Parameter(Mandatory=$false)]
    [string]$Destination = 'C:\cfn\downloads\PCoIP_agent_release_installer_2.7.0.4060_graphics.exe',

    [string]$stack,

    [string]$resource
)


# 2.5 teradici
# https://dl.dropbox.com/sh/a6mjoxkb03gnghf/AADmNMMpIWQMOMSogX8ERI2ja/PCoIP_agent_release_installer_2.5.1.908_graphics.exe?dl=1

try {
    $ErrorActionPreference = "Stop"

    Write-Verbose "Install Teradici"
    $parentDir = Split-Path $Destination -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType directory -Force | Out-Null
    }

    Write-Verbose "Trying to download from $Source to $Destination"
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
       #
       Start-Process -FilePath $Destination -ArgumentList '/S','/nodeskside' -Wait


       Write-Verbose "Creating pcoip_control_panel.exe shortcut"
       # create shortcut to teradici control panel
       #
       $WshShell = New-Object -comObject WScript.Shell
       Write-Verbose "Home = $Home"
       $desktopPath = "$Home\Desktop\pcoip_control_panel.lnk"
       Write-Verbose "shortcut path = $desktopPath"
       $Shortcut = $WshShell.CreateShortcut($desktopPath)
       $Shortcut.TargetPath = "C:\Program Files (x86)\Teradici\PCoIP Agent\bin\pcoip_control_panel.exe"
       $Shortcut.Save()
    } else {
        throw "Problem installing Teradici, not .exe extension"
    }
    Write-Verbose "Install Teradici complete"

    Write-Verbose "cfn-signal --success --stack $stack  --resource $resource"
    cfn-signal --success true --stack $stack --resource $resource

    # GPU drivers require a restart
    Restart-Computer
}
catch {
    Write-Verbose "catch: $_"
    $_ | Write-AWSQuickStartException
}
