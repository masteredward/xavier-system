# Xavier System Project

<p align="center"><img src="https://raw.githubusercontent.com/masteredward/xavier-system/master/img/professor_xavier.jpg" alt="logo" class="responsive" style="width: 50%; height: auto"></p>

The **Xavier System** is a remote containerized development environment, which uses [Visual Studio Code](https://code.visualstudio.com), the [Remote - SSH](https://code.visualstudio.com/docs/remote/ssh) extension and an [AWS EC2](https://aws.amazon.com/aws/ec2) instance as backend. This project is sourced from the original [Xavier](https://github.com/masteredward/xavier) and the [aws-admin](https://github.com/masteredward/aws-admin) projects, now deprecated in favor of the **Xavier System**.

## Introduction

By taking advantage of **Visual Studio Code** features like *SSH Agent forwarding* and *Environment Variable Inheritance*, the **Xavier System** allows the user to enjoy a *fully dynamic* remote development environment with the *same benefits and ease of use* as developing locally.

The **Xavier System** is a "micro framework", which allows the user to manage a dynamic containerized environment to accomodate multiple projects in the same instance. The `xv` tools can mutate the whole development environment with a single command, using [Docker](https://www.docker.com) to build and deploy containers.

Using **Xavier System**, the user can keep it's PC clean from resource demainding systems like *Docker Desktop, Virtual Machines or WSL systems*. All that the user needs, is **Visual Studio Code**, the [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) utility, some custom shell functions and a [Nerd Font](https://github.com/ryanoasis/nerd-fonts) for the [Oh My ZSH](https://ohmyz.sh/) framework.

## Main Concepts

The **Xavier System** uses the concept of "System Overlay". The "xv-container", in **Xavier System's** terminology, assumes the OS role. This is the core principle of the **Xavier System**. *Only a single container can assume the OS role at time*. If the user needs to change the current `xv-container` to another one, the `xv` tool can build and deploy another `xv-contanier`, replacing the old one. This way, there is always a single `xv-container` running in the instance. This helps the user to not waste resources and keeping the system organized. The running container always assumes the name and hostname of `xv-container`.

The `xv` tool is the "brain" of the **Xavier System**. It builds and deploys the `xv-container` using the user's custom configuration in the `xv.yaml` file to setup container mounts, enviroment variables and ports, similar to a [Docker Compose](https://docs.docker.com/compose) file. The `xv.yaml` file also have the concept of a global shared configuration, with allows the user to set common mounts, environment variables or ports to all `xv-containers` lauched by the `xv` tool.

By default, any `xv-container` is supposed to bind it's OpenSSH service on the default port 22 *to the port 2222 on the instance's IPv4 localhost* (127.0.0.1). Using *AWS SSM tunneling* and the `xvpf` function, the user bind's a local port into the intance's localhost on port 2222. This is a *very secure practice*, since both the instance or the container doesn't need to listen to SSH connections from outsite AWS. No need for Public Subnets or Inbound Security Group Rules. Although, the **Xavier System** itself needs Internet access to download binaries and images. At least a **NAT Gateway** or a **proxy server** should be supplied for the **Xavier System** instance.

The default base distro image for **Xavier System** container builds is [Fedora 36](https://docs.fedoraproject.org/en-US/fedora/latest/), although, the user can change the distro images to **Ubuntu**, **Debian** or any other distro in the **Dockerfiles**. But for that, some changes in the Dockefiles are necessary.

Note that **ALPINE IMAGES AREN'T SUPPORTED**. Alpine is a perfect distro for slim containers, but it uses [musl](https://en.wikipedia.org/wiki/Musl) instead of the standard [glibc](https://en.wikipedia.org/wiki/Glibc) used my most of Linux distros. Visual Studio Code SSH extension *isn't compatible with any non-glibc* distros. This information is mentioned in their documentation [here](https://code.visualstudio.com/docs/remote/ssh#_remote-ssh-limitations).

## Deployment and Installation

The default installation of the **Xavier System** bundles the **Oh My ZSH** framework with the [Powerlevel10k](https://github.com/romkatv/powerlevel10k) ZSH theme maintained by [Roman Perepelitsa](https://github.com/romkatv). The installation can be customized by creating the configuration file `xv-setup.yaml` file, using the `xv-setup.example.yaml` file as source. For more information, read "[The xv-setup tool](#the-xv-setup-tool)" section.

The installation customization allows the user to choose various **Oh My ZSH** plugins and themes, builtin or custom. Also, allows the user to avoid **Oh My ZSH** entirelly. It's installation uses the `xv-setup` container tool, which uses an [Ansible](https://www.ansible.com) playbook for both setup and updates.

To automate the environment creation, the user can customize one of the bundled [AWS CloudFormation](https://aws.amazon.com/cloudformation) templates in the `cfn/` directory, available for both AMD64 (x86_64) or ARM64 (aarch64) architetures.

The CloudFormation template uses the minimal [Amazon Linux 2022](https://aws.amazon.com/linux/amazon-linux-2022) AMI with it's default kernel. The **Amazon Linux 2022** is the latest version of Amazon Linux, now rebased to **Fedora**. AWS team is doing a terrific job on optimizing the **Amazon Linux 2022** distro. For this reason, **Amazon Linux 2022** is the default base distro for the **Xavier System** project. The base distro can be customized as well, but since it will only be used as base for the Xavier System, there is no much benefit here. Also, the `xv` tool uses the official [Amazon Linux 2022 container image](https://hub.docker.com/_/amazonlinux/) as base too.

### Step 1: Local Setup

1. [Install Visual Studio Code](https://code.visualstudio.com/Download) in your PC. Installation can be either "User" or "System". Use which suits you best.

2. Install any of the [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) available. I suggest the patched version of [Inconsolata](https://en.wikipedia.org/wiki/Inconsolata), which can be downloaded for Windows [here](https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Inconsolata/complete/Inconsolata%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible.otf) or MacOS/Linux [here](https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Inconsolata/complete/Inconsolata%20Nerd%20Font%20Complete%20Mono.otf).

3. **Open Visual Studio Code** and configure the property `"terminal.integrated.fontFamily"` to `"Inconsolata NF"` or any other Nerd Font you downloaded. Also, I recommend to disable the experimental "Integrated Shell" feature and enable environment inheritance. Your `settings.json` can look like this:

    ```json
    {
        "terminal.integrated.fontFamily": "Inconsolata NF",
        "terminal.integrated.shellIntegration.enabled": false,
        "terminal.integrated.inheritEnv": true
    }
    ```

4. Install and enable the **Remote - SSH** extension on your **Visual Studio Code** installation. For more information, refer [here](https://code.visualstudio.com/docs/remote/ssh).

5. Generate an OpenSSH key pair for connecting to **Xavier System**, preferably using the **Ed25519** private key format, to generate a very secure key with a very small public key. You can use any other SSH key pair you alreavy have. The command bellow works in *any modern OS*, even **Windows 10+** using **Powershell**. Remmember to add a *secure passphrase* to your key.

    ```console
    ssh-keygen -t ed25519 -i ~/.ssh/firstlast-xavier-system -C first.last@email.com
    ```

6. Create and/or add the following configuration to the OpenSSH file `~/.ssh/config`. Since server keys will change contantly, I recommend adding the `StrictHostKeyChecking no` option and setting the `UserKnownHostsFile` to **NULL**:

    ```text
    Host xavier
        HostName localhost
        Port 2222
        User root
        IdentityFile ~/.ssh/firstlast-xavier-system
        ForwardAgent yes
        StrictHostKeyChecking no
        # For Windows
        UserKnownHostsFile \\.\NUL
        # For MacOS/Linux
        UserKnownHostsFile /dev/null
    ```

7. Install and configure the **AWS CLI v2** utility. It will allow you to deploy and to connect to your EC2 instance. Follow the documentation [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). Use `aws sts get-caller-identity` command to test the AWS CLI v2 installation and configuration

8. Configure `xv*` helper functions to interact with your Xavier System. The Xavier System relies on the usage of [AWS SSM Documents](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-ssm-docs.html) to bind local and remote ports on the EC2 instance in a very secure way. You don't need to add any specific value to the `InstanceId` variable now. After the CloudFormation stack is deployed, you can retrieve the *EC2 Instance ID*.

    ```powershell
    # Powershell (Windows, MacOS or Linux)
    
    # Edit profile with: code $PROFILE
    # Reload profile with: . $PROFILE

    $InstanceId = "i-xxx"

    function xvstart {
      aws ec2 start-instances --instance-ids $InstanceId
    }

    function xvstop {
      aws ec2 stop-instances --instance-ids $InstanceId
    }

    function xvpf {
      param (
          [Parameter(Mandatory,Position=0)] [string] $LocalPortNumber,
          [Parameter(Mandatory,Position=1)] [string] $RemotePortNumber
      )
      aws ssm start-session --target $InstanceId --document-name AWS-StartPortForwardingSession --parameters "portNumber=${RemotePortNumber},localPortNumber=${LocalPortNumber}"
    }

    function xvcmd {
      param (
          [Parameter(Mandatory,Position=0)] [string] $Command
      )
      aws ssm start-session --target $InstanceId --document-name AWS-StartInteractiveCommand --parameters "command=[${Command}]"
    }

    function xvssh {
      aws ssm start-session --target $InstanceId
    }
    ```

    ```bash
    # BASH or ZSH (MacOS or Linux)

    # You can add these functions directly to .bashrc or .zshrc files.

    InstanceId="i-xxx"

    xvstart() {
      aws ec2 start-instances --instance-ids $InstanceId
    }

    xvstop() {
      aws ec2 stop-instances --instance-ids $InstanceId
    }

   xvpf() {
      aws ssm start-session --target $InstanceId --document-name AWS-StartPortForwardingSession --parameters "portNumber=${1},localPortNumber=${2}"
    }

    xvcmd() {
      aws ssm start-session --target $InstanceId --document-name AWS-StartInteractiveCommand --parameters "command=[${1}]"
    }

    xvssh() {
      aws ssm start-session --target $InstanceId
    }
    ```

### Step 2: Xavier System Deployment

1. Create a **AWS Cloudformation** stack by modifying one of the templates in the `cfn` directory. *Modify the default values* to customize the setup. The `stack-arm64.yaml` deploys a Graviton2 ARM64 `t4g.medium` Instance by default. The `stack-amd64.yaml` deploys an AMD x86 `t3a.medium` Instance by default. ARM instances are *slighty cheaper and faster* than it's x86 counterparts. I suggest you to use ARM instead of x86, unless your're using applications and packages that are unavailable for ARM.

    ```console
    aws cloudformation deploy --stack-name my-xavier-system --template-file stack-arm64.yaml --capabilities CAPABILITY_NAMED_IAM
    ```

2. After the deploy is finished, you can retrieve the Xavier System instance ID to update the `InstanceId` variable for the functions.

    ```console
    aws cloudformation describe-stacks --stack-name my-xavier-system --query "Stacks[0].Outputs[0].OutputValue"
    ```

3. Use the `xvssh` function to access the instance shell through the `ssm-user`. Then access the **Xavier System** path `/opt/xavier/system` as **root**:

    ```console
    $ xvssh
    $ sudo su -
    # cd /opt/xavier/system
    ```

4. Start the Xavier System installation by running the `./xv-setup.sh` script. If you wanto to customize the setup, copy the `xv-setup.example.yaml` file into the `xv-setup.yaml` file, then edit it's contents. Then run `./xv-setup.sh`.

5. The installation can take some minutes to complete. Enjoy the moment to grab a coffee.

6. Finally, use installed `xv` to build and run the `xv-utils` example container. Exit `xvssh` afterwards:

    ```console
    # xv xv-utils
    # exit
    $ exit
    ```

7. Use `xvpf` function to start a tunnel using **SSM** from port `2222` on the local OS to `2222` on the **Xavier Instance**. This is a blocking function and you can terminate it with `CTRL+C`.

    ```console
    xvpf 2222 2222
    ```

8. Open another terminal window. Use `code` to access the `xv-utils` container shell:

    ```console
    code --remote ssh-remote+xavier /xavier
    ```

9. The `xv-utils` container have access to all **Xavier System** files. It can be used to *create/edit Dockerfiles*, the `source/xv.yaml` file or to make tweaks on the Xavier System directory `system`. For more information on `xv-utils`, read [Creating xv-containers using xv-utils](#creating-xv-containers-using-xv-utils).

10. If you installed Xavier System with **Oh My ZSH** and the **Powerlevel10k** theme, run the `p10k configure` utility from **Visual Studio Code** *Integrated Terminal* to customize the theme.

11. Go to the `/xavier/sources` directory and start designing your containers! Time for some fun!

## Xavier System Directory Structure

The **Xavier System** uses a directory structure inside the `/opt/xavier` path. The `xv-utils` container, by default, mounts this path into the `/xavier` directory. These are the **Xavier System's** subdirectories:

- `root/` - This is the common shared `/root` directory for all `xv-containers`. This will allow every `xv-container` to share a common **Oh My ZSH** theme and plugins. Also share binaries and scripts installed under `/root/bin/`. This directory, however, is not intended for storing GIT repositories or other user's work. For that, use the `workspace/` directory.

- `sources/` - This is where things happen: Each one of the `sources/` subdirectories contains **Dockerfiles** and other files that are used during the `xv-container` builds by the `xv` tool. Also, the `xv.yaml` configuration file is located there. It's the user's main configuration file for the `xv` tool. The name of the subdirectory is the actual name of the `xv-container`. For more information, read "[The xv tool](#the-xv-tool)" section.

- `system/` - The clone of **Xavier System's** GIT repository is here. There the user can create a custom `xv-setup.yaml` file to customize the **Xavier System** installation. Also, the `xv-setup.sh` script can be used to update **Xavier System** configuration. For more information, read "[The xv-setup tool](#the-xv-setup-tool)" section.

- `tools/` - This is a reserved directory for user-managed container tools sources. Container tools are single-run or service helper containers, like the `xv` or the `amazon/aws-cli` container tools. The support to build and manage container tools is planned for future releases of the **Xavier System** project.

- `workspace/` - This directory, by default, is mounted on all `xv-containers` in the `/workspace` directory. The goal of this directory is to store there all user's GIT repositories and/or temporary directories for testing between `xv-containers`.

## The xv tool

The `xv` tool is quite simple. It's a containerized Python script that uses the [python-on-whales](https://github.com/gabrieldemarmiesse/python-on-whales) library maintained by [Gabriel de Marmiesse](https://github.com/gabrieldemarmiesse) to handle `xv-containers` builds and deployment. It must run as root (using sudo) and expects the name of the `xv-container` as argument. The example bellow will build `xv-utils` image and start it as the `xv-container`. If there is already a `xv-container` running, the `xv` tool will REPLACE it:

```console
xvcmd "sudo xv xv-utils"
```

WARNING: The `xv` tool is under constant development and isn't handling exceptions correctly.

### Configuring xv-containers

The `xv` tool main configuration file is the `xv.yaml` file, located under `source/` in the **Xavier System's** directory structure. There is a brief explanation on how it works:

```yaml
# Under "shared" the user can configure mounts, environments and ports that will be available to all xv-containers.
shared:
  # For "ports" it's mandatory to set all the 3 values, host, container and protocol.
  # If there is no ports to bound, set "ports:" to "ports: []"
  ports:
  - host: 127.0.0.1:2222 # This is the port that will be bound in the instance.
    container: 22 # This is the port that will be bound to the xv-container.
    protocol: tcp # This is the port protocol, tcp or udp.
  # For "environments", "name" and "value" must be set for every environment.
  environment:
  - name: BUILT_BY
    value: xavier-system
  # Under "volumes", set the bind mounts that will be exposed to xv-containers.
  # Please note that Docker Volumes aren't supported, just bind mounts.
  # It's mandatory to set all the 3 values, source, target and mode.
  volumes:
  - source: /opt/xavier/root # This is the path related to the HOST OS.
    target: /root # This is the path where the "source" will be bound into the xv-container.
    mode: rw # This is the mount mode. Only sets to rw if the container needs to modify files there.
  - source: /opt/xavier/workspace
    target: /workspace
    mode: rw
    # Notice that, by default, the Docker binary and UNIX socket is mounted on all containers. This will allow xv-containers to run container tools.
  - source: /usr/bin/docker
    target: /usr/bin/docker
    mode: ro
  - source: /var/run/docker.sock
    target: /var/run/docker.sock
    mode: rw

# Under "containers", the user can set the same options as above. The only difference here is that the ports, environments and volumes listed are available only to a specific xv-container. This way, the user can customize the container with unique features.
# The keys under "containers" MUST MATCH the name of the subdirectory under "sources/". the xv tool uses this information to properly build and deploy the xv-container.
containers:
  cdk-base:
    # No extra ports means only the shared ports are available. The key must be set to "[]" or the xv tool will produce an error.
    ports: []
    environment:
      # Change the AWS_PROFILE variabke
    - name: AWS_PROFILE
      value: myprofile
    volumes:
      # Mouting the AWS CLI config directory into the xv-container is only necessary if the user is developing applications that are using the AWS SDK to access AWS resources and need to test this integration, like CDK do.
      # For the actual AWS CLI usage, the Xavier System's fake "aws" utility automatically mounts the .aws config directory without the need to expose it to the container.
    - source: /root/.aws
      target: /root/.aws
      mode: ro

  xv-utils:
    ports: []
    environment:
      # This environment prevents the powerlevel10k theme to automatically launch it's configuration wizard. This can be removed if the user changed the theme on the xv-setup.yaml configuration file.
    - name: POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD
      value: "true"
    volumes:
      # This mount allows xv-utils to have full access on all Xavier System's directory structure for administration.
    - source: /opt/xavier
      target: /xavier
      mode: rw
      # This mount exposes the AWS CLI config directory on xv-utils for visualization and customization. Instead of using "aws configure", the user can setup the profiles on the "config" file by hand.
    - source: /root/.aws
      target: /xavier/awsconfig
      mode: rw

  # New container example:
  # The user must create a new subdirectory under "sources/" with the same name here.
  # In this case, the directory "sources/eks-hero/" needs to be created with a Dockerfile inside.
  eks-hero:
    ports:
      # This can be useful to expose EKS port-forwarding through SSM tunneling to the local machine.
    - host: 127.0.0.1:8080
      container: 8080
      protocol: tcp
    environment:
    - name: AWS_PROFILE
      value: profile_with_eks_cluster_access
    volumes: []

  # Minimal config
  simple-container:
    ports: []
    environment: []
    volumes: []
```

## The xv-setup tool

The `xv-setup.sh` script runs the `xv-setup` container tool. The `xv-setup` container run an Ansible playbook that setups and/or updates the Xavier System dependencies and features.
It uses the `xv-setup.yaml` file to select which examples sources and tools will be installed when the the playbook runs. If the `xv-setup.yaml` file isn't found, the `xv-setup` tool will generate a new one by copying the default `xv-setup.example.yaml` file.

The user can run this tool multiple times to add new features and update it's GIT repositories.

Please note that the `xv-setup` tool don't delete anything. If the user wants to remove a theme or a plugin, it must do it by hand.

Also, it's possible for the user to disable the **Oh My ZSH** framework or set the enabled plugins and theme for it.

For custom plugins, the user can add multiple GIT repositories and the name of the directory that will hold the plugin. The support for the theme is similar, but it only allows the user to set a single custom theme.

The default `xv-setup.yaml` file:

```yaml
install:
  # Change to False here to disable Oh My ZSH installation
  ohmyzsh: True
  examples:
    # By default, all example sources will be installed
    sources:
    - xv-utils
    - cdk-base
    tools:
      # By default, all scripts will be installed
      scripts:
      - eks-kubeconfig.sh
      - get-kubectl.sh
      - update-eksctl.sh

ohmyzsh:
  plugins:
    # By default, the xv-setup will clone the "zsh-autosuggestions" and "zsh-syntax-highlighting" plugins.
    # Also, enable them along with the builtin "git" and "history-substring-search" plugins
    enabled:
    - git
    - history-substring-search
    - zsh-autosuggestions
    - zsh-syntax-highlighting
    custom:
    - path: zsh-autosuggestions
      repo: https://github.com/zsh-users/zsh-autosuggestions.git
    - path: zsh-syntax-highlighting
      repo: https://github.com/zsh-users/zsh-syntax-highlighting.git
  theme:
    # By default, the powerlevel10k custom theme is cloned and set as current theme
    enabled: powerlevel10k/powerlevel10k
    custom:
      path: powerlevel10k
      repo: https://github.com/romkatv/powerlevel10k.git
```

## Creating xv-containers using xv-utils

Creating `xv-containers` needs that the user have some familiarity with Dockerfiles and container building.

By connecting to `xv-utils`, the user needs to create a new directory under `/xavier/sources/`.

For future releases of the **Xavier System**, it's planned to add a new tool (xv-make.sh) to help the user to bootstrap new sources easily. For now, the process is basically copy one of the existing examples and modify it.

For example, to create the source with the name `eks-hero`:

```console
mkdir /xavier/sources/eks-hero
```

Then, create a `/xavier/sources/eks-hero/Dockerfile` similar to this one:

```dockerfile
FROM fedora:36

RUN dnf install -y \
  git \
  helm \
  jq \
  passwd \
  openssh-clients \
  openssh-server \
  shadow-utils \
  zsh \
  && dnf clean all

RUN ssh-keygen -A && passwd -d root \
  && printf "\nPasswordAuthentication no\nPermitUserEnvironment yes\n" >> /etc/ssh/sshd_config

RUN usermod -s /usr/bin/zsh root

COPY /entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]

CMD /usr/sbin/sshd -De
```

Then copy the `entrypoint.sh` from either `xv-utils` or `cdk-base` to `eks-hero` directory.

Add a new entry in the `xv.yaml` under "containers" similar to the following:

```yaml
...
containers:
  ...
  eks-hero:
    ports: []
    environment:
    - name: AWS_PROFILE
      value: profile_with_eks_cluster_access
    volumes: []
```

Save the file. To build and set `eks-hero` as the new `xv-container`, from the local computer run:

```console
xvcmd "sudo xv eks-hero"
```

After the command is complete, next time you connect into Xavier System, you will be using `eks-hero`. To switch back to `xv-utils` just repeat the command above replacing `eks-hero` to `xv-utils`.

## The "fake" aws script

It's a simple but very useful script installed into Xavier System's `root/bin/` directory that runs a `amazon/aws-cli` container, mounting the host `/root/.aws/` directory and setting the `AWS_PROFILE` environment from `xv-container` own environment. All the arguments are passed directly into the `docker run` command. For the user perception, it's like running the actual `aws` command.
This helps the user to save time writing **Dockerfiles**, since the only method available to install the version 2 of the AWS CLI is by manually downloading the installer and running it during the container build.

## Example sources

### xv-utils

For information on the `xv-utils` tool, read [Creating xv-containers using xv-utils](#creating-xv-containers-using-xv-utils).

### cdk-base

This source have all the necessary dependencies to develop and run AWS CDK projects using Python. The user don't need to use or configure Python's VirtualEnv here.

To create a new CDK project, create a GIT repository, clone it to the `/workspace/mycdkproject` directory, then run `cdk init --language python --generate-only` inside of it.

To use Pylint and Pylance recommendations, enable the official Python extension in Visual Studio code for the remote system (not local). Then add the following to the end of the Visual Studio Code `settings.json` if not there already:

```json
{
  ...existing code...,
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true
}
```

## Example script tools

### eks-kubeconfig.sh

This script is very similar to the "fake" aws script installed by default, but with the purpose to generate a `/root/.kube/config` file to use with `kubectl` to access an EKS cluster. The difference is the extra mounting of the `root/.kube` directory and the `eks update-kubeconfig --name` arguments. The user only needs to supply the name of the EKS cluster.
Example:

```console
eks-kubeconfig.sh my-eks-cluster
```

### get-kubectl.sh

This is an utility script that deals with the `kubectl` versioning issues. `kubectl` can only supports Kubernetes clusters with the same version, one earlier or one later. For example: `kubectl` for Kubernetes 1.21 can only support Kubernetes clusters from 1.20-1.22.

By passing a Kubernetes version to this script as argument, it will download the official `kubectl` binary from AWS for the correct system archtecture and install it on `/root/bin/` directory, replacing any version already there. Example:

```console
get-kubectl.sh 1.22
```

### update-eksctl.sh

This is a simple script that downloads the most recent version of the `eksctl` tool into the `/root/bin/` directory. Like the `get-kubectl.sh` script, it detects the system archtecture and download the proper binary. No arguments needed.

## Contributions and Issues

Please, if you want to contribute with the project, open an issue or submit a PR. Contributors are always welcome! :)

## License information

Copyright 2022 Eduardo Medeiros Silva.

Licensed under [GNU General Public License v3.0](./LICENSE).
