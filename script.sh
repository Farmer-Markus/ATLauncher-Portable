#!/bin/bash

#Sets variables and functions#
##############################
scriptdir=$(cd $(dirname $0);pwd)
scriptname=$(basename "$0")
offset=auto
mountpoint="/tmp"
athome=$scriptdir
Begin_dwarfs_universal=`awk '/^#__Begin_dwarfs_universal__/ {print NR + 1; exit 0; }' $scriptdir/$scriptname`
End_dwarfs_universal=`awk '/^#__End_dwarfs_universal__/ {print NR - 1; exit 0; }' $scriptdir/$scriptname`

sh_mount () {
  mkdir -p $mountpoint/ATLauncher-Portable/mount-tools
  mkdir -p $mountpoint/ATLauncher-Portable/mnt
  if [ "$mounted" == "" ]
     then

         awk "NR==$Begin_dwarfs_universal, NR==$End_dwarfs_universal" $scriptdir/$scriptname > $mountpoint/ATLauncher-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64 && chmod a+x $mountpoint/ATLauncher-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64
         $mountpoint/ATLauncher-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64 --tool=dwarfs $scriptdir/$scriptname $mountpoint/ATLauncher-Portable/mnt -o offset=$offset
fi
}

sh_unmount () {
  umount $mountpoint/ATLauncher-Portable/mnt
  rm -r $mountpoint/ATLauncher-Portable
  rm -f $scriptdir/runtimes/minecraft/java-runtime-gamma/linux/java-runtime-gamma
}

sh_help () {
  echo 'sh Options                           Description'
  echo '----------                           -----------'
  echo '--use-internal-jar                   Uses internal ATLauncher.jar'
  echo '                                     (you need to recompile sh for Updates)'
  echo ''
  echo '--mount                              Mounts the dwarfs filesystem in '$mountpoint''
  echo '                                     (can be used with <--mountpoint>)'
  echo ''
  echo '--mountpoint=<path>                  Defines the mount location for the dwarfs'
  echo '                                     image.(Default mountpoint: </tmp>)'
  echo ''
  $mountpoint/ATLauncher-Portable/mnt/java-runtime-17/bin/java -jar $mountpoint/ATLauncher-Portable/mnt/ATLauncher/ATLauncher.jar --help
  umount $mountpoint/ATLauncher-Portable/mnt
  rm -r $mountpoint/ATLauncher-Portable
  exit
}

sh_if_mounted () {
  if [ ! -e $mountpoint/ATLauncher-Portable ]
     then

         sh_mount
         echo -e "\033[1;32mImage mounted\033[0;38m"
         exit

     else

         umount $mountpoint/ATLauncher-Portable/mnt
         rm -r $mountpoint/ATLauncher-Portable
         echo -e "\033[1;31mImage unmounted\033[0;38m"
         exit
fi
}

sh_internal_jar () {
  echo -e "\033[1;32mUsing internal jar\033[0;38m"
  $mountpoint/ATLauncher-Portable/mnt/java-runtime-17/bin/java -jar $mountpoint/ATLauncher-Portable/mnt/ATLauncher/ATLauncher.jar --working-dir $athome --no-launcher-update $atargs
}

sh_external_jar () {
  if [ ! -e $scriptdir/ATLauncher.jar ]
     then

         cp $mountpoint/ATLauncher-Portable/mnt/ATLauncher/ATLauncher.jar $scriptdir
fi
  $mountpoint/ATLauncher-Portable/mnt/java-runtime-17/bin/java -jar $scriptdir/ATLauncher.jar $atargs
}

for i in "$@"
do
case $i in
    -?|--h|--help)
    sh_mount && sh_help
    ;;
    --mount)
    mount=1
    ;;
    --use-internal-jar)
    internaljar=1
    ;;
    --mountpoint=*)
    mountpoint="${i#*=}"
    ;;
    *)
    #atargs=$1
    ;;
esac
done
#Scriptstart#
#############
if [[ "$internaljar" == "1" && "$mount" = "1" ]]; then echo -e "\033[1;31mCan't use this options together!\033[0;38m"; fi
if [[ "$internaljar" == "1" && "$mount" = "" ]]; then sh_mount && sh_internal_jar && sh_unmount; fi
if [[ "$internaljar" == "" && "$mount" = "" ]]; then sh_mount && sh_external_jar && sh_unmount; fi
if [[ "$internaljar" == "" && "$mount" = "1" ]]; then sh_if_mounted; fi

exit
#__Begin_dwarfs_universal__
