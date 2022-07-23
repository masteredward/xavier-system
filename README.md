# Xavier System Project

The Xavier System is a remote containerized development environment, which uses [Visual Studio Code](https://code.visualstudio.com), the [Remote - SSH](https://code.visualstudio.com/docs/remote/ssh) extension and an [AWS EC2](https://aws.amazon.com/aws/ec2) instance as backend.

By taking advantage of Visual Studio Code features like SSH Agent forwarding and Environment Variable Inheritance, it's possible to have a fully remote development enviromnent with the same benefits and ease of use as developing locally.

The Xavier System is a "micro framework", which allows the user to manage a dynamic containerized environment to accomodate multiple projects in the same instance. The `xv` utility can mutate the whole development environment with a single command, using [Docker](https://www.docker.com) to build and deploy containers.

Using Xavier System, the user can keep it's PC clean from resource demainding systems like Docker Desktop, Virtual Machines or WSL systems. All that the user needs, is Visual Studio Code, the [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) utility, some custom shell functions and a [Nerd Font](https://github.com/ryanoasis/nerd-fonts) for the [Oh My ZSH](https://ohmyz.sh/) framework.

The default installation of the Xavier System bundles the Oh My ZSH framework with the [Powerlevel10k](https://github.com/romkatv/powerlevel10k) ZSH theme maintained by [Roman Perepelitsa](https://github.com/romkatv). The installation can be customized by creating the configuration file `xv-setup.yaml` file, modifying the bundled `xv-setup.example.yaml` file.

The installation customization allows the user to choose different Oh My ZSH plugins and themes, builtin or custom. Also, allows the user to avoid Oh My ZSH entirelly. It's installation uses the `xv-setup` container tool, which uses [Ansible](https://www.ansible.com) playbooks for both setup and updates.

The `xv` utility uses a custom configuration file called `xv.yaml` to configure container mounts, enviroments, ports and image building, similar to a [Docker Compose](https://docs.docker.com/compose) file. The advantage of `xv.yaml` is the shared configuration, with allows the user to set common mounts, environments or ports to all containers managed by `xv`.

To automate the environment creation, the user can customize one of the bundled [AWS CloudFormation](https://aws.amazon.com/cloudformation) templates in the `cfn` directory, available for AMD64 or ARM64 architetures.

## Local Setup

1. [Install Visual Studio Code](https://code.visualstudio.com/Download) in your PC. Installation can be either "User" or "System". Use which suits you best.

2. Install any of the [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) available. I suggest the patched version of [Inconsolata](https://en.wikipedia.org/wiki/Inconsolata), which can be downloaded for Windows [here](https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Inconsolata/complete/Inconsolata%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible.otf) or MacOS/Linux [here](https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Inconsolata/complete/Inconsolata%20Nerd%20Font%20Complete%20Mono.otf)

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

7. Install and configure the AWS CLI v2 utility. It will allow you to deploy and to connect to your EC2 instance. Follow the documentation [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). Use `aws sts get-caller-identity` command to test the AWS CLI v2 installation and configuration

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

## Xavier System Deployment

1. Create an **AWS Cloudformation** stack by modifying one of the templates in the `cfn` directory. *Modify the default values* to customize the setup. The `stack-arm64.yaml` deploys a Graviton2 ARM64 `t4g.medium` Instance by default. The `stack-amd64.yaml` deploys an AMD x86 `t3a.medium` Instance by default. ARM instances are *slighty cheaper and faster* than it's x86 counterparts. I suggest you to use ARM instead of x86, unless your're using applications and packages that are unavailable for ARM.

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

9. The `xv-utils` container have access to all **Xavier System** files. It can be used to *create/edit Dockerfiles*, the `source/xv.yaml` file or to make tweaks on the Xavier System directory `system`. For more information on `xv-utils`, go to [XV Utils]().

10. If you installed Xavier System with **Oh My ZSH** and the **Powerlevel10k** theme, run the `p10k configure` utility from **Visual Studio Code** *Integrated Terminal* to customize the theme.

11. Go to the `/xavier/sources` directory and start designing your containers! Time for some fun! For more information, keep reading.

## XV Utils
