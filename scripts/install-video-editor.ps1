[cmdletbinding()]
Param()

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

    Write-Verbose "Blender install complete"
}
catch {
    Write-Verbose "catch: $_"
    $_ | Write-AWSQuickStartException
}




