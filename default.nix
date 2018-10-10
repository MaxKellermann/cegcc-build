with import <nixpkgs> {};
#stdenv.mkDerivation rec {
stdenvNoCC.mkDerivation rec {
  name = "cegcc";
  env = buildEnv { name = name; paths = buildInputs; };
  hardeningDisable = [ "format" ];  # to build the cross-compiler, otherwise  there ar erros with -Werror=format-security
  buildInputs = [
    bison
    flex
    gmp       # required for gcc
    mpfr      # required for gcc
    libmpc    # required for gcc
  ];
}
