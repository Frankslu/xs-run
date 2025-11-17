#!/bin/bash
pwd_tmp=$(pwd)
function func() {(
  set -e
	function set_env(){
	  cd ../
	  . ./env.sh
	  cd XiangShan
	}
	set_env

	########## param: YOU SHOULD CONFIRM ##########
	threads=16 # notice threads should keep same between build.sh and run.sh

	########## make ##########
	echo "========== make start at $(date) =========="

	cd $DRAMSIM3_HOME
	git checkout cosim-kmh
	mkdir build -p && cd build
	cmake -D COSIM=1 ..
	make -j
	cd $NOOP_HOME

  [ -e build ] && mv build build.$(date +%Y%m%d_%H_%M_%d).tmp
  make clean
  make -C $NOOP_HOME emu -j$(( $(nproc) / 2 )) SIM_ARGS="" EMU_THREADS=$threads WITH_DRAMSIM3=1 EMU_TRACE=1 CONFIG=KunminghuV2Config \
    1> >(tee build.log) 2> >(tee build.err)

  echo "========== make end at $(date) =========="
  touch $pwd_tmp/.build.succ
)}
func
if [ -e $pwd_tmp/.build.succ ]; then
  python3 /nfs/home/share/liyanqin/scripts/ShareAutoEmailAlert.py -r 0 --content "XiangShan build finish"
  rm $pwd_tmp/.build.succ
else
  python3 /nfs/home/share/liyanqin/scripts/ShareAutoEmailAlert.py -r 1 --content "XiangShan build fail"
fi
