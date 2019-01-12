#!/bin/bash

cd tools/
source set-or1k-env
echo | fusesoc init
make fpga-bitstream
