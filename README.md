roborio-python
==============

This repository holds builds of Python for the RoboRIO, and associated build
scripts. You don't need to build this yourself, instead use the robotpy-installer
and execute `robotpy-installer download-python` to download them.

Build process
-------------

Compiling this can eat up most of your RoboRIO's disk space, so you'll probably
want to reimage it before using the RoboRIO in a competition.

There are several non-automated steps:

* You must execute this build from a Linux environment
* Make a USB flash drive to be swap
  * Use `cfdisk` to partition your USB drive
  * Use `mkswap` to initialize the space
  * Mount it on the roborio via `swapon`
* Make another USB flash drive to be extra storage space
  * Use `cfdisk` to partition as linux partition
  * Use `mkfs.ext2` to format it
  * Plug it into the roborio and you should see it at /media/sda1
  * Run the following to redirect the install folders to your drive:

```
mkdir /media/sda1/bin
mkdir /media/sda1/include
mkdir /media/sda1/lib

ln -s /media/sda1/bin /usr/local/bin
ln -s /media/sda1/include /usr/local/include
ln -s /media/sda1/lib /usr/local/lib
```

Once your RoboRIO is sufficiently mangled, execute this from your host:

    make ROBORIO=roborio-XXXX-frc.local all

Building on a first generation RoboRIO takes about half a day.
