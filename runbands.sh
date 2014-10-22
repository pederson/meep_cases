#!/bin/bash

# specify the path to the meep folder
meepfolder="../meep"

origfolder=`pwd`

# extract the base name
name=`basename -s .ctl $1`

cd ${meepfolder}

# run meep for the file
${meepfolder}/meep12 do_bands=true "${origfolder}/$1" | tee "${name}.out"

# grep for the real frequencies
grep freqs: "${name}.out" > "${name}_fRe.txt"

# grep for the imaginary frequencies
grep freqs-im: "${name}.out" > "${name}_fIm.txt"

# move it all to its folder (if it exists)
if [ -d "${meepfolder}/meep_output/${name}" ]
then
  echo "yes, folder exists"
else
  echo "no, folder doesn't exist"
  mkdir "${meepfolder}/meep_output/${name}"
fi

if [ -d "${meepfolder}/meep_output/${name}/bands" ]
then
  echo "bands folder exists"
else
  mkdir "${meepfolder}/meep_output/${name}/bands"
fi

mv "${name}"* "${meepfolder}/meep_output/${name}/bands"
