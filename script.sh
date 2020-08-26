set -e

CORES="${CORES:-32}"
REPEAT="${REPEAT:-10}"

mkdir results
RESULTS="`pwd`/results"

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
export CC="`pwd`/bin/clang"
export CXX="`pwd`/bin/clang++"
LIT="`pwd`/bin/llvm-lit"
cd ../..

SUITE="`pwd`/suite"

mkdir $SUITE

git clone git@github.com:wsmoses/HTO-test-suite forheaders -b annotate --depth 1
cd forheaders

for i in $(seq 1 1); do
	rm -rf build
	mkdir build
	cd build
	cmake -DLARGE_PROBLEM_SIZE=1 .. -DSUITEDIR=$SUITE -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseNoLTO.cmake
	make -i
    $LIT -v -j 1 -o $RESULTS/plain$i.json ./MultiSource || true;
	cd ..
done
cd ..

git clone git@github.com:wsmoses/HTO-test-suite hto -b fastbuild --depth 1
cd hto

for i in $(seq 1 $REPEAT); do
rm -rf build
	mkdir build
cd build
cmake .. -DLARGE_PROBLEM_SIZE=1 -DSUITEDIR=$SUITE -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseNoLTO.cmake
make -i | tee errs.txt
    $LIT -v -j 1 -o $RESULTS/hto$i.json ./MultiSource || true;
cd ..
done
cd ..


git clone git@github.com:wsmoses/HTO-test-suite thinlto -b lto --depth 1
cd thinlto

for i in $(seq 1 $REPEAT); do
rm -rf build
	mkdir build
cd build
cmake .. -DLARGE_PROBLEM_SIZE=1 -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseThinLTO.cmake
make -i
    $LIT -v -j 1 -o $RESULTS/thinlto$i.json ./MultiSource || true;
cd ..
done
cd ..

git clone git@github.com:wsmoses/HTO-test-suite fulllto -b lto --depth 1
cd fulllto

for i in $(seq 1 $REPEAT); do
rm -rf build
	mkdir build
cd build
cmake .. -DLARGE_PROBLEM_SIZE=1 -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseLTO.cmake
make -i
    $LIT -v -j 1 -o $RESULTS/fulllto$i.json ./MultiSource || true;
cd ..
done
cd ..

git clone git@github.com:wsmoses/HTO-test-suite noheaders -b noannotate --depth 1
cd noheaders

for i in $(seq 1 $REPEAT); do
rm -rf build
	mkdir build
cd build
cmake .. -DLARGE_PROBLEM_SIZE=1 -DSUITEDIR=$SUITE -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseNoLTO.cmake
make -j$CORES -i
    $LIT -v -j 1 -o $RESULTS/noheaders$i.json ./MultiSource || true;
cd ..
done
cd ..

