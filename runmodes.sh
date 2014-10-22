#!/bin/bash

# specify the path to the meep folder
meepfolder="../meep"

origfolder=`pwd`

# extract the base name
name=`basename -s .ctl $1`

cd ${meepfolder}

# run meep for the file
./meep12 fcen=0.4 df=0.35 "${origfolder}/$1" | tee "${name}.out"

# create the geometry (eps file)
h5topng -S3 ${name}-eps-000000.00.h5

# grep for the frequencies
grep -i harminv0 "${name}.out" > "${name}_frequencies.txt"

# get the count of frequencies
numfreq=`wc -l ${name}_frequencies.txt | cut -c 1-2`
echo "numfreq = $numfreq" 

rm "${name}-ez"*.h5

# move it all to its folder (if it exists)
if [ -d "${meepfolder}/meep_output/${name}" ]
then
  echo "yes, folder exists"
else
  echo "no, folder doesn't exist"
  mkdir "${meepfolder}/meep_output/${name}"
fi

if [ -d "${meepfolder}/meep_output/${name}/modes" ]
then
  echo "bands folder exists"
else
  mkdir "${meepfolder}/meep_output/${name}/modes"
fi

# for each frequency, run meep in a small band
for (( i=2; i <= numfreq ; i++ ))
do

  echo "iteration: $i" 
  # get the currenty frequency (first three decimal places of freq)
  sedcomm="sed '${i}q;d' ${name}_frequencies.txt | cut -d \",\" -f 2 | cut -c 2-6"
  echo "sedcomm = $sedcomm"
  fthis=`eval $sedcomm`

  # run meep in a small band around that frequency
  ./meep12 "fcen=$fthis" df=0.01 $1 | tee "${name}.out"

  # extract images
  h5topng -RZc dkbluered -C "${name}-eps-000000.00.h5" "${name}-ez"*.h5

  # create gif
  convert "${name}-ez-"*.png "${name}-ez-${fthis}.gif"

  # clean up images and h5 files
  rm "${name}-ez-"*.png
  rm "${name}-ez"*.h5

done

# move all the gifs and stuff to the output folder
mv "${name}"* "meep_output/${name}/modes"
