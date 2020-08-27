#!/bin/bash
set -e

CORES="${CORES:-32}"
REPEAT="${REPEAT:-10}"
MULTI="alacconvert-decode alacconvert-encode burg clamscan ldecod lencod SIBsim4 SPASS aha make_dparser hbd hexxagon kc lambda lemon lua minisat Obsequi oggenc sgefa siod spiff sqlite3 treecc viterbi 7zip-benchmark smg2000 AMGmk CrystalMk IRSmk drop3 five11 uudecode uuencode bullet CLAMR HACCKernels HPCCG PENNANT miniFE CoMD PathFinder rsbench SimpleMOC XSBench miniAMR miniGMG fhourstones3.1 fhourstones analyzer distray fourinarow mason neural pcompress2 pifft cfrac espresso gs qbsort testtrie bisect eks main vor iotest trie bintr imp automotive-basicmath automotive-bitcount automotive-susan consumer-jpeg consumer-lame consumer-typeset network-dijkstra network-patricia office-ispell office-stringsearch security-blowfish security-rijndael security-sha telecomm-CRC32 telecomm-fft telecomm-adpcm telecomm-gsm is bh bisort em3d health mst perimeter power treeadd tsp voronoi paq8p np city deriv1 deriv2 employ family fsm garage life objects ocean office primes shapes simul trees vcirc timberwolfmc agrep allroots assembler mybison cdecl compiler fixoutput football gnugo loader simulator unix-smail unix-tbl anagram bc ft ks yacr2 backprop hotspot pathfinder srad scimark2 ControlFlow-dbl ControlFlow-flt ControlLoops-dbl ControlLoops-flt CrossingThresholds-dbl CrossingThresholds-flt Equivalencing-dbl Equivalencing-flt Expansion-dbl Expansion-flt GlobalDataFlow-dbl GlobalDataFlow-flt IndirectAddressing-dbl IndirectAddressing-flt InductionVariable-dbl InductionVariable-flt LinearDependence-dbl LinearDependence-flt LoopRerolling-dbl LoopRerolling-flt LoopRestructuring-dbl LoopRestructuring-flt NodeSplitting-dbl NodeSplitting-flt Packing-dbl Packing-flt Recurrences-dbl Recurrences-flt Reductions-dbl Reductions-flt Searching-dbl Searching-flt StatementReordering-dbl StatementReordering-flt Symbolics-dbl Symbolics-flt enc-3des enc-md5 enc-pc1 enc-rc4 netbench-crc netbench-url 8b10b beamformer bmm dbms ecbdes llu pairlocalalign rawcaudio rawdaudio encode toast cjpeg mpeg2decode nbench sim tramp3d-v4 frame_layout"

INCDIR="$HOME/muslhto8"

mkdir -p results
RESULTS="`pwd`/results"

if (( 1 )) ; then

git clone --depth 1 git://sourceware.org/git/binutils-gdb.git binutils
cd binutils
BININC="`pwd`/include"
mkdir build
cd build
../configure --enable-gold --enable-plugins --disable-werror
make -j$CORES
cd ../..

git clone https://github.com/wsmoses/LLVM-HTO -b manglecpp --depth 1
cd LLVM-HTO
mkdir build
cd build
cmake ../llvm -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_USE_LINKER=gold -DLLVM_BINUTILS_INCDIR="$BININC"
make -j$CORES
export CC="$HOME/muslpfx/bin/musl-clang"
export CXX="$HOME/muslpfx/bin/musl-clang++"
LIT="`pwd`/bin/llvm-lit"
cd ../..

git clone git@github.com:wsmoses/HTO-test-suite hto -b fastbuild --depth 1
cd hto

for i in $(seq 1 $REPEAT); do
rm -rf build
	mkdir build
cd build
cmake .. -DSUITEDIR=$INCDIR -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseNoLTO.cmake
make -i $MULTI | tee errs.txt
    $LIT -v -j 1 -o $RESULTS/muslhto$i.json ./MultiSource || true;
cd ..
done
cd ..

git clone git@github.com:wsmoses/HTO-test-suite noheaders -b noannotate --depth 1
fi
export CC="$HOME/muslpfx/bin/musl-clang"
export CXX="$HOME/muslpfx/bin/musl-clang++"
cd noheaders

for i in $(seq 1 $REPEAT); do
rm -rf build
	mkdir build
cd build
cmake .. -DSUITEDIR=$INCDIR -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseNoLTO.cmake
make -i $MULTI
    $LIT -v -j 1 -o $RESULTS/noheaders$i.json ./MultiSource || true;
cd ..
done
cd ..


git clone git@github.com:wsmoses/HTO-test-suite thinlto -b fastbuild --depth 1
cd thinlto

for i in $(seq 1 $REPEAT); do
rm -rf build
	mkdir build
cd build
cmake .. -DSUITEDIR=$INCDIR -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseThinLTO.cmake
make -i $MULTI
    $LIT -v -j 1 -o $RESULTS/muslthinlto$i.json ./MultiSource || true;
cd ..
done
cd ..

git clone git@github.com:wsmoses/HTO-test-suite fulllto -b fastbuild --depth 1
cd fulllto

for i in $(seq 1 $REPEAT); do
rm -rf build
	mkdir build
cd build
cmake .. -DSUITEDIR=$INCDIR -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseLTO.cmake
make -i $MULTI
    $LIT -v -j 1 -o $RESULTS/fulllto$i.json ./MultiSource || true;
cd ..
done
cd ..


