#!/bin/bash
wget https://github.com/mhx/dwarfs/releases/download/v0.7.3/dwarfs-universal-0.7.3-Linux-x86_64 && chmod a+x dwarfs-universal-0.7.3-Linux-x86_64
wget -P dwarfs/ATLauncher/ https://atlauncher.com/download/jar
mv dwarfs/ATLauncher/jar dwarfs/ATLauncher/ATLauncher.jar
./dwarfs-universal-0.7.3-Linux-x86_64 --tool=mkdwarfs -i dwarfs -o dwarfs.dwarfs
cat script.sh dwarfs-universal-0.7.3-Linux-x86_64 1 dwarfs.dwarfs > ATLauncher-Portable.sh && chmod a+x ATLauncher-Portable.sh
