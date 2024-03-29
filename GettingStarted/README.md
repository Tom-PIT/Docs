# Getting started guide for developers
This guide shows the necessary steps to perform a first launch and start using the Tom PIT platform.

## Prerequisites
This guide assumes the user has administrator access on the specific OS they're using. This is required for package installation and software startup.

The prerequisites are required in order to launch a development environment easily. If you already have all the prerequisites installed, you may skip these steps and continue to [container configuration](#configuration).
- Docker (linux images)
- WSL (Windows only)
- GIT (Optional, but recommended)
- The .env and docker-compose.yaml files from this repository

#### First time preparation
- [Windows](#prepare-windows)
- [Linux](#prepare-linux)

<a name="prepare-windows"></a>
### Windows
There are two ways of installing the platform and prerequisites on Microsoft Windows (Win 10 and up). The first is fully automated and can be accessed by opening an <b>administrator</b> PowerShell and pasting the following:

```ps
Invoke-expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Tom-PIT/Docs/main/GettingStarted/src/Windows/install.ps1'))
```

Alternatively, follow the steps below:
1. Ensure "winget" is installed and enabled on your system. You can verify this by running

    ```ps
    winget -v
    ``` 
    in PowerShell. 
    If installed, a version will be displayed. If not, follow the install instructions [here]("https://github.com/microsoft/winget-cli").
2. Ensure WSL is enabled and up to date on your system. You can verify this by running

    ```ps
    wsl --status
    ``` 
    in PowerShell. 
    If installed, WSL info will be displayed. If not, make sure your OS is on build 2004 or later, and run the command
    ```ps
    wsl --install
    ```
    Follow the setup steps and reboot your computer.
3. Ensure the default WSL version is 2. 
    ```ps
    wsl --set-default-version 2
    ```
4. Ensure "Docker desktop" is installed on your system. You can do this by running
    ```ps
    docker info
    ```
    from PowerShell.
    If no info is returned, install Docker desktop by running
    ```ps
    winget install docker.dockerdesktop
    ```
    from PowerShell. After the procedure is completed, restart PowerShell.
5. Ensure the Docker daemon is running. If running
    ```ps
    docker info
    ```
    ends in a message similar to:
    ```
    Server:
    ERROR: error during connect: this error may indicate that the docker daemon is not running: Get "http://%2F%2F.%2Fpipe%2Fdocker_engine/v1.24/info": open //./pipe/docker_engine: The system cannot find the file specified.
    ```
    odds are the Docker daemon is not running. Start it by either running Docker desktop from your start menu, or by running
    ```ps
    & "C:\Program Files\Docker\Docker\frontend\Docker Desktop.exe"
    ```
6. (Optional) Install SSMS
    ```ps
    winget install Microsoft.SQLServerManagementStudio
    ```

    <b>NOTE</b>: If at any point PowerShell claims it does not recognise a command you just installed, you probably need to close all PowerShell windows to restart PowerShell.
7. Install GIT for Windows
    ```ps
    winget install git.git
    ```
8. Clone this repository into a folder of your choice:
    ```ps
    mkdir C:/exampleDirectory
    cd C:/exampleDirectory
    git clone https://github.com/Tom-PIT/Docs.git
    cd Docs/GettingStarted/Compose
    explorer .
    ```


<a name="prepare-linux"></a>
### Linux 
There are two ways of installing the platform and prerequisites on a Debian based linux distro.
The first is fully automated and can be accessed by opening a Terminal and pasting the following:

```bash
source <(curl -s https://raw.githubusercontent.com/Tom-PIT/Docs/main/GettingStarted/src/Linux/install.sh)
```

Alternatively, follow the steps below:
1. Update apt repository data
    ```bash
    sudo apt update
    ```
2. Install Docker daemon
    ```bash
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install docker and required plugins
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```
3. (Optional) Configure Docker to run at startup
    ```bash
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    ```
4. Install GIT
    ```bash
    sudo apt-get update
    sudo apt-get install git
    ```
5. Clone this repository
    ```bash
    sudo mkdir /exampleDir
    cd /exampleDir
    git clone https://github.com/Tom-PIT/Docs.git
    cd Docs/GettingStarted/Compose
    ```

### Starting the platform environment
<a name="configuration"></a>
#### .env configuration
There are two files required to start the platform, supplied in the [GettingStarted/Compose](https://github.com/Tom-PIT/Docs/tree/main/GettingStarted/src/Compose) directory of this repository.

Regardless of you using the install script or following the preparation steps, you ended up in a directory containing both these files:
- docker-compose.yaml (instructions for docker setup and container management).
- .env (user and environment specific varaiables to use in combination with the above file).

Let us take a look at the .env environment variables:
- DB_PASSWORD - the default password of the initialized database. Can be left as default.
- INSTANCE_TOKEN - the default instance token, used for REST calls between instances. Can be left as default.
- SQL_PORT - the port on which the database is visible on the host. Change between instances.
- DEV_PORT - the port on which the development instance is visible on the host. Change between instances.
- QA_PORT - the port on which the qa instance is visible on the host. Change between instances.

#### Docker-compose configuration
The docker-compose file is set up in a way that allows it to be run if the .env file is properly configured. Change at your own risk.

#### First start
The first start is identical on all platforms, thanks to Docker. To start a mini platform cluster, consisting of a database server, a development instance and a QA instance, simply run
```bash
docker-compose up
```
from the folder containing both the .env and docker-compose.yaml files.

To run several instances, copy both files to another folder, change the port configuration in the .env file, and repeat the above procedure.

There are a few things to be wary of when starting the mini cluster; the first startup must initialize the database, install the base development microservices and configure the platform. Much can go wrong if startup parameters are tampered with, but even with a perfect startup, the initialization process takes a bit of time. This only happens on the first and second start. See the flow below to understand what happens.

1. The sql development server starts, configures a default user and creates the default "sys" database.
2. Once the server is healthy, the development instance starts. On startup, it checks for an installation complete flag. If none is found or it is in the error state, the system attempts to reinstall the "Tom-PIT/Development base" image from the repository service. Dependening on your connection, this can take a few minutes.
3. Once development has finished installing the microservices, it must restart. The restart will be noted in the logs.
4. Once development restarts, it will recompile all missing microservices.
5. The QA instance detects the development instance is healthy and running and starts itself, compiling any missing microservices.

Once the QA instance is fully running, the platform is ready to start development.

On all subsequent restarts of the mini cluster (docker-compose down), the database initialization and microservice installation steps are skipped.

## Troubleshooting
### My instance won't start
First of all, run an instance without changing any variables in the .env file and without changing the docker-compose.yaml file. If it starts up then, chances are there is a conflict in your settings somewhere. Be wary of the # sign, as it is interpreted as a comment in .env and .yaml files.
