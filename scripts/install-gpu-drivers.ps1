[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$WinVersion
)

if ($WinVersion -eq 'windows2016') {
    Write-Verbose 'Assume windows2016'

    # win10 very close to windows server 2016
    #
    # $Source = 'http://us.download.nvidia.com/Windows/Quadro_Certified/362.56/362.56-quadro-grid-desktop-notebook-win10-64bit-international-whql.exe'
    # $Destination = 'c:\Users\Administrator\Downloads\362.56-quadro-grid-desktop-notebook-win10-64bit-international-whql.exe'

    # 369.95
    #
    $Source = 'http://us.download.nvidia.com/Windows/Quadro_Certified/GRID/369.95/369.95-quadro-winserv-2016-64bit-international-whql.exe'
    $Destination = 'c:\Users\Administrator\Downloads\369.95-quadro-winserv-2016-64bit-international-whql.exe'
} else {
    Write-Verbose 'Assume windows2008r2'

    $Source = 'http://us.download.nvidia.com/Windows/Quadro_Certified/362.56/362.56-quadro-tesla-grid-winserv2008-2008r2-2012-64bit-international-whql.exe'
    $Destination = 'c:\Users\Administrator\Downloads\362.56-quadro-tesla-grid-winserv2008-2008r2-2012-64bit-international.exe'
}


#
# 362.56 was recommended due to performance issues by teradici ... need to double check in email
#
# http://us.download.nvidia.com/Windows/Quadro_Certified/362.56/362.56-quadro-grid-desktop-notebook-win10-64bit-international-whql.exe


# extract the nvidia setup because we can't pass the no reboot flag to the whql exe ... it ignores it
#

#
# install GPU drivers
#
#       -s = silent
#       -noreboot = no reboot
#
# http://nvidia.custhelp.com/app/answers/detail/a_id/2985/~/how-can-i-perform-a-silent-install-of-the-gpu-driver%3F
#

try {
    $ErrorActionPreference = "Stop"

    Write-Verbose "Install GPU Drivers"
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
        Write-Verbose "Start install of GPU drivers ..."
        # first extract the setup.exe so we can pass the -noreboot = noreboot and -s = silent cmd line params
        # self extracting installer only excepts /s
        #
        # x = preserve dir structure
        # -aoa = overwrite
        # -o is output dir
        Start-Process -FilePath "c:\Program Files\7-Zip\7z.exe" -ArgumentList 'x',$Destination,'-aoa','-oc:\Users\Administrator\Downloads\gpu-drivers' -NoNewWindow -Wait

        echo ""
        echo "install GPU drivers"
        date
        # -noreboot = no reboot, important or it will interrupt the rest of the install proces
        # -s = silent install, don't pop up a window for input
        Start-Process -FilePath "c:\Users\Administrator\Downloads\gpu-drivers\setup.exe" -ArgumentList @('-noreboot', '-s') -Wait
        echo "complete: install GPU drivers"
        date
     } else {
        throw "Problem installing gpu drivers, not .exe extension"
     }
}
catch {
    Write-Verbose "catch: $_"
    $_ | Write-AWSQuickStartException
}



