#!/bin/bash
function func() {(
  set -e
	pwd_tmp=$(pwd)
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
  make -C $NOOP_HOME emu -j$(( $(nproc) / 2 )) SIM_ARGS="" EMU_THREADS=$threads WITH_DRAMSIM3=1 EMU_TRACE=1 CONFIG=KunminghuV2Config 2>&1 | tee $pwd_tmp/.build.log

  echo "========== make end at $(date) =========="
)}
func
python3 /nfs/home/share/liyanqin/scripts/ShareAutoEmailAlert.py -r $? --content "XiangShan build finish"
