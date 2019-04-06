#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
cyan='\033[01;36m'
blue='\033[01;34m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
DEFCONFIG="msm8909_x20_g151_defconfig"
KERNEL="zImage"

#Hyper Kernel Details
BASE_VER="CAF-ARM-N108-G151"
VER="-$(date +"%Y%m%d"-%H%M)-"
Devmod_VER="$BASE_VER$VER$TC"

# Vars
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=g151
export KBUILD_BUILD_HOST=fzkdevmod

# Paths
KERNEL_DIR=`pwd`
RESOURCE_DIR="/home/fzkdevmod/Desktop/fzk_team/project_hy"
ANYKERNEL_DIR="$RESOURCE_DIR/hyper"
TOOLCHAIN_DIR="$RESOURCE_DIR/toolchain"
REPACK_DIR="$ANYKERNEL_DIR"
PATCH_DIR="$ANYKERNEL_DIR/patch"
MODULES_DIR="$ANYKERNEL_DIR/modules"
ZIP_MOVE="$RESOURCE_DIR/kernel_out"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm/boot"

# Functions
function make_kernel {
		make $DEFCONFIG $THREAD
		make $THREAD
		make dtbs $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

#function make_modules {
#		cd $KERNEL_DIR
#		make modules $THREAD
#		find $KERNEL_DIR -name '*.ko' -exec cp {} $MODULES_DIR/ \;
#		cd $MODULES_DIR
#       $STRIP --strip-unneeded *.ko
#      cd $KERNEL_DIR
#}

function make_dtb {
		$KERNEL_DIR/dtbToolLineage -2 -o $KERNEL_DIR/arch/arm/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
		cp -vr $KERNEL_DIR/arch/arm/boot/dt.img $REPACK_DIR/dtb
}

function make_zip {
		cd $REPACK_DIR
		zip -r `echo $Devmod_VER$TC`.zip *
		mv  `echo $Devmod_VER$TC`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}

DATE_START=$(date +"%s")


echo -e "${green}"
echo "--------------------------------------------------------"
echo "Wellcome !!!   Initiatig To Compile $Devmod_VER    "
echo "--------------------------------------------------------"
echo -e "${restore}"

echo -e "${cyan}"
while read -p "Plese Select Desired Toolchain for compiling Kernel

UBERTC-4.9 (ARM)---->(1)

GNU-8.2 (ARM)---->(2)

LINARO-8.2 (ARM)---->(3)


" echoice
do
case "$echoice" in
	1 )
		export CROSS_COMPILE=$TOOLCHAIN_DIR/ubertc/arm/gcc4/arm-eabi-4.9/bin/arm-eabi-
		export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/ubertc/arm/gcc4/arm-eabi-4.9/lib/
		STRIP=$TOOLCHAIN_DIR/ubertc/arm/gcc4/arm-eabi-4.9/bin/arm-eabi-strip
		TC="UB"
		rm -rf $MODULES_DIR/*
		rm -rf $ZIP_MOVE/*
		rm -rf $KERNEL_DIR/arch/arm/boot/dt.img
		cd $ANYKERNEL_DIR
		rm -rf zImage
		rm -rf dtb
		cd $KERNEL_DIR
		make clean && make mrproper
		echo "cleaned directory"
		echo "Compiling Kernel Using UBERTC-4.9 Toolchain"
		break
		;;
	2 )
		export CROSS_COMPILE=$TOOLCHAIN_DIR/gnu/arm/arm-linux-gnueabi/bin/arm-linux-gnueabi-
		export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/gnu/arm/arm-linux-gnueabi/lib/
		STRIP=$TOOLCHAIN_DIR/gnu/arm/arm-linux-gnueabi/bin/arm-linux-gnueabi-strip
		TC="GNU"
		rm -rf $MODULES_DIR/*
		rm -rf $ZIP_MOVE/*
		rm -rf $KERNEL_DIR/arch/arm/boot/dt.img
		cd $ANYKERNEL_DIR
		rm -rf zImage
		rm -rf dtb
		cd $KERNEL_DIR
		make clean && make mrproper
		echo "cleaned directory"
		echo "Compiling Kernel Using GNU-8.2 Toolchain"
		break
		;;
	3 )
		export CROSS_COMPILE=$TOOLCHAIN_DIR/linaro/arm/gcc8/arm-linux-gnueabi/bin/arm-linux-gnueabi-
		export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/linaro/arm/gcc8/arm-linux-gnueabi/lib/
		STRIP=$TOOLCHAIN_DIR/linaro/arm/gcc8/arm-linux-gnueabi/bin/arm-linux-gnueabi-strip
		TC="LN"
		rm -rf $MODULES_DIR/*
		rm -rf $ZIP_MOVE/*
		rm -rf $KERNEL_DIR/arch/arm/boot/dt.img
		cd $ANYKERNEL_DIR
		rm -rf zImage
		rm -rf dtb
		cd $KERNEL_DIR
		make clean && make mrproper
		echo "cleaned directory"
		echo "Compiling Kernel Using LINARO-8.2 Toolchain"
		break
		;;

	* )
		echo
		echo "Invalid Selection try again !!"
		echo
		;;
esac
done
echo -e "${restore}"

echo
while read -p "Do you want to start Building Kernel ?

Yes Or No ? 

Enter Y for Yes Or N for No
" dchoice
do
case "$dchoice" in
	y|Y )
		make_kernel
		make_dtb
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid Selection try again !!"
		echo
		;;
esac
done
echo -e "${green}"
echo $Devmod_VER$TC.zip
echo "------------------------------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo " "
