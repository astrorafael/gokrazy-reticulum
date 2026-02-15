# gokrazy-reticulum
Recipe to install Reticulum Network Stack oon a Raspberry Pi Zero 2 W

This repo is only a [Just](https://just.systems/man/en/) recipe to install the [Reticulum Network Stack](https://reticulum.network/) on a [Raspberry Pi Zero 2 W](https://www.raspberrypi.com/products/raspberry-pi-zero-2-w/).

There isn an excelent video on how to [Build a Small Reticulum Meshchat Node with Raspberry Pi Zero 2W and RAK 4631 including WiFi Hotspot.](https://youtu.be/T1itQcdf5cc?si=qkncRQCppQkjlbGT)

However, the Raspberry Pi Zero 2 W setup was very involved itself. Takes ages to flash, to boot and feels slugish at the cpommadn prompt. . Then I stumbled upon the amazing [Gokrazy Project](https://gokrazy.org/) which sets up the minimal Linux OS you ever need: just a kernel, few more processes and your Go application.

All I had to do was to find a Go-implemented Reticulum Transport Stack equivalent to the Python reference implementation.

Fortunately, I found a couple of GitHub repositores. I chose [this GitHub repo](https://github.com/svanichkin/go-reticulum) and by trial and error I setup a Just recipe to automate the flashing process.

# Instalation

The first thing to do is to install the [Go Programming language](https://go.dev/). Do not forget to add these three lines in your `.bashrc` file

```bash
export GOROOT="/usr/local/go"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
```

Also you must install [Just](https://just.systems/man/en/)

Download this repo ced into it and you are ready.

## Steps
1. Install `GoKrazy`

```bash
just gokrazy
```
2. Create a GoKrazy instance image (your node)

Create an instance named `myreticulum` which will connect to your WiFi router with SSID `XYD` and password `foo`
```bash
just base myreticulum XYD foo
```

3. Add the Go-Reticulum daemon rnsd and a few utilities

```bash
just reticulum myreticulum
```

4. Flash the whole image to an SD Card

Suppose that your fresh and unmounted SD card resides on `/dev/sdc`

```bash
just flash myreticulum
```
And that's it. Now you are ready to insert your SD card on your Raspberry Pi Zero and boot.

Find out what is the IP address assigned by your router (i.e. 192.168.1.39).

There is no OpenSSH setup. The forst access is through a Web Browser to
```bash
http://gokrazy:<http password>@192.168.1.39)
```