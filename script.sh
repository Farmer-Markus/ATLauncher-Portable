#!/bin/bash

#offset: Die Stelle, an der die dwarfs Datei anfängt(in bytes). script.sh+dwarfs-universal-0.7.3-Linux-x86_64+1+atlauncher.tar.gz+2=offset
scriptname=$(basename "$0")
scriptdir=$(cd $(dirname $0);pwd)
mountpoint="/tmp"
offset=auto
if [ -e $mountpoint/ATLauncher-Portable ]
   then

       mounted=1

   else

       mounted=0
fi
Begin_dwarfs_universal=`awk '/^#__Begin_dwarfs_universal__/ {print NR + 1; exit 0; }' $scriptdir/$scriptname`
End_dwarfs_universal=`awk '/^#__End_dwarfs_universal__/ {print NR - 1; exit 0; }' $scriptdir/$scriptname`

mkdir -p $mountpoint/ATLauncher-Portable/mount-tools
mkdir -p $mountpoint/ATLauncher-Portable/mnt

if [ "$mounted" == "0" ]
   then

       awk "NR==$Begin_dwarfs_universal, NR==$End_dwarfs_universal" $scriptdir/$scriptname > /tmp/ATLauncher-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64 && chmod a+x /tmp/ATLauncher-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64
       $mountpoint/ATLauncher-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64 --tool=dwarfs $scriptdir/$scriptname $mountpoint/ATLauncher-Portable/mnt -o offset=$offset
fi

if [ "$1" == "--help" ]
   then

       echo 'sh Options                           Description'
       echo '----------                           -----------'
       echo '--use-internal-jar                   Uses internal ATLauncher.jar'
       echo '                                     (you need to recompile sh for Updates,'
       echo '                                     need to be used as first option!)'
       echo ''
       echo '--mount                              Mounts the dwarfs filesystem in'
       echo '                                     '$mountpoint''
       echo ''

       $mountpoint/ATLauncher-Portable/mnt/java-runtime-17/bin/java -jar /tmp/ATLauncher-Portable/mnt/ATLauncher/ATLauncher.jar $1

       umount /tmp/ATLauncher-Portable/mnt
       rm -r /tmp/ATLauncher-Portable
       exit
fi

if [ "$1" == "--mount" ]
   then

       if [ "$mounted" == "0" ]
          then

              echo -e "\033[1;32mImage mounted\033[0;38m"
              exit

          else

              umount /tmp/ATLauncher-Portable/mnt
              rm -r /tmp/ATLauncher-Portable
              echo -e "\033[1;31mImage unmounted\033[0;38m"
              exit
fi
fi

mkdir -p $scriptdir/runtimes/minecraft/java-runtime-gamma/linux/
ln -s $mountpoint/ATLauncher-Portable/mnt/java-runtime-17/ $scriptdir/runtimes/minecraft/java-runtime-gamma/linux/java-runtime-gamma

if [ "$1" == "--use-internal-jar" ]
   then

       echo -e "\033[1;32mUsing internal jar\033[0;38m"
       $mountpoint/ATLauncher-Portable/mnt/java-runtime-17/bin/java -jar /tmp/ATLauncher-Portable/mnt/ATLauncher/ATLauncher.jar $2 --working-dir $scriptdir --no-launcher-update

   else

       if [ ! -e $scriptdir/ATLauncher.jar ]
          then

              cp /tmp/ATLauncher-Portable/mnt/ATLauncher/ATLauncher.jar $scriptdir
fi

       $mountpoint/ATLauncher-Portable/mnt/java-runtime-17/bin/java -jar $scriptdir/ATLauncher.jar $1
fi

umount /tmp/ATLauncher-Portable/mnt
rm -r /tmp/ATLauncher-Portable
rm -f $scriptdir/runtimes/minecraft/java-runtime-gamma/linux/java-runtime-gamma

exit
#__Begin_dwarfs_universal__
