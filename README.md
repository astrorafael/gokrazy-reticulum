# gokrazy-reticulum

Recipe to install Reticulum Network Stack oon a Raspberry Pi Zero 2 W

There isn an excelent video on how to [Build a Small Reticulum Meshchat Node with Raspberry Pi Zero 2W and RAK 4631 including WiFi Hotspot.](https://youtu.be/T1itQcdf5cc?si=qkncRQCppQkjlbGT)

However, the Raspberry Pi Zero 2 W setup was very involved itself. Takes ages to flash and boot. Also feels the command prompt feels sluggish. Then I stumbled upon the amazing [Gokrazy Project](https://gokrazy.org/) which sets up a custom Linux image which is the minimun you can have, the kernel, the init process, a few more essential processes and your Go application.

All I had to do was to find a Go-implemented Reticulum Transport Stack equivalent to the Python reference implementation.

Fortunately, I found a couple of GitHub repositores. I chose [this GitHub repo](https://github.com/svanichkin/go-reticulum) and by trial and error I setup Just recipes to automate the whole process.

This repo is only a [Just](https://just.systems/man/en/) recipe to install the [Reticulum Network Stack](https://reticulum.network/) on a [Raspberry Pi Zero 2 W](https://www.raspberrypi.com/products/raspberry-pi-zero-2-w/).

Even if you don't use it, the configuration process described as Just recipes is available for reference.

After a succesful configuration, you will certainly notice:

* how quick the flashing process is. 
* how quick the boot process is. 
* how light this custom Linux instance is.

# Instalation

## Prerequisites

Befor even executing the recipes, the first thing to do is to install the [Go Programming language](https://go.dev/) in your desktop computer. Do not forget to add these three lines in your `.bashrc` file

```bash
export GOROOT="/usr/local/go"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
```

Also you must install [Just](https://just.systems/man/en/)

Download this repo, `cd` into it and you are ready to go.

## Steps
1. Install `GoKrazy`

```bash
just gokrazy
```
2. Create a GoKrazy instance image (your node)

Create an instance named `myreticulum` which will connect to your WiFi router with SSID `XYD` and password `foo`. Before executing this command, make sure that your id_rsa.pub is avaliable on yoir `.ssh/` directory so that yo can log-in later on.

```bash
just base myreticulum XYD foo
```

After executing this step, even if no Reticulum software is added, the instance can be booted and the software can be added later on. The base instance contains a mkfs utility so that the `/perm` partition is formatted with ext4 filesystem the first time it is booted. The `/perm` partition is the only partition where permanent files like configurations files or data can be stored.

3. Add the Go-Reticulum daemon rnsd and a few utilities

```bash
just reticulum myreticulum
```

Just before the next step, you can hava a look at the `$HOME/gokrazy/myreticulum/config.son` file and edit the HTTPPassword if you like to sometthin easier to remember (`hello` in the example below). **The first login must be done via a Web browser**.

The config file should look something like

```json
{
    "Hostname": "myreticulum",
    "Update": {
        "HTTPPassword": "hello"
    },
    "Environment": [
        "GOOS=linux",
        "GOARCH=arm64",
        "GOKRAZY_RPI=model-zero-2-w"
    ],
    "Packages": [
        "github.com/gokrazy/fbstatus",
        "github.com/gokrazy/hello",
        "github.com/gokrazy/serial-busybox",
        "github.com/gokrazy/breakglass",
        "github.com/gokrazy/wifi",
        "github.com/gokrazy/mkfs",
        "github.com/svanichkin/go-reticulum/cmd/rnsd",
        "github.com/svanichkin/go-reticulum/cmd/rnx",
        "github.com/svanichkin/go-reticulum/cmd/rnpath",
        "github.com/svanichkin/go-reticulum/cmd/rncp",
        "github.com/svanichkin/go-reticulum/cmd/rnir"
    ],
    "PackageConfig": {
    "github.com/svanichkin/go-reticulum/cmd/rnir": {
        "CommandLineFlags": [
            "-config=/perm/.reticulum"
        ]
    },
        "github.com/gokrazy/breakglass": {
            "ExtraFilePaths": {
                "/etc/breakglass.authorized_keys": "breakglass.authorized_keys"
            },
            "CommandLineFlags": [
                "-authorized_keys=/etc/breakglass.authorized_keys"
            ]
        },
        "github.com/gokrazy/gokrazy/cmd/randomd": {
            "ExtraFileContents": {
                "/etc/machine-id": "4278aca91a2242498219bb60dcab254f\n"
            }
        },
        "github.com/gokrazy/wifi": {
            "ExtraFilePaths": {
                "/etc/wifi.json": "wifi.json"
            }
        },
        "github.com/svanichkin/go-reticulum/cmd/rncp": {
            "CommandLineFlags": [
                "-config=/perm/.reticulum"
            ]
        },
        "github.com/svanichkin/go-reticulum/cmd/rnpath": {
            "CommandLineFlags": [
                "-config=/perm/.reticulum"
            ]
        },
        "github.com/svanichkin/go-reticulum/cmd/rnsd": {
            "CommandLineFlags": [
                "-config=/perm/.reticulum"
            ]
        },
        "github.com/svanichkin/go-reticulum/cmd/rnx": {
            "CommandLineFlags": [
                "-config=/perm/.reticulum"
            ]
        }
    },
    "SerialConsole": "disabled",
    "InternalCompatibilityFlags": {}
}

```


4. Flash the whole image to an SD Card

Suppose that your fresh and unmounted SD card resides on `/dev/sdc`

```bash
just flash myreticulum
```
And that's it. Now you are ready to insert your SD card on your Raspberry Pi Zero and boot.

Find out what is the IP address assigned by your router (i.e. 192.168.1.39).

5. Web Browser log-in

There is no OpenSSH daemnon. `breakglass`, the Go SSH drop-in is installed but it is not launched. The first access must be done through a Web Browser:
```bash
http://gokrazy:hello@192.168.1.39
```

The maing page shows a list of "services" available. Click on the `breakglass` "service" and on the next page, click on the upper right button to launch it. Now you are ready to log in via ordinary ssh.

6. SSH Log-in

After `breakglass` is succesfully launced you can try and access from your desktop computer using ssh:

```bash
ssh root@192.168.1.39
```
 
 The shell and a couple of hundred Linux utilities are avaliable thanks to `busybox`.
