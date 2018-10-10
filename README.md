This is meta-repository to build entire CeGCC toolchain.

Clone this repository using:

```
git clone git://github.com/MaxKellermann/cegcc-build
```

To build:

```
cd cegcc-build
git submodule init
git submodule update
cd build-arm-mingw32ce
mkdir build-mingw32ce
cd build-mingw32ce
sh ../build-mingw32ce.sh --prefix=/where/to/install
```

If you won't specify `--prefix`, it will install to `cegcc-build/bindist-arm-mingw32ce/`.

To update afterwards:

```
git pull
git submodule update
cd build-arm-mingw32ce/build-mingw32ce
sh ../build-mingw32ce.sh --prefix=/where/to/install
```

(After update, to get 100% clean-room, you may want to rebuild
everything from scratch.)

# Errors

## Binutils

> gcc -c -I. -I/home/geier/work/ka/cegcc-build/binutils/binutils -W -Wall -Wstrict-prototypes -Wmissing-prototypes -Wshadow -Wstack-usage=262144 -I/home/geier/work/ka/cegcc-build/binutils/binutils/../zlib -g -O2  /home/geier/work/ka/cegcc-build/binutils/binutils/syslex_wrap.c
> /home/geier/work/ka/cegcc-build/binutils/binutils/syslex_wrap.c:25:10: fatal error: syslex.c: No such file or directory
>  #include "syslex.c"
>           ^~~~~~~~~~
> compilation terminated.
> make[2]: *** [Makefile:1375: syslex_wrap.o] Error 1
> make[2]: Leaving directory '/home/geier/work/ka/cegcc-build/build-arm-mingw32ce/binutils/binutils'
> make[1]: *** [Makefile:3575: all-binutils] Error 2
> make[1]: Leaving directory '/home/geier/work/ka/cegcc-build/build-arm-mingw32ce/binutils'
> make: *** [Makefile:849: all] Error 2

Configure has been called from a wrong directory, probably the whole
build script has been called from a wrong directory.

## GCC

### Missing libraries

> checking for the correct version of gmp.h... no
> configure: error: Building GCC requires GMP 4.2+, MPFR 2.3.1+ and MPC 0.8.0+.
> Try the --with-gmp, --with-mpfr and/or --with-mpc options to specify
> their locations.  Source code for these libraries can be found at
> their respective hosting sites as well as at
> ftp://gcc.gnu.org/pub/gcc/infrastructure/.  See also
> http://gcc.gnu.org/install/prerequisites.html for additional info.  If
> you obtained GMP, MPFR and/or MPC from a vendor distribution package,
> make sure that you have installed both the libraries and the header
> files.  They may be located in separate packages.


Simply call `./contrib/download_prerequisites.sh` in gcc (in the source
directory) and re run everything.

### Compilation Error `-Werror=format-security`

> /home/geier/work/ka/cegcc-build/gcc/libcpp/expr.c: In function ‘unsigned int cpp_classify_number(cpp_reader*, const cpp_token*, const char**, source_location)’:
> /home/geier/work/ka/cegcc-build/gcc/libcpp/expr.c:770:18: error: format not a string literal and no format arguments [-Werror=format-security]
>         0, message);
>                   ^
> /home/geier/work/ka/cegcc-build/gcc/libcpp/expr.c:773:39: error: format not a string literal and no format arguments [-Werror=format-security]
>            virtual_location, 0, message);
>                                        ^
> cc1plus: some warnings being treated as errors

Usually a problem with system hardening policy, i.e. for nix, invoking a
nix-shell with `hardeningDisable = [ "format" ];` helps. (compare to `default.nix` file in the root directory).

  * <https://wiki.debian.org/Hardening#Using_Hardening_Options>
  * <https://nixos.org/releases/nixpkgs/nixpkgs-16.09pre90369.202d9e2/manual/#sec-hardening-in-nixpkgs>
