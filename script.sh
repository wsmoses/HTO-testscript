set -e

CORES="${CORES:-10}"
REPEAT="${REPEAT:-10}"

mkdir results
RESULTS="`pwd`/results"

git clone https://github.com/wsmoses/LLVM-HTO -b manglecpp --depth 1
cd LLVM-HTO
mkdir build
cd build
cmake ../llvm -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_TARGETS_TO_BUILD="X86"
make -j$CORES
export CC="`pwd`/bin/clang"
export CXX="`pwd`/bin/clang++"
LIT="`pwd`/bin/llvm-lit"
cd ../..

SUITE="`pwd`/suite"

mkdir $SUITE

git clone git@github.com:wsmoses/HTO-test-suite forheaders -b annotate --depth 1
cd forheaders
mkdir build
cd build
cmake .. -DSUITEDIR=$SUITE -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/Release.cmake
make -j$CORES -i

for i in {1..$REPEAT}; do
    $LIT -v -j 1 -o $RESULTS/plain$i.txt;
done
cd ../..

git clone git@github.com:wsmoses/HTO-test-suite hto -b fastbuild --depth 1
cd hto
mkdir build
cd build
cmake .. -DSUITEDIR=$SUITE -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/Release.cmake
make -j$CORES -i

for i in {1..$REPEAT}; do
    $LIT -v -j 1 -o $RESULTS/hto$i.txt;
done
cd ../..


git clone git@github.com:wsmoses/HTO-test-suite thinlto -b lto --depth 1
cd thinlto
mkdir build
cd build
cmake .. -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseThinLTO.cmake
make -j$CORES -i

for i in {1..$REPEAT}; do
    $LIT -v -j 1 -o $RESULTS/thinlto$i.txt;
done
cd ../..

git clone git@github.com:wsmoses/HTO-test-suite thinlto -b lto --depth 1
cd thinlto
mkdir build
cd build
cmake .. -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -C../cmake/caches/ReleaseLTO.cmake
make -j$CORES -i

for i in {1..$REPEAT}; do
    $LIT -v -j 1 -o $RESULTS/fulllto$i.txt;
done
cd ../..


