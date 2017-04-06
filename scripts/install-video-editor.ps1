

try {
    $ErrorActionPreference = "Stop"

    # this is failing
    #
    # Invoke-Item (start powershell ((Split-Path $MyInvocation.InvocationName) + ".\show-reboots.ps1"))

    #
    # Install packages
    #
    Write-Verbose "Install Chocolatey"
    $url = 'https://chocolatey.org/install.ps1'
    iex ((new-object net.webclient).DownloadString($url))

    Write-Verbose "Install Chrome"
    choco install --limit-output -y GoogleChrome

    Write-Verbose "Install 7zip"
    choco install --limit-output -y 7zip

    Write-Verbose "Install awscli"
    choco install --limit-output -y awscli

    #
    # install windows media player, requirement for premiere
    #
    Write-Verbose "Install windows media player"
    import-module servermanager
    Add-WindowsFeature Desktop-Experience


    # echo "Install blender"
    #
    # where msiexec.exe - shows location of executable
    #
    # Start-Process msiexec.exe   /?
    #
    #choco install --limit-output -y blender

    Write-Verbose "choco installs complete"
}
catch {
    Write-Verbose "catch: $_"
    $_ | Write-AWSQuickStartException
}




