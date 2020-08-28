set -e

CORES="${CORES:-24}"
REPEAT="${REPEAT:-10}"

TESTS=" 453.povray 429.mcf 462.libquantum 456.hmmer 470.lbm 473.astar 444.namd 445.gobmk 458.sjeng 400.perlbench 483.xalancbmk 450.soplex 464.h264ref 482.sphinx3 433.milc"
EXTRA=" -DTEST_SUITE_EXTERNALS_DIR=$HOME -DTEST_SUITE_RUN_TYPE=ref -DTEST_SUITE_ARCH_FLAGS='-march=native'"

mkdir results
RESULTS="`pwd`/results"

git clone --depth 1 git://sourceware.org/git/binutils-gdb.git binutils
git clone https://github.com/wsmoses/LLVM-HTO -b rebasev2 --depth 1
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


