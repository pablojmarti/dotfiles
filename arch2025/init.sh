#/usr/bin/env bash

# Set Up dot files in home repo

# grab all dot files currently in folder and iterate over them

# Adding this command here to document how I sync'd my actual nvim config with this repo
# find /Users/pablo/workspace/projects/dotfiles/macbook2024-redux/.config/nvim/ -type d -exec ln -s '{}' /Users/pablo/.config/nvim  \;
# for file in $( find $(pwd) -name ".*" -type f ); 
# do
#   linking_path="$HOME/$(basename $file)"
#   echo "Linking $file with $linking_path"
#   ln -fs $file $HOME
# done

for folder in $(find .config -type d);
do
  echo "mkdir -p $HOME/$folder"
  mkdir -p $HOME/$folder
  for file in $(find $folder -maxdepth 1 -type f);
  do
    echo "ln -s $(pwd)/$file $HOME/$file"
    ln -s $(pwd)/$file $HOME/$file
  done
done

echo "Config done"

