#!/usr/bin/env bash
# shellcheck disable=SC2199
# shellcheck source=/dev/null
#
# Copyright (C) 2020-22 UtsavBalar1231 <utsavbalar1231@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

GCC_64_DIR="$HOME/tc/aarch64-linux-android-4.9"
KBUILD_COMPILER_STRING=$($HOME/tc/aosp-clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
KBUILD_LINKER_STRING=$($HOME/tc/aosp-clang/bin/ld.lld --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' | sed 's/(compatible with [^)]*)//')
export KBUILD_COMPILER_STRING
export KBUILD_LINKER_STRING

DEVICE=$1

if [ "${DEVICE}" = "alioth" ]; then
DEFCONFIG=vendor/alioth_defconfig
elif [ "${DEVICE}" = "apollo" ]; then
DEFCONFIG=vendor/apollo_defconfig
elif [ "${DEVICE}" = "lmi" ]; then
DEFCONFIG=vendor/lmi_defconfig
elif [ "${DEVICE}" = "munch" ]; then
DEFCONFIG=munch_defconfig
elif [ "${DEVICE}" = "psyche" ]; then
DEFCONFIG=vendor/psyche_defconfig
fi

#
# Enviromental Variables
#

DATE=$(date '+%Y%m%d-%H%M')

# Set our directory
OUT_DIR=out/

VERSION="Uvite-${DEVICE}-${DATE}"

# Export Zip name
export ZIPNAME="${VERSION}.zip"

# How much kebabs we need? Kanged from @raphielscape :)
if [[ -z "${KEBABS}" ]]; then
    COUNT="$(grep -c '^processor' /proc/cpuinfo)"
    export KEBABS="$((COUNT + 2))"
fi

echo "Jobs: ${KEBABS}"

ARGS="ARCH=arm64 \
O=${OUT_DIR} \
CC=clang \
LLVM=1 \
LLVM_IAS=1 \
CLANG_TRIPLE=aarch64-linux-gnu- \
CROSS_COMPILE=$GCC_64_DIR/bin/aarch64-linux-android- \
-j${KEBABS}"

START=$(date +"%s")

# Set compiler Path
export PATH="$HOME/tc/aosp-clang/bin:$PATH"
export LD_LIBRARY_PATH=${HOME}/tc/aosp-clang/lib64:$LD_LIBRARY_PATH

echo "------ Starting Compilation ------"

# Make defconfig
make -j${KEBABS} ${ARGS} ${DEFCONFIG}

make -j${KEBABS} ${ARGS} CC="ccache clang" HOSTCC="ccache gcc" HOSTCXX="ccache g++" 2>&1 | tee build.log

#make -j1 ${ARGS} CC="ccache clang" HOSTCC="ccache gcc" HOSTCXX="ccache g++" V=1 2>&1 | tee build.log
