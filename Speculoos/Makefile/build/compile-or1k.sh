#!/bin/bash

cd tools/

#Define environment
source set-or1k-env
echo | fusesoc init

#Make linux kernel
cd linux/
export ARCH=openrisc
export CROSS_COMPILE=or1k-linux-musl-
make distclean
make or1ksim_defconfig
make
mv vmlinux vmlinux_sim

#Clean previous files compilation
rm arch/openrisc/support/initramfs/*.elf
rm arch/openrisc/support/initramfs/*.sh

#Compile .c files
cd ../../
for filename in  build/src/*.c
do
  file=${filename%.*}
  echo "Compiling ${file##*/}"
  or1k-linux-musl-gcc -fno-stack-protector -z execstack build/src/${file##*/}.c -o tools/linux/arch/openrisc/support/initramfs/${file##*/}.elf
done

#Copy shell scripts
for file in build/src/*.sh
do
  cp build/src/${file##*/} tools/linux/arch/openrisc/support/initramfs/${file##*/}
done

#Finalize linux kernel
cd tools/linux/
make
mv vmlinux vmlinux_sim
