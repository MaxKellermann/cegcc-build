This is meta-repository to build entire CeGCC toolchain.

Clone this repository using::

 git clone git://github.com/MaxKellermann/cegcc-build

To build::

 cd cegcc-build
 git submodule init
 git submodule update
 cd build-arm-mingw32ce
 mkdir build-mingw32ce
 cd build-mingw32ce
 sh ../build-mingw32ce.sh --prefix=/where/to/install

If you won't specify `--prefix`, it will install to
`cegcc-build/bindist-arm-mingw32ce/`

To update afterwards::

 git pull
 git submodule update
 cd build
 ./build-mingw32ce.sh --prefix=/where/to/install

(After update, to get 100% clean-room, you may want to rebuild
everything from scratch.)
