#!/bin/bash

cd ../tools

{
  sleep 1
  echo "halt; init; reset; halt; load_image /home/esc/csaw_esc_2016/tools/linux/vmlinux_de0; reg r3 0; reg npc 0x100; resume"
sleep 40
} | telnet localhost 4444
