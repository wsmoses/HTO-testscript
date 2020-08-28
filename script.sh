set -e

CORES="${CORES:-24}"
REPEAT="${REPEAT:-10}"

TESTS="alacconvert-decode alacconvert-encode burg clamscan ldecod lencod SIBsim4 SPASS aha make_dparser hbd hexxagon kc lambda lemon lua minisat Obsequi oggenc sgefa siod spiff sqlite3 treecc viterbi 7zip-benchmark smg2000 AMGmk CrystalMk IRSmk drop3 five11 uudecode uuencode bullet CLAMR HACCKernels HPCCG PENNANT miniFE CoMD PathFinder rsbench SimpleMOC XSBench miniAMR miniGMG fhourstones3.1 fhourstones analyzer distray fourinarow mason neural pcompress2 pifft cfrac espresso gs qbsort testtrie bisect eks main vor iotest trie bintr imp automotive-basicmath automotive-bitcount automotive-susan consumer-jpeg consumer-lame consumer-typeset network-dijkstra network-patricia office-ispell office-stringsearch security-blowfish security-rijndael security-sha telecomm-CRC32 telecomm-fft telecomm-adpcm telecomm-gsm is bh bisort em3d health mst perimeter power treeadd tsp voronoi paq8p np city deriv1 deriv2 employ family fsm garage life objects ocean office primes shapes simul trees vcirc timberwolfmc agrep allroots assembler mybison cdecl compiler fixoutput football gnugo loader simulator unix-smail unix-tbl anagram bc ft ks yacr2 backprop hotspot pathfinder srad scimark2 ControlFlow-dbl ControlFlow-flt ControlLoops-dbl ControlLoops-flt CrossingThresholds-dbl CrossingThresholds-flt Equivalencing-dbl Equivalencing-flt Expansion-dbl Expansion-flt GlobalDataFlow-dbl GlobalDataFlow-flt IndirectAddressing-dbl IndirectAddressing-flt InductionVariable-dbl InductionVariable-flt LinearDependence-dbl LinearDependence-flt LoopRerolling-dbl LoopRerolling-flt LoopRestructuring-dbl LoopRestructuring-flt NodeSplitting-dbl NodeSplitting-flt Packing-dbl Packing-flt Recurrences-dbl Recurrences-flt Reductions-dbl Reductions-flt Searching-dbl Searching-flt StatementReordering-dbl StatementReordering-flt Symbolics-dbl Symbolics-flt enc-3des enc-md5 enc-pc1 enc-rc4 netbench-crc netbench-url 8b10b beamformer bmm dbms ecbdes llu pairlocalalign rawcaudio rawdaudio encode toast cjpeg mpeg2decode nbench sim tramp3d-v4 frame_layout "
EXTRA=""

mkdir results
RESULTS="`pwd`/results"

git clone --depth 1 git://sourceware.org/git/binutils-gdb.git binutils
git clone https://github.com/wsmoses/LLVM-HTO -b rebase2 --depth 1
#git clone https://github.com/wsmoses/LLVM-HTO -b manglecpp --depth 1

git clone git@github.com:wsmoses/HTO-test-suite fulllto -b lto --depth 1
git clone git@github.com:wsmoses/HTO-test-suite forheaders -b annotate --depth 1
git clone git@github.com:wsmoses/HTO-test-suite thinlto -b lto --depth 1
git clone git@github.com:wsmoses/HTO-test-suite noheaders -b noannotate --depth 1
git clone git@github.com:wsmoses/HTO-test-suite hto -b fastbuild --depth 1

cd binutils
BININC="`pwd`/include"
mkdir build
cd build
../configure --enable-gold --enable-plugins --disable-werror
make -j$CORES
cd ../..

cd LLVM-HTO
mkdir build
cd build
cmake ../llvm -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_USE_LINKER=gold -DLLVM_BINUTILS_INCDIR="$BININC"
make -j$CORES
export CC="`pwd`/bin/clang"
export CXX="`pwd`/bin/clang++"
LIT="`pwd`/bin/llvm-lit"
cd ../..

SUITE="`pwd`/suite"

mkdir $SUITE

cd forheaders
for i in $(seq 1 1); do
	rm -rf build
	mkdir build
	cd build
	cmake -DLARGE_PROBLEM_SIZE=1 $EXTRA .. -DSUITEDIR=$SUITE -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseNoLTO.cmake
	taskset -c 1-1 numactl -i all make -i $TESTS
    	taskset -c 1-8 numactl -i all $LIT -v -j 1 -o $RESULTS/plain$i.json ./MultiSource || true;
	cd ..
done
cd ..

find $SUITE -type f -exec sed -E "s/class ([A-Za-z0-9_:]*)::\*/\1::\*/g" {} -i \;
find $SUITE -type f -exec sed -E "s/>>/> >/g" {} -i \;
find $SUITE -type f -exec sed -E "s/= 0;/;/g" -i {} \;

cd hto

for i in $(seq 1 $REPEAT); do
rm -rf build
	mkdir build
cd build
cmake .. -DLARGE_PROBLEM_SIZE=1 $EXTRA -DSUITEDIR=$SUITE -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseNoLTO.cmake
taskset -c 1-1 numactl -i all make -i $TESTS | tee errs.txt
taskset -c 1-8 numactl -i all $LIT -v -j 1 -o $RESULTS/hto$i.json ./MultiSource || true;
cd ..
done
cd ..


cd thinlto

for i in $(seq 1 $REPEAT); do
rm -rf build
	mkdir build
cd build
cmake .. -DLARGE_PROBLEM_SIZE=1 $EXTRA -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseThinLTO.cmake
taskset -c 1-1 numactl -i all make -i $TESTS
taskset -c 1-8 numactl -i all $LIT -v -j 1 -o $RESULTS/thinlto$i.json ./MultiSource || true;
cd ..
done
cd ..

cd noheaders
for i in $(seq 1 $REPEAT); do
rm -rf build
	mkdir build
cd build
cmake .. -DLARGE_PROBLEM_SIZE=1 $EXTRA -DSUITEDIR=$SUITE -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseNoLTO.cmake
taskset -c 1-1 numactl -i all make -i $TESTS
taskset -c 1-8 numactl -i all $LIT -v -j 1 -o $RESULTS/noheaders$i.json ./MultiSource || true;
cd ..
done
cd ..

cd fulllto

for i in $(seq 1 $REPEAT); do
rm -rf build
	mkdir build
cd build
cmake .. -DLARGE_PROBLEM_SIZE=1 $EXTRA -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseLTO.cmake
taskset -c 1-1 numactl -i all make -i $TESTS
taskset -c 1-8 numactl -i all $LIT -v -j 1 -o $RESULTS/fulllto$i.json ./MultiSource || true;
cd ..
done
cd ..


