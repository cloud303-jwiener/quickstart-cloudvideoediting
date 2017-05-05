

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

    #echo "aws: Install Chrome"
    #Write-Verbose "Install Chrome"
    #choco install --limit-output -y GoogleChrome

    echo "aws: Install 7zip"
    Write-Verbose "Install 7zip"
    choco install --limit-output -y 7zip

    Write-Verbose "Install awscli"
    choco install --limit-output -y awscli

    # windows version numbers
    # https://msdn.microsoft.com/library/windows/desktop/ms724832.aspx
    $winVersion = [Environment]::OSVersion.Version
    Write-Verbose "Detected Windows version $winVersion"
    if ($winVersion.Major -eq 6 -and $winVersion.Minor -eq 1) {
        #
        # Windows 2008 R2 only
        #
        # install windows media player, requirement for Adobe Premiere

        #echo "aws: Install windows media player"
        #Write-Verbose "Detected 2008 R2 or Windows 7"
        #Write-Verbose "Install windows media player"
        #import-module servermanager
        #Add-WindowsFeature Desktop-Experience
    } else {
        echo "aws: Didn't detect 2008 R2"
        Write-Verbose "Didn't detect 2008 R2"
    }

    Write-Verbose "choco installs complete"
}
catch {
    Write-Verbose "catch: $_"
    $_ | Write-AWSQuickStartException
}




