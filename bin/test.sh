#!/bin/sh

dir=$(dirname "$0")
cd "$dir/.."

modes="
| Testing ImageJ2 + original ImageJ |--legacy=true
|    Testing ImageJ2 standalone     |--legacy=false
|  Testing Fiji Is Just ImageJ(2)   |--ij=sc.fiji:fiji
|  Testing locally wrapped Fiji.app |--ij=Fiji.app
|  Testing ImageJ2 version 2.10.0   |--ij=2.10.0
|  Testing ImageJ2 version 2.14.0   |--ij=2.14.0
"

if [ ! -d Fiji.app ]
then
  # No locally available Fiji.app; download one.
  echo "-- Downloading and unpacking Fiji.app --"
  curl -fsLO https://downloads.imagej.net/fiji/latest/fiji-nojre.zip
  unzip fiji-nojre.zip
  echo
fi

echo "$modes" | while read mode
do
  test "$mode" || continue
  msg="${mode%|*}|"
  flag=${mode##*|}
  echo "-------------------------------------"
  echo "$msg"
  echo "-------------------------------------"
  if [ $# -gt 0 ]
  then
    python -m pytest -p no:faulthandler $flag $@
  else
    python -m pytest -p no:faulthandler $flag tests
  fi
  code=$?
  if [ $code -ne 0 ]
  then
    # HACK: `while read` creates a subshell, which can't modify the parent
    # shell's variables. So we save the failure code to a temporary file.
    echo $code >exitCode.tmp
  fi
done
exitCode=0
if [ -f exitCode.tmp ]
then
  exitCode=$(cat exitCode.tmp)
  rm -f exitCode.tmp
fi
exit "$exitCode"
