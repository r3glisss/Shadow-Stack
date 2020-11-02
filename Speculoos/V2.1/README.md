Speculoos installation guide (CSAW ESC 2016 Team Esisar)
========================================================

Here, we assume every tools needed to set up a working OpenRISC environment have already been installed.

In order to install the new core mor1kx-3.1 with the defense module Speculoos, we will firstly copy all the files from speculoos into /home/esc/csaw_esc_2016. Now, we have to set up a new core library for fusesoc with the modified core by replacing the fusesoc configuration file. We only have to execute from csaw_esc_2016 directory : 
```Shell
mv fusesoc.conf /home/esc/.config/fusesoc/fusesoc.conf

The next step is to build the Linux kernel in ELF format for the OpenRISC processor compatible with the de0_nano FPGA target. Just type :
```Shell
make compile-kernel

**Note that this command has compiled all the user programs present in build/src inside the kernel image.**

Then, we have to build the OpenRISC System on Chip for the de0_nano using the following command :
```Shell
make generate-bitstream

Now, we have to program the bitstream to the FPGA :
```Shell
make program-fpga

**Note that you can do the last 3 steps using `make all` or the last 2 steps using `make pgm-de0`**

Finally, we can connect to the SoC using three (3) terminal windows, as follows: 
-   In the first window, we run OpenOCD using `make run-openocd`; 
-   In the second window, we connect through telnet using `make connect-openocd` from csaw_esc_2016/tools. 
-   In the third terminal window, we run `sudo putty` and connect to `dev/ttyUSB0` using the serial connection type and `115200` speed (baud rate). 

To transfer the `vmlinux_de0` kernel image and boot Linux on the FPGA, we type 
```Shell
halt; init; reset; halt; load_image /home/esc/csaw_esc_2016/tools/linux/vmlinux_de0; reg r3 0; reg npc 0x100; resume

4 attacks have been compiled inside the linux kernel image
-string.elf (string format attack, first scanf activate printf vunerability)
-buffer.elf (buffer overflow)
-dos.elf (pointer hijacking, use 12 in argument)
-escalation.elf (run firstly right.sh, to give root privilege to escalation.elf and create a new user 'usr', then run the program using 13 as argument)

**Another solution can be found in the directory Speculoos_v2**
**Interrupts have been disabled**
