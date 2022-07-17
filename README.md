# xavier-system
A dynamic and automated development environment using an EC2 instance as backend

## Setup

- Create some helper functions in BASH, ZSH or PowerShell profiles.
- Powershell
  ```powershell
  # Powershell
  
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

- Apply the AWS Cloudformation stack in the `cfn` directory. Modify the default values to customize the setup.
  ```console
  $ aws cloudformation deploy --stack-name my-xavier-system --template-file stack-arm64.yaml --capabilities CAPABILITY_NAMED_IAM
  ```
- Get the Xavier instance ID to update the functions.
  ```console
  $ aws cloudformation describe-stacks --stack-name my-xavier-system --query "Stacks[0].Outputs[0].OutputValue"
  ```

- Use `xvssh` to access the instance shell through the `ssm-user`. Then access the Xavier System path `/opt/xavier/system`
  ```console
  $ xvssh
  $ sudo su -
  # cd /opt/xavier/system
  ```

- Setup Xavier System using the `xv-setup.sh` script. It will take some minutes to finish. Copy the `xv.example.yaml` file and the `examples/sources/xv-utils` directory into the `/opt/xavier/sources` directory:
  ```console
  # ./xv-setup.sh
  # cp xv.example.yaml ../sources/xv.yaml
  # cp -r examples/sources/xv-utils ../sources
  ```

- Finally, use `xv` to build and run the `xv-utils` container. Exit `xvssh` afterwards:
  ```console
  # xv xv-utils
  # exit
  $ exit
  ```

- Use `xvpf` to create a tunnel using SSM from port `2222` on the local OS to `2222` on the Xavier Instance:
  ```console
  $ xvpf 2222 2222
  ```

- Use `code` to access the `xv-utils` container:
  ```console
  code --remote ssh-remote+xavier /xavier
  ```

- `xv-utils` have access to all Xavier System files. It can be used to create/edit Dockerfiles, the `source/xv.yaml` file or to make tweaks on the Xavier System directory `system`.