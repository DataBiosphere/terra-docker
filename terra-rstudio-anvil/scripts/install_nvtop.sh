#!/bin/bash
set -e

apt-get update && apt-get -y install cmake libncurses5-dev libncursesw5-dev git
git clone https://github.com/Syllo/nvtop.git
cd nvtop
# Pin to a specific known-good version to ensure reproducible builds
git checkout v3.0.0
mkdir -p build && cd build
cmake .. -DNVML_RETRIEVE_HEADER_ONLINE=True
make
make install
cd ../..

# Clean up
rm -rf /var/lib/apt/lists/* nvtop
