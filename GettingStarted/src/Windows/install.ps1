write-host "Welcome to the Tom PIT platform install script. This script will set up your development machine to the point of the first platform run."
$installPath = read-host "Please enter the path into which to install the first start repository"

##Ensure install folder exists and is empty
if(!(test-path $installPath)) {
    New-Item -Path $installPath -ItemType "directory"
}

## Install winget
write-host "Installing winget"

$wingetResponse = winget -v;

if($wingetResponse){
    winget upgrade winget
}
else {
    $wingetUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    $wingetUrl = (Invoke-WebRequest -Uri $wingetUrl).Content | ConvertFrom-Json |
            Select-Object -ExpandProperty "assets" |
            Where-Object "browser_download_url" -Match '.msixbundle' |
            Select-Object -ExpandProperty "browser_download_url"

    $wingetSetup = "$installPath/Setup.msix";

    Invoke-WebRequest -Uri $wingetUrl -OutFile $wingetSetup -UseBasicParsing

    Import-Module -Name Appx -UseWindowsPowerShell
    Add-AppxPackage -Path $wingetSetup

    Remove-Item $wingetSetup
}

## Install WSL

write-host "Installing WSL 2"

wsl --update
wsl --set-default-version 2

## Install Docker desktop
write-host "Installing docker desktop"
winget install docker.dockerdesktop

## Install Git
write-host "Installing Git"
winget install git.git

## Clone repo and open explorer
write-host "Cloning repository"
Set-Location $installPath
if(test-path "$installPath/Docs"){
    git clone git@github.com:Tom-PIT/Docs.git
}else{
    git pull
}
Set-Location Docs/GettingStarted/Compose
explorer .

## Complete
write-host "Setup completed. It is recomended you restart your machine before attempting to run the platform."
write-host "Remember to start docker desktop after the restart!"
Pause