#!/bin/bash

# extract the base name
name=`basename -s .ctl $1`

# run meep for the file
./meep12 fcen=0.4 df=0.35 $1 | tee "${name}.out"

# create the geometry (eps file)
h5topng -S3 ${name}-eps-000000.00.h5

# grep for the frequencies
grep -i harminv0 "${name}.out" > "${name}_frequencies.txt"

# get the count of frequencies
numfreq=`wc -l ${name}_frequencies.txt | cut -c 1-2`
echo "numfreq = $numfreq" 

rm "${name}-ez"*.h5

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
