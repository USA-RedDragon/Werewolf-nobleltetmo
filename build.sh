#!/bin/bash

export kernel=Werewolf
export outdir=/home/reddragon/Werewolf
export makeopts="-j$(nproc)"
export zImagePath="build/arch/arm64/boot/Image"
export KBUILD_BUILD_USER=USA-RedDragon
export KBUILD_BUILD_HOST=EdgeOfCreation
export CROSS_COMPILE="ccache /android-src/inv/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
export ARCH=arm64
export shouldclean="0"
export istest="0"
export deviceconfig=""
export device="nobleltetmo"
export modules="0"

export version=$(cat version)
export RDIR=$(pwd)


function build() {
    if [[ $shouldclean =~ "1" ]] ; then
        rm -rf build
    fi

    mkdir -p build

    make -C ${RDIR} O=build ${makeopts} ${deviceconfig}
    make -C ${RDIR} O=build ${makeopts}
    if [[ $modules =~ "1" ]] ; then
        make -C ${RDIR} O=build ${makeopts} modules
    fi

    if [ -a ${zImagePath} ] ; then
        cd ${RDIR}
        cp ${zImagePath} zip/zImage
	zip/dtbTool -o zip/dtb -s 2048 -p ./build/scripts/dtc/dtc ./build/arch/arm64/boot/dts/
        MOD=""
        if [[ $modules =~ "1" ]] ; then
            mkdir -p zip/modules/
            find build -name '*.ko' -exec cp -av {} zip/modules/ \;
            MOD="modules"
        fi
        cd zip
        zip -q -r ${kernel}-${device}-${version}.zip anykernel.sh META-INF tools zImage dtb $MOD
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

if [[ $1 =~ "stock" ]] ; then
    device="nobleltetmo-Stock"
    deviceconfig="werewolf_stock_defconfig"
else
    deviceconfig="werewolf_defconfig"
    if [[ $1 =~ "clean" ]] ; then
        shouldclean="1"
    fi
fi

if [[ $2 =~ "clean" ]] ; then
    shouldclean="1"
fi

build
