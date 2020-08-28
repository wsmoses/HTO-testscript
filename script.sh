set -e

CORES="${CORES:-24}"
REPEAT="${REPEAT:-10}"

TESTS="em3d Reductions-flt InductionVariable-dbl unix-smail make_dparser StatementReordering-dbl LinearDependence-dbl imp bintr life assembler garage CrossingThresholds-flt archie allroots np security-sha LoopRestructuring-flt paq8p Searching-flt hexxagon iotest bc gs mpeg2decode cjpeg simul frame_layout bullet CrossingThresholds-dbl Symbolics-dbl automotive-basicmath GlobalDataFlow-flt AMGmk PathFinder miniFE deriv2 sim fsm objects city ControlFlow-dbl oggenc rawcaudio gnugo telecomm-adpcm CoMD alacconvert-encode unix-tbl enc-rc4 SimpleMOC NodeSplitting-dbl security-rijndael lambda consumer-typeset smg2000 cdecl IndirectAddressing-dbl ks telecomm-CRC32 anagram ControlLoops-dbl IndirectAddressing-flt Recurrences-flt consumer-lame is ecbdes main nbench automotive-susan StatementReordering-flt spiff enc-3des football LoopRerolling-dbl encode aha telecomm-fft automotive-bitcount ocean vor fixoutput clamscan deriv1 Recurrences-dbl trees backprop Equivalencing-flt consumer-jpeg Packing-dbl plot2fig pathfinder hbd network-patricia Reductions-dbl NodeSplitting-flt dbms network-dijkstra tramp3d-v4 SIBsim4 lua LoopRerolling-flt family treecc ControlFlow-flt power bisect telecomm-gsm mybison toast uuencode hotspot InductionVariable-flt rsbench shapes SPASS pairlocalalign drop3 eks rawdaudio security-blowfish PENNANT kc testtrie Expansion-dbl srad alacconvert-decode CrystalMk five11 CLAMR treeadd trie yacr2 HPCCG agrep XSBench Packing-flt 7zip-benchmark 8b10b Expansion-flt employ Symbolics-flt qbsort office-stringsearch vcirc HACCKernels GlobalDataFlow-dbl LoopRestructuring-dbl ControlLoops-flt office burg Searching-dbl uudecode fhourstones miniGMG office-ispell primes LinearDependence-flt siod Equivalencing-dbl espresso"
EXTRA=""

mkdir results
RESULTS="`pwd`/results"

git clone --depth 1 git://sourceware.org/git/binutils-gdb.git binutils
git clone https://github.com/wsmoses/LLVM-HTO -b rebasev2 --depth 1
#git clone https://github.com/wsmoses/LLVM-HTO -b manglecpp --depth 1

git clone git@github.com:wsmoses/HTO-test-suite fulllto -b lto --depth 1
git clone git@github.com:wsmoses/HTO-test-suite forheaders -b annotate --depth 1
git clone git@github.com:wsmoses/HTO-test-suite thinlto -b lto --depth 1
git clone git@github.com:wsmoses/HTO-test-suite noheaders -b noannotate --depth 1
git clone git@github.com:wsmoses/HTO-test-suite hto -b htomusl --depth 1

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
export CC="$HOME/muslpfx/bin/musl-clang"
export CXX="$HOME/muslpfx/bin/musl-clang++"
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


