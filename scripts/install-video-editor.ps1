[cmdletbinding()]
 Param()

try {
    $ErrorActionPreference = "Stop"


    # echo "Install blender"
    #
    # where msiexec.exe - shows location of executable
    #
    # Start-Process msiexec.exe   /?
    #
    #choco install --limit-output -y blender

    #Write-Verbose "Blender install complete"
}
catch {
    Write-Verbose "catch: $_"
    $_ | Write-AWSQuickStartException
}




