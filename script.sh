#!/bin/bash

#Sets variables and functions#
##############################
scriptdir=$(cd $(dirname $0);pwd)
scriptname=$(basename "$0")
offset=auto
mountpoint="/tmp"
workdir=$scriptdir
Begin_dwarfs_universal=`awk '/^#__Begin_dwarfs_universal__/ {print NR + 1; exit 0; }' $scriptdir/$scriptname`
End_dwarfs_universal=`awk '/^#__End_dwarfs_universal__/ {print NR - 1; exit 0; }' $scriptdir/$scriptname`

sh_mount () {
  if [ ! -e "$mountpoint/ATLauncher-Portable" ]
     then

         mkdir -p $mountpoint/ATLauncher-Portable/mount-tools
         mkdir -p $mountpoint/ATLauncher-Portable/mnt 
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
  echo '--install                            Moves the image into your .local/share'
  echo '                                     folder and creates an desktop entry'
  echo '-------------------------------------------------------------------------------'
  $mountpoint/ATLauncher-Portable/mnt/java-runtime-17/bin/java -jar $mountpoint/ATLauncher-Portable/mnt/ATLauncher/ATLauncher.jar --help
  umount $mountpoint/ATLauncher-Portable/mnt
  rm -r $mountpoint/ATLauncher-Portable
  exit
}

sh_if_mounted () {
  if [ ! -e $mountpoint/ATLauncher-Portable ]
     then

         sh_mount
         echo -e "\033[1;32mImage mounted in $mountpoint\033[0;38m"
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
  mkdir -p $scriptdir/runtimes/minecraft/java-runtime-gamma/linux
  ln -s $mountpoint/ATLauncher-Portable/mnt/java-runtime-17 $scriptdir/runtimes/minecraft/java-runtime-gamma/linux/java-runtime-gamma
  $mountpoint/ATLauncher-Portable/mnt/java-runtime-17/bin/java -jar $mountpoint/ATLauncher-Portable/mnt/ATLauncher/ATLauncher.jar --no-launcher-update $workdir $atargs 
}

sh_external_jar () {
  if [ ! -e $scriptdir/ATLauncher.jar ]
     then

         cp $mountpoint/ATLauncher-Portable/mnt/ATLauncher/ATLauncher.jar $scriptdir
fi
  mkdir -p $scriptdir/runtimes/minecraft/java-runtime-gamma/linux
  ln -s $mountpoint/ATLauncher-Portable/mnt/java-runtime-17 $scriptdir/runtimes/minecraft/java-runtime-gamma/linux/java-runtime-gamma
  $mountpoint/ATLauncher-Portable/mnt/java-runtime-17/bin/java -jar $scriptdir/ATLauncher.jar $atargs
}

sh_install () {
  if [ -e ~/.local/share/ATLauncher-Portable ]
     then

         echo -e "\033[1;31mFolder RTTR-Portable already exists in ~/.local/share\033[0;38m"
         if [ ! -e ~/.local/share/applications/ATLauncher.desktop ]; then sh_create_entry && echo -e "\033[1;32mFixed missing desktop entry\033[0;38m"; fi
         echo -e "\033[1;31mCan't install in ~/.local/share\033[0;38m"
         echo -e "\033[1;31mAlready installed\033[0;38m"
         echo -e "\033[1;31mWould you like to uninstall? All data will be removed![Y/n]\033[0;38m"
         read input
         case $input in
             y|yes)
             sh_uninstall
             ;;
             n|no)
             echo -e "\033[1;31mAborting\033[0;38m"
             ;;
             *)
             echo -e "\033[1;31mAborting\033[0;38m"
             ;;
         esac
         exit

     else

         echo -e "\033[1;32mInstalling ATLauncher in ~/.local/share...\033[0;38m"
         sh_mount
         mkdir -p ~/.local/share/ATLauncher-Portable
         cp $scriptdir/$scriptname ~/.local/share/ATLauncher-Portable
         cp  $mountpoint/ATLauncher-Portable/mnt/install/ATLauncher.png ~/.local/share/ATLauncher-Portable/
         if [ -e ~/.local/share/applications/atlauncher.desktop ]; then rm ~/.local/share/applications/atlauncher.desktop; fi
         echo -e "\033[1;32mCreating desktop entry...\033[0;38m"
         sh_create_entry
         echo -e "\033[1;32mDone\033[0;38m"
         sh_unmount
         echo -e "\033[1;32mFinished installing RTTR in ~/.local/share...\033[0;38m"
fi
}

sh_create_entry () {
  echo '[Desktop Entry]'							   	 >> ~/.local/share/applications/atlauncher.desktop
  echo 'Name=ATLauncher'							   	 >> ~/.local/share/applications/atlauncher.desktop
  echo 'Exec='$HOME'/.local/share/ATLauncher-Portable/ATLauncher-Portable.sh' 	         >> ~/.local/share/applications/atlauncher.desktop
  echo 'Type=Application'							   	 >> ~/.local/share/applications/atlauncher.desktop
  echo 'Keywords=game;Minecraft;'							 >> ~/.local/share/applications/atlauncher.desktop
  echo 'Categories=Games;'						 		 >> ~/.local/share/applications/atlauncher.desktop
  echo 'Comment=A launcher for Minecraft which integrates multiple different modpacks to allow you to download and install modpacks easily and quickly.'     	  								 >> ~/.local/share/applications/atlauncher.desktop
  echo 'StartupNotify=true'								 >> ~/.local/share/applications/atlauncher.desktop
  echo 'Terminal=false'									 >> ~/.local/share/applications/atlauncher.desktop
  echo 'Icon='$HOME'/.local/share/ATLauncher-Portable/ATLauncher.png'			 >> ~/.local/share/applications/atlauncher.desktop
}

sh_uninstall () {
  echo -e "\033[1;32mUninstalling ATLauncher in ~/.local/share...\033[0;38m"
  echo -e "\033[1;31mAll data will be removed in\033[0;38m"
  sleep 1s
  echo -e "\033[1;31m3		Press ctrg+c to abort\033[0;38m"
  sleep 1s
  echo -e "\033[1;31m2		Press ctrg+c to abort\033[0;38m"
  sleep 1s
  echo -e "\033[1;31m1		Press ctrg+c to abort\033[0;38m"
  sleep 1s
  
  echo -e "\033[1;32mRemoving data...\033[0;38m"
  rm -r ~/.local/share/ATLauncher-Portable
  echo -e "\033[1;32mRemoving desktop entry...\033[0;38m"
  rm ~/.local/share/applications/atlauncher.desktop
  echo -e "\033[1;32mFully uninstalled ATLauncher in ~/.local/share\033[0;38m"
}
#Scriptstart#
#############
for i in "$@"
do
case $i in
    -?|--h|--help)
    help=1
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
    --install)
    install=1
    ;;
    *)
    atargs="$atargs $i"
    ;;
esac
done

if [ ! "$(echo $atargs | grep "working-dir")" == "" ]; then workdir=""; else workdir="--working-dir $workdir" ; fi
if [ "$help" == "1" ]; then sh_mount && sh_help; fi
if [ "$install" == "1" ]; then sh_install && exit; fi
if [[ "$internaljar" == "1" && "$mount" = "1" ]]; then echo -e "\033[1;31mCan't use this options together!\033[0;38m"; fi
if [[ "$internaljar" == "1" && "$mount" = "" ]]; then sh_mount && sh_internal_jar && sh_unmount; fi
if [[ "$internaljar" == "" && "$mount" = "" ]]; then sh_mount && sh_external_jar && sh_unmount; fi
if [[ "$internaljar" == "" && "$mount" = "1" ]]; then sh_if_mounted; fi


exit
#__Begin_dwarfs_universal__
