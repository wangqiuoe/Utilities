#!/bin/bash

# Set name of list of all problems
problem_list="list_all.txt"

# Loop through problem list
while IFS= read -r problem
do

  # Create folder for decoded problem, if doesn't exist already
  if [ ! -d decoded/$problem ]; then
    mkdir decoded/$problem;
  fi

  # Move to folder to decode problem
  cd decoded/$problem;

  # Decode problem
  cutest2matlab_osx $problem;
  
  # Move back to script directory
  cd ../..;

done < "$problem_list"
