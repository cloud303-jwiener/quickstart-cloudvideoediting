[cmdletbinding()]
Param()

[string]$bigbuckSourceUrl = "http://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_1080p_stereo.avi"
[string]$bigbuckDestFilename = "C:\Users\Administrator\Downloads\big_buck_bunny_1080p_stereo.avi"

function downloadFile($sourceUrl, $destFilename) {
    Write-Verbose "Trying to download from $sourceUrl to $destFilename"
    $tries = 5
    while ($tries -ge 1) {
        try {
            (New-Object System.Net.WebClient).DownloadFile($sourceUrl,$destFilename)
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
}


try {
    $ErrorActionPreference = "Stop"

    $env:path += ";C:\ProgramData\chocolatey\bin"
    Write-Verbose "path = $env:path"

    Write-Verbose "Install blender"
    #
    # where msiexec.exe - shows location of executable
    #
    # Start-Process msiexec.exe   /?
    #
    choco install --limit-output -y blender

    # create a shortcut to blender on the desktop
    #
    $WshShell = New-Object -comObject WScript.Shell
    $desktopPath = "C:\Users\Administrator\Desktop\Blender.lnk"
    Write-Verbose "shortcut path = $desktopPath"
    $Shortcut = $WshShell.CreateShortcut($desktopPath)
    $Shortcut.TargetPath = "C:\Program Files\Blender Foundation\Blender\blender.exe"
    $Shortcut.WorkingDirectory = "c:\Program Files\Blender Foundation\Blender"
    $Shortcut.Save()
    Write-Verbose "Blender install complete"

    # download a video file that can be loaded into the editor
    downloadFile $bigbuckSourceUrl $bigbuckDestFilename
}
catch {
    Write-Verbose "catch: $_"
    $_ | Write-AWSQuickStartException
}




