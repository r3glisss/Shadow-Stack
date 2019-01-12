SHELL:=/bin/bash
	
all: compile-kernel generate-bitstream program-fpga

pgm-de0: generate-bitstream program-fpga

compile-kernel:
	build/compile-kernel.sh

generate-bitstream:
	build/generate-bitstream.sh

program-fpga:
	build/program-fpga.sh

run-openocd:
	build/run-openocd.sh


