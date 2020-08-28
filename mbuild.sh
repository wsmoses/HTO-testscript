
export BUILD=$HOME/muslbuild
rm -rf $BUILD
mkdir -p $BUILD
cd $BUILD
export CC="$HOME/HTO-testscript/LLVM-HTO/build/bin/clang"
export CXX="$HOME/HTO-testscript/LLVM-HTO/build/bin/clang++"
export AR="$HOME/HTO-testscript/LLVM-HTO/build/bin/llvm-ar"
export RANLIB="$HOME/HTO-testscript/LLVM-HTO/build/bin/llvm-ranlib"
export HTODIR=$HOME/muslhto

rm -rf $HTODIR
mkdir -p $HTODIR
export CFLAGS="-mllvm -hto_dir=$HTODIR -Rannotation -mllvm -attributor-enable=all -mllvm -hto_nostring=true -O3"
#export CXXFLAGS="$CFLAGS"
#export CPPFLAGS="$CXXFLAGS"
export INSTALL=$HOME/muslpfx
mkdir -p $INSTALL

$HOME/musl/configure --host=x86_64 --prefix=$INSTALL --syslibdir=$INSTALL/lib --disable-shared --disable-werror --with-clang --disable-float128 --with-lld --with-default-link --disable-multi-arch
cd $BUILD
make -j

sed -i 's/arg_attr(2, "returned")//g' $HTODIR/-home-ubuntu-musl-src-complex-cimag.h
export BUILD2=$HOME/muslbuild2
export HTODIR2=$HOME/muslhto2
rm -rf $BUILD2
mkdir -p $BUILD2
cd $BUILD2
rm -rf $HTODIR2
mkdir -p $HTODIR2
export CFLAGS="-mllvm -hto_dir=$HTODIR2 -htoinclude=$HTODIR -Rannotation -mllvm -attributor-enable=all -mllvm -hto_nostring=true -O3"
$HOME/musl/configure --host=x86_64 --prefix=$INSTALL --syslibdir=$INSTALL/lib --disable-shared --disable-werror --with-clang --disable-float128 --with-lld --with-default-link --disable-multi-arch
cd $BUILD2
make -j
sed -i 's/arg_attr(2, "returned")//g' $HTODIR2/-home-ubuntu-musl-src-complex-cimag.h

export BUILD3=$HOME/muslbuild3
export HTODIR3=$HOME/muslhto3
rm -rf $BUILD3
mkdir -p $BUILD3
cd $BUILD3
rm -rf $HTODIR3
mkdir -p $HTODIR3
export CFLAGS="-mllvm -hto_dir=$HTODIR3 -htoinclude=$HTODIR2 -Rannotation -mllvm -attributor-enable=all -mllvm -hto_nostring=true -O3"
$HOME/musl/configure --host=x86_64 --prefix=$INSTALL --syslibdir=$INSTALL/lib --disable-shared --disable-werror --with-clang --disable-float128 --with-lld --with-default-link --disable-multi-arch
cd $BUILD3
make -j
sed -i 's/arg_attr(2, "returned")//g' $HTODIR3/-home-ubuntu-musl-src-complex-cimag.h

export BUILD4=$HOME/muslbuild4
export HTODIR4=$HOME/muslhto4
rm -rf $BUILD4
mkdir -p $BUILD4
cd $BUILD4
rm -rf $HTODIR4
mkdir -p $HTODIR4
export CFLAGS="-mllvm -hto_dir=$HTODIR4 -htoinclude=$HTODIR3 -Rannotation -mllvm -attributor-enable=all -mllvm -hto_nostring=true -O3"
$HOME/musl/configure --host=x86_64 --prefix=$INSTALL --syslibdir=$INSTALL/lib --disable-shared --disable-werror --with-clang --disable-float128 --with-lld --with-default-link --disable-multi-arch
cd $BUILD4
make -j
sed -i 's/arg_attr(2, "returned")//g' $HTODIR4/-home-ubuntu-musl-src-complex-cimag.h

export BUILD5=$HOME/muslbuild5
export HTODIR5=$HOME/muslhto5
rm -rf $BUILD5
mkdir -p $BUILD5
cd $BUILD5
rm -rf $HTODIR5
mkdir -p $HTODIR5
export CFLAGS="-mllvm -hto_dir=$HTODIR5 -htoinclude=$HTODIR4 -Rannotation -mllvm -attributor-enable=all -mllvm -hto_nostring=true -O3"
$HOME/musl/configure --host=x86_64 --prefix=$INSTALL --syslibdir=$INSTALL/lib --disable-shared --disable-werror --with-clang --disable-float128 --with-lld --with-default-link --disable-multi-arch
cd $BUILD5
make -j
sed -i 's/arg_attr(2, "returned")//g' $HTODIR5/-home-ubuntu-musl-src-complex-cimag.h

export BUILD6=$HOME/muslbuild6
export HTODIR6=$HOME/muslhto6
rm -rf $BUILD6
mkdir -p $BUILD6
cd $BUILD6
rm -rf $HTODIR6
mkdir -p $HTODIR6
export CFLAGS="-mllvm -hto_dir=$HTODIR6 -htoinclude=$HTODIR5 -Rannotation -mllvm -attributor-enable=all -mllvm -hto_nostring=true -O3"
$HOME/musl/configure --host=x86_64 --prefix=$INSTALL --syslibdir=$INSTALL/lib --disable-shared --disable-werror --with-clang --disable-float128 --with-lld --with-default-link --disable-multi-arch
cd $BUILD6
make -j
sed -i 's/arg_attr(2, "returned")//g' $HTODIR6/-home-ubuntu-musl-src-complex-cimag.h

export BUILD7=$HOME/muslbuild7
export HTODIR7=$HOME/muslhto7
rm -rf $BUILD7
mkdir -p $BUILD7
cd $BUILD7
rm -rf $HTODIR7
mkdir -p $HTODIR7
export CFLAGS="-mllvm -hto_dir=$HTODIR7 -htoinclude=$HTODIR6 -Rannotation -mllvm -attributor-enable=all -mllvm -hto_nostring=true -O3"
$HOME/musl/configure --host=x86_64 --prefix=$INSTALL --syslibdir=$INSTALL/lib --disable-shared --disable-werror --with-clang --disable-float128 --with-lld --with-default-link --disable-multi-arch
cd $BUILD7
make -j
sed -i 's/arg_attr(2, "returned")//g' $HTODIR7/-home-ubuntu-musl-src-complex-cimag.h

export BUILD8=$HOME/muslbuild8
export HTODIR8=$HOME/muslhto8
rm -rf $BUILD8
mkdir -p $BUILD8
cd $BUILD8
rm -rf $HTODIR8
mkdir -p $HTODIR8
export CFLAGS="-mllvm -hto_dir=$HTODIR8 -htoinclude=$HTODIR7 -Rannotation -mllvm -attributor-enable=all -mllvm -hto_nostring=true -O3"
$HOME/musl/configure --host=x86_64 --prefix=$INSTALL --syslibdir=$INSTALL/lib --disable-shared --disable-werror --with-clang --disable-float128 --with-lld --with-default-link --disable-multi-arch
cd $BUILD8
make -j
sed -i 's/arg_attr(2, "returned")//g' $HTODIR8/-home-ubuntu-musl-src-complex-cimag.h

find $HTODIR8 -type f -exec sed -i -E "s/restrict//g" {} \;

find $HTODIR8 -type f -exec sed -i -E "s/new,/,/g" {} \;
find $HTODIR8 -type f -exec sed -i -E "s/new\)/\)/g" {} \;
find $HTODIR8 -type f -exec sed -i -E "s/class,/,/g" {} \;
find $HTODIR8 -type f -exec sed -i -E "s/class\)/\)/g" {} \;
find $HTODIR8 -type f -exec sed -i -E "s/template,/,/g" {} \;
find $HTODIR8 -type f -exec sed -i -E "s/template\)/\)/g" {} \;








