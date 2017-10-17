#!/bin/bash

export kernel=Werewolf
export outdir=/home/reddragon/Werewolf
export makeopts="-j$(nproc)"
export zImagePath="arch/arm64/boot/Image"
export KBUILD_BUILD_USER=USA-RedDragon
export KBUILD_BUILD_HOST=EdgeOfCreation
export CROSS_COMPILE="ccache /android-src/inv/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
export ARCH=arm64
export shouldclean="0"
export istest="0"

export version=$(cat version)
export RDIR=$(pwd)


function build() {
    if [[ $shouldclean =~ "1" ]] ; then
        make ${makeopts} clean
        make ${makeopts} mrproper
    fi
    export deviceconfig="werewolf_defconfig"
    export device="nobleltetmo"

    make -C ${RDIR} ${makeopts} ${deviceconfig}
    make -C ${RDIR} ${makeopts}
    make -C ${RDIR} ${makeopts} modules

    if [ -a ${zImagePath} ] ; then
        cp ${zImagePath} zip/zImage
	zip/dtbTool -o zip/dtb -s 2048 -p ./scripts/dtc/dtc ./arch/arm64/boot/dts/
	mkdir -p zip/modules/
	find -name '*.ko' -exec cp -av {} zip/modules/ \;
        cd zip
        zip -q -r ${kernel}-${device}-${version}.zip anykernel.sh META-INF tools zImage dtb modules
    else
        echo -e "\n\e[31m***** Build Failed *****\e[0m\n"
    fi

    if ! [ -d ${outdir} ] ; then
        mkdir ${outdir}
    fi

    if [ -a ${kernel}-${device}-${version}.zip ] ; then
        mv -v ${kernel}-${device}-${version}.zip ${outdir}
    fi

    cd ${RDIR}

    rm -f zip/zImage
    rm -f zip/dtb
    rm -rf zip/modules
}

if [[ $1 =~ "clean" ]] ; then
    shouldclean="1"
fi

build
