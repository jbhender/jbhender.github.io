#!/bin/env bash

## This is an example shell script
## meant to illustrate some Linux
## shell functionality.

# File with class roster
ROSTER=./roster.txt

# Loop over the roster 
while read line 
do

  # Check whether the directory already exists
  if [ ! -d "$line" ]; then

    mkdir $line
    echo Hi $line! > $line/$line.txt

  else

    # Check if the file exists
    if [ ! -f "$line.txt" ]; then

      # Print a hello message in the directory
      echo Hi $line! > $line/$line.txt

    fi

  fi

done < $ROSTER

