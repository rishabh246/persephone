#!/bin/bash -x

# Setup synthetic work library
make -C ${PSP_DIR}/Persephone/submodules/fake_work libfake

# Setup RocksDB
make -j -C ${PSP_DIR}/Persephone/submodules/rocksdb static_lib

# Setup Perséphone
mkdir ${PSP_DIR}/Persephone/build && cd ${PSP_DIR}/Persephone/build
cmake -DCMAKE_BUILD_TYPE=Release -DDPDK_MELLANOX_SUPPORT=OFF ${PSP_DIR}/Persephone
make -j -C ${PSP_DIR}/Persephone/build

# Setup Shinjuku
cd ${PSP_DIR}/Persephone/submodules/shinjuku
${PSP_DIR}/Persephone/submodules/shinjuku/deps/fetch-deps.sh
sudo rmmod pcidma
sudo rmmod dune
sudo make -sj -C deps/dune
make -sj -C deps/pcidma
make -sj -C deps/dpdk config T=x86_64-native-linuxapp-gcc
cd ${PSP_DIR}/Persephone/submodules/shinjuku/deps/dpdk
git apply ${PSP_DIR}/Persephone/submodules/shinjuku/deps/dpdk_i40e.patch
git apply ${PSP_DIR}/Persephone/submodules/shinjuku/deps/dpdk_mk.patch
cd ${PSP_DIR}/Persephone/submodules/shinjuku
make -sj -C deps/dpdk
cd ${PSP_DIR}/Persephone/submodules/shinjuku/deps/rocksdb
git apply ${PSP_DIR}/Persephone/submodules/shinjuku/deps/rocksdb.patch
cd ${PSP_DIR}/Persephone/submodules/shinjuku/
make -sj -C deps/rocksdb static_lib
make -sj -C deps/opnew
make -j
# Setup the RocksDB database creation utility
make -C db create_db

sudo mkdir -p /tmpfs
mountpoint -q /tmpfs || sudo mount -t tmpfs -o size=50G,mode=1777 tmpfs /tmpfs
mkdir -p /tmpfs/experiments/
