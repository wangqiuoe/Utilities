#!/bin/bash

# Set name of list of all problems
problem_list="list_decoded.txt"

# Loop through problem list
while IFS= read -r problem
do

  # Create main directory for decoded problems
  if [ ! -d "decoded" ]
  then
    mkdir decoded;
  fi

  # Create directory for decoded problem, if doesn't exist already
  if [ ! -d "decoded/$problem" ]
  then
    mkdir decoded/$problem;
  fi

  # Move to directory to decode problem
  cd decoded/$problem;

  # Decode problem
  cutest2matlab $problem;
  
  # Move back to script directory
  cd ../..;

done < "$problem_list"
