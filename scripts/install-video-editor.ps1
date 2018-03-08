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

    # remove the blender exe shortcut, it will be confused with our startup file below
    Remove-Item 'C:\Users\Administrator\Desktop\Blender.lnk'

    # this startup file configures a timeline view, typical of a video editor.
    cp "c:\cfn\scripts\startup.blend" "C:\Users\Administrator\Desktop\blender.blend"

    # download a video file that can be loaded into the editor
    downloadFile $bigbuckSourceUrl $bigbuckDestFilename
}
catch {
    Write-Verbose "catch: $_"
    $_ | Write-AWSQuickStartException
}




