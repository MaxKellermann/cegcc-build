with import <nixpkgs> {};
#stdenv.mkDerivation rec {
#NoCC important to overwrite compiler..
stdenvNoCC.mkDerivation rec {
  name = "cegcc";
  env = buildEnv { name = name; paths = buildInputs; };
  hardeningDisable = [ "format" ];  # to build the cross-compiler, otherwise  there ar erros with -Werror=format-security
  buildInputs = [
    gcc       # make sure gcc is used to link the C preprocessor cpp properly
    bison
    flex
    gmp       # required for gcc
    mpfr      # required for gcc
    libmpc    # required for gcc
  ];
}
