#!/bin/bash

# @file configgen.sh
# @brief Generates landslide-config.py for config.simics

function sched_func {
	echo -n
}
function ignore_sym {
	echo -n
}
function without_function {
	echo -n
}
function within_function {
	echo -n
}
function extra_sym {
	echo -n
}
function starting_threads {
	echo -n
}


function die {
	echo -e "\033[01;31m$1\033[00m" >&2
	exit 1
}

# Doesn't work without the "./". Everything is awful forever.
CONFIG=./config.landslide
if [ ! -f "$CONFIG" ]; then
	die "Where's $CONFIG?"
fi
TIMER_WRAPPER_DISPATCH=
IDLE_TID=
source $CONFIG

# Check sanity

if [ ! -f "$KERNEL_IMG" ]; then
	die "Invalid kernel image $KERNEL_IMG"
fi
if [ ! -d "$KERNEL_SOURCE_DIR" ]; then
	die "Invalid kernel source dir $KERNEL_SOURCE_DIR"
fi

if [ -f kernel -o -d kernel ]; then
	if ! cmp "$KERNEL_IMG" kernel 2>&1 >/dev/null; then
		if [ -L kernel ]; then
			rm kernel
			ln -s $KERNEL_IMG kernel
		else
			die "'kernel' exists, would be clobbered, please remove/relocate it."
		fi
	fi
else
	ln -s $KERNEL_IMG kernel
fi

# Generate file

echo "# This function is automatically generated by configgen.sh."
echo "# Any changes you make to it may will be overwritten."
echo "ls_source_path = \"$KERNEL_SOURCE_DIR\""
echo "ls_test_case = \"$TEST_CASE\""

echo "import hashlib"
KERNEL_MD5=`md5sum kernel | cut -d" " -f1`
echo -e "kernel_md5 = hashlib.md5(file(\"kernel\", \"r\").read()).hexdigest()"
echo -e "if kernel_md5 != \"$KERNEL_MD5\":"
echo -e "\tprint \"success\""
echo -e "\tprint \"\\\\033[01;31mFailed checksum on 'kernel';\""
echo -e "\tprint \"Landslide was built for $KERNEL_MD5,\""
echo -e "\tprint \"but current image hashes to \" + kernel_md5"
echo -e "\tprint \"Please re-run ./build.sh. Make sure 'bootfd.img' is right too!\""
echo -e "\tprint \"\\\\033[00m\""
echo -e "\tSIM_quit(1)"

BOOTFD_MD5=`md5sum bootfd.img | cut -d" " -f1`
echo -e "bootfd_md5 = hashlib.md5(file(\"bootfd.img\", \"r\").read()).hexdigest()"
echo -e "if bootfd_md5 != \"$BOOTFD_MD5\":"
echo -e "\tprint \"success\""
echo -e "\tprint \"\\\\033[01;31mFailed checksum on 'bootfd.img';\""
echo -e "\tprint \"Landslide was built for $BOOTFD_MD5,\""
echo -e "\tprint \"but current image hashes to \" + bootfd_md5"
echo -e "\tprint \"Please re-run ./build.sh. Make sure 'kernel' is right too!\""
echo -e "\tprint \"\\\\033[00m\""
echo -e "\tSIM_quit(1)"
