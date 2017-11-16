#!/bin/bash
# Run from dir with scripts and subdir call_graph
# Parameters:
# $1 = sources (default is call_graph/sources.txt)
# $2 = targets (default is call_graph/targets.txt)

SOURCES=$1
if [ "$SOURCES" == "" ]; then SOURCES=call_graph/sources.txt; fi
TARGETS=$2
if [ "$TARGETS" == "" ]; then TARGETS=call_graph/targets.txt; fi

if [ ! -d call_graph ]; then echo "Run from parent dir of call_graph" >&2; exit 1; fi
(
#  cat call_graph/targets.txt
  for file in `cat $SOURCES `
  do
    for target in `grep -v -E '^ *#' $file | grep -o -F -w -f $TARGETS | grep -v -w $file | sort | uniq`
    do echo $file $target
    done
  done
)