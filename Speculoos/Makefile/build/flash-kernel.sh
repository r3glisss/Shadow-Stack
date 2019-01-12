#!/bin/bash

cd build/

gnome-terminal -e 'bash -c "
./termA.sh"'

sleep 2

gnome-terminal -x bash -c './termB.sh;exec bash'

gnome-terminal -e 'bash -c "
./termC.sh"'
