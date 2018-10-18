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
mkdir build
cd build
sh ../build-mingw32ce.sh --prefix=/where/to/install
```

If you won't specify `--prefix`, it will install to `cegcc-build/bindist-arm-mingw32ce/`. I specified `~/.local-arm-cegcc/` 

To update afterwards:

```
git pull
git submodule update
cd build
sh ../build-mingw32ce.sh --prefix=/where/to/install
```

(After update, to get 100% clean-room, you may want to rebuild
everything from scratch.)

To build the tool chain step by step, look at `build-mingw32ce.sh` line 24 where an array of components is listed.
First `binutils` is installed, then all required headers are copied before gcc is bootstraped.
Then mingw and the win32api are built and installed before finally the full gcc and libgcc are build and installed.

You can put one component at once at the list i.e. `COMPONENTS=( bootstrap_gcc )` to re-run only specific parts of the tool chain.

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

This is the reason why the build script has been slightly reorganized from Max Kellermann where the error naturally occured for me.

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

## libgcc

> checking how to run the C preprocessor... /lib/cpp
> configure: error: in `/home/geier/work/ka/cegcc-build/build-arm-mingw32ce/build-mingw32ce/gcc-bootstrap/arm-mingw32ce/libgcc':
> configure: error: C preprocessor "/lib/cpp" fails sanity check
> See `config.log' for more details.
> make: *** [Makefile:13029: configure-target-libgcc] Error 1

The installation assumes to find a compiler at `/lib/cpp`. This is not the case on all systems. 
If you have a working compiler at `/usr/bin/cpp` you can create a symlink `ln -s /usr/bin/cpp /lib/cpp` or simpler set
 the `CPP` variable properly before calling any script, 
i.e. `export CPP=\`which cpp\`` or `CPP=\`which cpp\` sh ../build-mingw32ce.sh --prefix=/where/to/install`.
If this also causes problems, look in `build-mingw32ce.sh`, jump to the function `build_bootstrap_gcc` and `build_gcc` and set `CPP` before `configure_host_module`.
On a linux environment, make sure `cpp` links to gcc's preprocessor and not clang's.
Compare to <https://www.mail-archive.com/cegcc-devel@lists.sourceforge.net/msg02259.html>, <https://stackoverflow.com/questions/43763527/compile-gcc-7-error-c-preprocessor-lib-cpp-fails-sanity-check>.


## win32api

The win32api has forked to apply a small fix in `libce/Makefile.in` where `AS_FOR_TARGET` has referenced to itself by `${AS_FOR_TARGET}`. 
Problem was resolved by accessing the proper makefile variable `@AS_FOR_TARGET@` instead of `${AS_FOR_TARGET}`

# Helpfull stuff

    * <http://www.nathancoulson.com/proj_cross.php>
