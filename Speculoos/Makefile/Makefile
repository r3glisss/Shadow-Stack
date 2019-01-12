SHELL:=/bin/bash
	
all: compile-kernel generate-bitstream program-fpga flash-kernel

compile-kernel:
	build/compile-kernel.sh

compile-or1k:
	build/compile-or1k.sh

generate-bitstream:
	build/generate-bitstream.sh

program-fpga:
	build/program-fpga.sh

flash-kernel:
	build/flash-kernel.sh

start-or1k:
	build/start-or1k.sh

pgm-de0: program-fpga flash-kernel
