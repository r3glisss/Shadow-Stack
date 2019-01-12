#!/bin/bash

cd ../tools
source set-or1k-env
echo | fusesoc init  
make run-openocd
