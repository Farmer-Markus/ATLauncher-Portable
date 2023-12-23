#!/bin/bash
Begin_squashfusetools_tar=`awk '/^#__Begin_squashfusetools_tar__/ {print NR + 1; exit 0; }' $0` #finds line number
End_squashfusetools_tar=`awk '/^#__End_squashfusetools_tar__/ {print NR - 1; exit 0; }' $0`

Begin_java_runtime=`awk '/^#__Begin_java_runtime__/ {print NR + 1; exit 0; }' $0`
End_java_runtime=`awk '/^#__End_java_runtime__/ {print NR - 1; exit 0; }' $0`

awk "NR==$Begin_squashfusetools_tar, NR==$End_squashfusetools_tar" $0 | tar xzv -C .
export LD_LIBRARY_PATH=/home/markus/Downloads/teest/libs
awk "NR==$Begin_java_runtime, NR==$End_java_runtime" $0 > /home/markus/Downloads/teest/libs/squashfuse "{testsdfsd}" temp/
#/home/markus/Downloads/teest/libs/squashfuse $test temp/

exit
#__Begin_squashfusetools_tar__
