# Lichee Pi Nano Bootable Linux Image (Buildroot)

(This is forked from [this original repo](https://github.com/unframework/licheepi-nano-buildroot) with some documentation updates specific for my purposes.)

[Lichee Pi Nano](http://nano.lichee.pro/index.html) ([English article](https://www.cnx-software.com/2018/08/17/licheepi-nano-cheap-sd-card-sized-linux-board/)) is a very small single-board computer that is about the size of an SD card. It can run Linux. There is a good amount of official documentation on the [original manufacturer site](http://nano.lichee.pro/get_started/first_eye.html) (in Chinese, but easily readable thanks to Google Translate). However, the tooling used to build the full card/SPI-Flash images is mostly made up of custom shell scripts, and is not always easy to extend or maintain.

This repository contains a Buildroot config extension that allows all of those build steps to be handled via a single Buildroot `make` command. That means fully building the U-Boot image, Linux kernel, the rootfs image and the final partitioned binary image for flashing onto the bootable SD card (SPI-Flash support is possible but not handled here yet).

This heavily borrows from the work done by the FunKey Zero project: https://github.com/Squonk42/buildroot-licheepi-zero/. That repo targets Lichee Pi Zero, a sibling board to the Nano, but I was able to adapt it for use with the latter, and also converted the content to be a `BR2_EXTERNAL` extension rather than a full Buildroot fork.

There was reasonable effort to keep config files readable, e.g. here is the main Buildroot defconfig file: [configs/licheepi_nano_defconfig](configs/licheepi_nano_defconfig).

## Dependencies

- Vagrant (if building inside the VM)
  - vagrant-vbguest plugin
  - vagrant-disksize plugin
- Ubuntu Bionic or similar (see Vagrant VM)
- Buildroot 2020.02 (auto-downloaded by VM, otherwise see [project downloads page](https://buildroot.org/download.html))

Buildroot takes care of downloading any further dependencies automatically.

## Building the Image

If performing the build inside the VM:

```sh
vagrant up
vagrant ssh
```

Otherwise, download Buildroot and extract it into a folder.

Before building, install these Ubuntu packages:

```sh
sudo apt-get install swig python-dev fakeroot devscripts chrpath gawk texinfo libsdl1.2-dev whiptail diffstat cpio libssl-dev
```

Then, create initial build configuration:

```sh
# if not using VM, change /vagrant to location of this repo
BR2_EXTERNAL=/vagrant make licheepi_nano_defconfig
```

If the above fails, just copy over the `licheepi_nano_defconfig` file from this repo to the `configs` directory of buildroot, and run:

```sh
make ./configs/licheepi_nano_defconfig
```

Customize Buildroot configuration if needed:

```sh
make menuconfig
```

Proceed with the build:

```sh
make
```

The build may take 1.5 hours on a decent machine, or longer. For a faster build, try changing configuration to use external toolchain. I have tried building with Linaro GCC 7.5, but ran into crashes at time of `/sbin/init` invocation (issue with bundled glibc?).

A successful build will produce a `output/images` folder. That folder contains a `sdcard.img` file that can now be written to the bootable SD card. For example:

Note: the `post-image.sh` script contains the `genimage` call where you can change the output directory where the final image is written.

```sh
sudo dd if=output/images/sdcard.img of=DEVICE # e.g. /dev/sd?, etc
```

On Windows, Rufus or Balena Etcher can be used, or another utility like that.

## LCD Screen Support

This build includes a DTS file that supports a 480x272 TFT screen (plugged into the 40-pin flex-PCB connector on the board). The custom kernel branch also includes a DTS file with support for 800x480 TFT resolution: use `suniv-f1c100s-licheepi-nano` name for the DTS file, and update `boot.cmd` and `genimage.cfg` to reference that device tree as well.

## Setting up GPIO

If you want to use the GPIO pins (E0 - E12), the reference number of each pin is 128 plus the E-number. For example, `E7` would be 135. To work with a GPIO pin, such as E7, you would do the following:

```sh
echo "135" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio135/direction
echo "1" > /sys/class/gpio/gpio135/value
```

You can write values of "1" or "0" to make the pin high or low.

If you want to use the pin as an input, you would do:

```sh
echo "in" > /sys/class/gpio/gpio135/direction
cat /sys/class/gpio/gpio135/value
```

## Troubleshooting

### Working from Windows

If you checked out the repo in Windows, and are running Vagrant in a Windows environment, there may be problems with line endings (CRLF versus LF). The whole build might actually work, but then the boot process will fail because the `boot.cmd` file contains lines with incorrect line endings, which will cause u-boot to break.

You'll need to manually convert the line endings to unix (LF) in these files before proceeding.

### Rebuilding boot.scr

The `make` workflow does not automatically recreate `boot.scr` if changes are made to the `boot.cmd` file. To recreate it manually, try the following:

```sh
./output/build/uboot-nano-v2018.01/tools/mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n 'u-boot script' -d /vagrant/board/licheepi_nano/boot.cmd boot.scr
```

### Errors during make

* Running out of space (could not allocate ext2 blocks)

Just run `make menuconfig`, go to Filesystem images, and increase the "exact size" of the ext2 filesystem.

* Could not find `/board/licheepi_nano/...` files (i.e. `make` is trying to search from the root directory).

This indicates that the `BR2_EXTERNAL_LICHEEPI_NANO_PATH` environment variable isn't set. You can either set it, or, in a jam, you can just actually copy over the `/board/licheepi_nano` directory to the root.
