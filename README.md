# Hardware Shadow-Stack on open Processor

This work has been done for the CSAW 2016 in NYU.
Read our poster in this repository
Read our IEEE research paper : https://ieeexplore.ieee.org/document/8326545 

## Getting Started

This document aims to setup the environment in order to work and develop for this project.  To do so, several components and programs are necessary:

 - A Linux OS, with root/sudo privileges, for hosting the OpenRISC environment
 - The “fusesoc” package manager, to easily retrieve the OpenRISC system on chip HDL source code
 - The Linux kernel source code for running an OS over OpenRISC targets
 - The “or1k-sim” architectural simulator, which can run OpenRISC programs by emulating a complete OpenRISC system at the instruction level
 - C/C++ toolchains for cross-compiling baremetal and Linux programs to be able to run on an OpenRISC processor

To implement OpenRISC on an actual FPGA target, the following components are also needed:
-   The Altera Quartus Prime Lite Edition (free), to compile OpenRISC system on chip bitstream for FPGA targets (e.g., the DE0-nano);
-   The “openocd” on-chip debug interface program, to control the deployed target system.

## Installing Components

Here, we assume that the host OS is Ubuntu 16.04 LTS. First, we need to install pre-requisite packages:

 - Update and Install the following packages with the following commands on a Shell.
```bash
$ sudo apt-get update
$ sudo apt-get install git aria2 python-yaml libusb-dev libftdi-dev putty iverilog gtkwave
```
 - Download the ESC 2016 repository using:

```bash
$ git clone https://github.com/nekt/csaw_esc_2016.git
```
 - From within the “csaw_esc_2016/tools” directory, in order to download “fusesoc”, the Linux kernel source, “or1k-sim”, and the C/C++ toolchains (i.e., baremetal and linux compilers) type in the shell

```bash
$ make basic-tools-download
```
-	In order to download “openocd” and Quartus, type in the previous shell:
```bash
$ make fpga-tools-download
```
-	To setup all environmental variables, it is sufficient to type in shell within the “csaw_esc_2016/tools” directory:
```bash
$ source set-or1k-env
```
-	To download all OpenRISC sources, simply execute:
```bash
$ fusesoc init
```

## Building, Compiling and Simulating the Basic Core (Quick Start Guide)

Now that everything is installed we need to build the kernel in ELF format for the OpenRISC processor. We execute the following from within the “linux” directory, depending on the target platform (i.e., FPGA or or1k simulator):

-To build a kernel compatible with the **or1k simulator**, we type in the shell:

```bash
$ export ARCH=openrisc
$ export CROSS_COMPILE=or1k-linux-musl-
$ make distclean
$ make or1ksim_defconfig
$ make
$ mv vmlinux vmlinux_sim
```
- To build a kernel compatible with the **DE0-nano FPGA target**, we type in the shell:

```bash
$ export ARCH=openrisc
$ export CROSS_COMPILE=or1k-linux-musl-
$ make distclean
$ make de0_nano_defconfig
$ make
$ mv vmlinux vmlinux_de0
```

The compiled kernel image will be saved in the “vmlinux_***” file.
As an exemple we can compile a simple Hello World program and add it to the kernel, we can create a valid “helloworld.c” within the “linux” folder and then run in a shell:

```bash
$ or1k-linux-musl-gcc helloworld.c -o arch/openrisc/support/initramfs/hello.elf
$ make
```
followed by “mv vmlinux vmlinux_de0” or “mv vmlinux vmlinux_sim” depending on **current target configuration** (i.e., “or1ksim_defconfig” or “de0_nano_defconfig”).

To simulate the OpenRISC processor with Linux using “or1k-sim”, run the following from within the `csaw_esc_2016/tools` directory:
```bash
$ make simulate-linux
```
As soon as Linux boots, we can type commands such as “ls” and execute our Hello World program typing “./hello.elf” in the new terminal opened by “or1k-sim”.

To build the OpenRISC System on Chip for the DE0-nano, we type “make fpga-bitstream” from within the “csaw_esc_2016/tools” directory. To program the FPGA using Quartus, we type “make program-fpga”. To interface with the FPGA, we need a **3.3Volt** FTDI USB to TTL serial cable connected to the UART [pins of the board] (https://sites.google.com/site/fpgaandco/de0-nano-pinout) (default: pins 5 and 6 on port JP3).

To change the default pin assignment for UART, we need to edit “~/.local/share/orpsoc-cores/systems/de0_nano/data/pinmap.tcl” and re-generate the bitstream using “make fpga-bitstream”.

After programming the bitstream to the FPGA, we can connect to the SoC using three (3) terminal windows, as follows:
-	In the first window, we run OpenOCD using “make run-openocd”
-	In the second window, we connect through telnet using “make openocd-connect”
-	In the third terminal window, we run “sudo putty” and connect to “dev/ttyUSB0” using the serial connection type and “115200” speed (baud rate)

To transfer the “vmlinux_de0” kernel image and boot Linux on the FPGA, we type in the second terminal window (i.e., in the “telnet” prompt):

```bash
$ halt; init; reset; halt; load_image (_path_to_)/linux/vmlinux_de0; reg r3 0; reg npc 0x100; resume
```

## Buiding, Compiling and Simulating Speculoos

In order to install the new core mor1kx-3.1 with the defense module Speculoos, we will firstly copy all the files from speculoos into /home/esc/csaw_esc_2016. Now, we have to set up a new core library for fusesoc with the modified core by replacing the fusesoc configuration file. We only have to execute from csaw_esc_2016 directory, in a shell: 

```bash
$ mv fusesoc.conf /home/esc/.config/fusesoc/fusesoc.conf
```

The next step is to build the Linux kernel in ELF format for the OpenRISC processor compatible with the de0_nano FPGA target. Just type:

```bash
$ make compile-kernel
```

Note that this command has compiled all the user programs present in build/src inside the kernel image.

Then, we have to build the OpenRISC System on Chip for the de0_nano using the following command:

```bash
$ make generate-bitstream
```

Now, we have to program the bitstream to the FPGA:

```bash
$ make program-fpga
```

Note that you can do the last 3 steps using “make all” or the last 2 steps using “make pgm-de0”

Finally, we can connect to the SoC using three (3) terminal windows, as follows: 
-	In the first window, we run OpenOCD using “make run-openocd”
-	In the second window, we connect through telnet using “make connect-openocd” from csaw_esc_2016/tools.
-	In the third terminal window, we run “sudo putty” and connect to “dev/ttyUSB0” using the serial connection type and `115200` speed (baud rate).
 
To transfer the “vmlinux_de0” kernel image and boot Linux on the FPGA, we type in the second terminal window (i.e., in the “telnet” prompt):

```bash
$ halt; init; reset; halt; load_image /home/esc/csaw_esc_2016/tools/linux/vmlinux_de0; reg r3 0; reg npc 0x100; resume
```

4 attacks have been compiled inside the linux kernel image
-string.elf (string format attack, first scanf activate printf vunerability)
-buffer.elf (buffer overflow)
-dos.elf (pointer hijacking, use 12 in argument)
-escalation.elf (run firstly right.sh, to give root privilege to escalation.elf and create a new user “usr”, then run the program using 13 as argument)




