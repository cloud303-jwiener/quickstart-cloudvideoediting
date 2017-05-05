[CmdletBinding()]

$winVersion = [Environment]::OSVersion.Version
if ($winVersion.Major -eq 10) {
    Write-Verbose 'Detected Windows Server 2016'

    # I was told win10 is very close to windows server 2016
    #
    # $Source = 'http://us.download.nvidia.com/Windows/Quadro_Certified/362.56/362.56-quadro-grid-desktop-notebook-win10-64bit-international-whql.exe'
    # $Destination = 'c:\Users\Administrator\Downloads\362.56-quadro-grid-desktop-notebook-win10-64bit-international-whql.exe'

    # 369.95
    #
    $Source = 'http://us.download.nvidia.com/Windows/Quadro_Certified/GRID/369.95/369.95-quadro-winserv-2016-64bit-international-whql.exe'
    $Destination = 'c:\Users\Administrator\Downloads\369.95-quadro-winserv-2016-64bit-international-whql.exe'
} elseif ($winVersion.Major -eq 6 -and $winVersion.Minor -eq 1) {
    Write-Verbose 'Detected Windows Server 2008R2'

    $Source = 'http://us.download.nvidia.com/Windows/Quadro_Certified/362.56/362.56-quadro-tesla-grid-winserv2008-2008r2-2012-64bit-international-whql.exe'
    $Destination = 'c:\Users\Administrator\Downloads\362.56-quadro-tesla-grid-winserv2008-2008r2-2012-64bit-international.exe'
} else {
    Write-Verbose 'Unsupported version of Windows: $winVersion'
    throw 'Unsupported version of Windows: $winVersion'
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
# https://devtalk.nvidia.com/default/topic/830929/quadro-348-07-driver-silent-installation-unable-to-generate-setup-iss-response-file/
#

try {
    $ErrorActionPreference = "Stop"

    Write-Verbose "Unzip GPU Drivers"
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
        Write-Verbose "Extract GPU drivers ..."
        # first extract the setup.exe so we can pass the -noreboot = noreboot and -s = silent cmd line params
        # self extracting installer only excepts /s
        #
        # x = preserve dir structure
        # -aoa = overwrite
        # -o is output dir
        Start-Process -FilePath "c:\Program Files\7-Zip\7z.exe" -ArgumentList 'x',$Destination,'-aoa','-oc:\Users\Administrator\Downloads\gpu-drivers' -NoNewWindow -Wait

        Write-Verbose "Install GPU drivers ... run setup.exe"
        date
        # -noreboot = no reboot
        # -s = silent install, don't pop up a window for input
        # Start-Process -FilePath "c:\Users\Administrator\Downloads\gpu-drivers\setup.exe" -ArgumentList '-s' -Wait

        # using a ProcessStartInfo object is masking the exit 1
        #
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = "c:\Users\Administrator\Downloads\gpu-drivers\setup.exe"
        $pinfo.RedirectStandardError = $true
        $pinfo.RedirectStandardOutput = $true
        $pinfo.UseShellExecute = $false
        $pinfo.Arguments = '-s'
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start()
        $p.WaitForExit()
        $stdout = $p.StandardOutput.ReadToEnd()
        $stderr = $p.StandardError.ReadToEnd()
        Write-Verbose "gpu driver install process stdout: $stdout"
        Write-Verbose "gpu driver install stderr: $stderr"
        Write-Verbose "gpu driver install exit code:"
        $p.ExitCode | Write-Verbose

        Write-Verbose "complete: install GPU drivers"
        date
     } else {
        Write-Verbose "throw exception, didn't find .exe extension for $Destination"
        throw "Problem installing gpu drivers, not .exe extension"
     }
}
catch {
    Write-Verbose "catch: $_"
    $_ | Write-AWSQuickStartException
}



