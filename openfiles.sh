#!/bin/bash
# Sebastian von dem Berge, v0.1
#
# Collect open files over period of time and provide feedback
#
# Output files (if any):
# openfiles_high_prevalence: more than 90% occurrences across all iterations
# openfiles_medium_prevalence: more than 50% occurrences across all iterations
# openfiles_low_prevalence: less than 50% occurrences across all iterations

#############
# global vars
#############
# collecting data for 1 day: 8.640 iterations; 10 seconds pause in between
g_iterations=8640
g_sleep=10
# command configurable
g_cmd="lsof -w -d 0-999| awk '\$5 == \"REG\" || \$5 == \"DIR\" {print \$9}'"

##########
# Function
##########
function get_openfiles() {
  declare -A l_files
  for line in $(eval "$g_cmd"); do
    l_files[${line}]=1
  done
  for line in "${!l_files[@]}"; do
    [ -v g_files[${line}] ] && (( g_files[${line}]+=1 )) || g_files[${line}]=1
  done
}

######
# Main
######
declare -A g_files

# go through iterations
for iteration in $(eval echo "{1..$g_iterations}"); do
  get_openfiles
  sleep ${g_sleep}
done

# process data and write to files
for entry in "${!g_files[@]}"; do
  prevalence=$(( (${g_files[${entry}]} *100 / ${g_iterations}) ))
  if [ $prevalence -ge 90 ]
  then
    echo ${entry} >> openfiles_high_prevalence.log
  elif [ $prevalence -ge 50 ]
  then
    echo ${entry} >> openfiles_medium_prevalence.log
  else
    echo ${entry} >> openfiles_low_prevalence.log
  fi
done
