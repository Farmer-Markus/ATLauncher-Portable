#!/bin/bash

#Sets variables and functions#
##############################
scriptdir=$(cd $(dirname $0);pwd)
scriptname=$(basename "$0")
offset=auto
mountpoint="/tmp"
workdir=$scriptdir
workdiroption="--working-dir"
Begin_dwarfs_universal=`awk '/^#__Begin_dwarfs_universal__/ {print NR + 1; exit 0; }' "$scriptdir/$scriptname"`
End_dwarfs_universal=`awk '/^#__End_dwarfs_universal__/ {print NR - 1; exit 0; }' "$scriptdir/$scriptname"`

sh_mount () {
  if [ ! -e "$mountpoint/ATLauncher-Portable" ]
     then

         mkdir -p "$mountpoint/ATLauncher-Portable/mount-tools"
         mkdir -p "$mountpoint/ATLauncher-Portable/mnt" 
         awk "NR==$Begin_dwarfs_universal, NR==$End_dwarfs_universal" "$scriptdir/$scriptname" > "$mountpoint/ATLauncher-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64" && chmod a+x "$mountpoint/ATLauncher-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64"
         "$mountpoint/ATLauncher-Portable/mount-tools/dwarfs-universal-0.7.3-Linux-x86_64" --tool=dwarfs "$scriptdir/$scriptname" "$mountpoint/ATLauncher-Portable/mnt" -o offset=$offset
fi
}

sh_unmount () {
  umount "$mountpoint/ATLauncher-Portable/mnt"
  rm -r "$mountpoint/ATLauncher-Portable"
  rm "$workdir/runtimes/minecraft/java-runtime-gamma/linux/java-runtime-gamma"
  rm -rf "$workdir/runtimes"
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
  echo '--mountpoint=<string>                Defines the mount location for the dwarfs'
  echo '                                     image.(Default mountpoint: </tmp>)'
  echo ''
  echo '--install                            Moves the image into your .local/share'
  echo '                                     folder and creates an desktop entry'
  echo ''
  echo '--working-dir=<string>               This forces the working directory for the'
  echo '				     launcher.'
  echo ''
  echo '--audio=<string>                     Forces the audio driver for alsoft'
  echo '                                     (can be usefull against crashes using pipewire)'
  echo '-------------------------------------------------------------------------------'
  "$mountpoint/ATLauncher-Portable/mnt/java-runtime-17/bin/java" -jar "$mountpoint/ATLauncher-Portable/mnt/ATLauncher/ATLauncher.jar" --help | sed '/--working-dir/,+1 d' #removing the --working-dir option of the launcher help.(some issues with spaces in working-dir path)
  umount "$mountpoint/ATLauncher-Portable/mnt"
  rm -r "$mountpoint/ATLauncher-Portable"
  exit
}

sh_if_mounted () {
  if [ ! -e "$mountpoint/ATLauncher-Portable" ]
     then

         sh_mount
         echo -e "\033[1;32mImage mounted in "$mountpoint"\033[0;38m"
         exit

     else

         umount "$mountpoint/ATLauncher-Portable/mnt"
         rm -r "$mountpoint/ATLauncher-Portable"
         echo -e "\033[1;31mImage unmounted\033[0;38m"
         exit
fi
}

sh_internal_jar () {
  echo -e "\033[1;32mUsing internal jar\033[0;38m"
  mkdir -p "$workdir/runtimes/minecraft/java-runtime-gamma/linux"
  ln -s "$mountpoint/ATLauncher-Portable/mnt/java-runtime-17" "$workdir/runtimes/minecraft/java-runtime-gamma/linux/java-runtime-gamma"
  "$mountpoint/ATLauncher-Portable/mnt/java-runtime-17/bin/java" -jar "$mountpoint/ATLauncher-Portable/mnt/ATLauncher/ATLauncher.jar" --no-launcher-update $workdiroption "$workdir" "$atargs"
}

sh_external_jar () {

  if [ ! -e "$workdir/ATLauncher.jar" ]
     then

         cp "$mountpoint/ATLauncher-Portable/mnt/ATLauncher/ATLauncher.jar" "$workdir"
fi
  mkdir -p "$workdir/runtimes/minecraft/java-runtime-gamma/linux"
  ln -s "$mountpoint/ATLauncher-Portable/mnt/java-runtime-17" "$workdir/runtimes/minecraft/java-runtime-gamma/linux/java-runtime-gamma"
  "$mountpoint/ATLauncher-Portable/mnt/java-runtime-17/bin/java" -jar "$workdir/ATLauncher.jar" $workdiroption "$workdir" "$atargs"
}

sh_install () {
  if [ -e ~/.local/share/ATLauncher-Portable ]
     then

         echo -e "\033[1;31mFolder ATLauncher-Portable already exists in ~/.local/share\033[0;38m"
         if [ ! -e ~/.local/share/applications/atlauncher-portable.desktop ]; then sh_create_entry && echo -e "\033[1;32mFixed missing desktop entry\033[0;38m"; fi
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
         cp "$scriptdir/$scriptname" ~/.local/share/ATLauncher-Portable
         cp "$mountpoint/ATLauncher-Portable/mnt/install/ATLauncher.png" ~/.local/share/ATLauncher-Portable/
         if [ -e ~/.local/share/applications/atlauncher-portable.desktop ]; then rm ~/.local/share/applications/atlauncher-portable.desktop; fi
         echo -e "\033[1;32mCreating desktop entry...\033[0;38m"
         sh_create_entry
         echo -e "\033[1;32mDone\033[0;38m"
         sh_unmount
         echo -e "\033[1;32mFinished installing ATLauncher in ~/.local/share.\033[0;38m"
fi
}

sh_create_entry () {
  echo '[Desktop Entry]'								>> ~/.local/share/applications/atlauncher-portable.desktop
  echo 'Name=ATLauncher'								>> ~/.local/share/applications/atlauncher-portable.desktop
  echo 'Exec='$HOME'/.local/share/ATLauncher-Portable/ATLauncher-Portable.sh'		>> ~/.local/share/applications/atlauncher-portable.desktop
  echo 'Type=Application'								>> ~/.local/share/applications/atlauncher-portable.desktop
  echo 'Keywords=game;Minecraft;'							>> ~/.local/share/applications/atlauncher-portable.desktop
  echo 'Categories=Games;'								>> ~/.local/share/applications/atlauncher-portable.desktop
  echo 'Comment=A portable version of a launcher for Minecraft which integrates multiple different modpacks to allow you to download and install modpacks easily and quickly.'										>> ~/.local/share/applications/atlauncher-portable.desktop
  echo 'Comment[de]=Eine portable Version von einem Launcher für Minecraft, der es erlaubt Modpacks einfach und schnell herunterzuladen und zu installieren.'									>> ~/.local/share/applications/atlauncher-portable.desktop
  echo 'StartupNotify=true'								>> ~/.local/share/applications/atlauncher-portable.desktop
  echo 'Terminal=false'									>> ~/.local/share/applications/atlauncher-portable.desktop
  echo 'Icon='$HOME'/.local/share/ATLauncher-Portable/ATLauncher.png'			>> ~/.local/share/applications/atlauncher-portable.desktop
  echo 'Actions=alsa-driver;'								>> ~/.local/share/applications/atlauncher-portable.desktop
  echo ''										>> ~/.local/share/applications/atlauncher-portable.desktop
  echo '[Desktop Action alsa-driver]'							>> ~/.local/share/applications/atlauncher-portable.desktop
  echo 'Name=Use alsa audio driver'							>> ~/.local/share/applications/atlauncher-portable.desktop
  echo 'Name[de]=Alsa Audiotreiber benutzen'						>> ~/.local/share/applications/atlauncher-portable.desktop
  echo 'Exec='$HOME'/.local/share/ATLauncher-Portable/ATLauncher-Portable.sh --audio=alsa'	>> ~/.local/share/applications/atlauncher-portable.desktop
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
  rm -rf ~/.local/share/ATLauncher-Portable
  echo -e "\033[1;32mRemoving desktop entry...\033[0;38m"
  rm ~/.local/share/applications/atlauncher-portable.desktop
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
    --working-dir=*)
    workdir="${i#*=}"
    ;;
    --audio=*)
    audiodriver="${i#*=}"
    ;;
    --install)
    install=1
    ;;
    *)
    atargs="$atargs $i"
    ;;
esac
done

if [ "$help" == "1" ]; then sh_mount && sh_help; fi
if [ "$install" == "1" ]; then sh_install && exit; fi
if [ ! "$audiodriver" == "" ]; then export ALSOFT_DRIVERS="$audiodriver"; fi
if [[ "$internaljar" == "1" && "$mount" = "1" ]]; then echo -e "\033[1;31mCan't use this options together!\033[0;38m"; fi
if [[ "$internaljar" == "1" && "$mount" = "" ]]; then sh_mount && sh_internal_jar && sh_unmount; fi
if [[ "$internaljar" == "" && "$mount" = "" ]]; then sh_mount && sh_external_jar && sh_unmount; fi
if [[ "$internaljar" == "" && "$mount" = "1" ]]; then sh_if_mounted; fi


exit
#__Begin_dwarfs_universal__
