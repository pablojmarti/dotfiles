#/usr/bin/env bash

# Set Up dot files in home repo

# grab all dot files currently in folder and iterate over them
for file in $( find $(pwd) -name ".*" -type f ); 
do
  linking_path="$HOME/$(basename $file)"
  echo "Linking $file with $linking_path"
  ln -fs $file $HOME
done

echo "Config done"
