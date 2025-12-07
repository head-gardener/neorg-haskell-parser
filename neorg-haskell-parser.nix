{ mkDerivation, aeson, base, bytestring, containers, directory
, filepath, hspec, HUnit, lib, megaparsec, optics-core
, optparse-applicative, pandoc-types, text, transformers
, typed-process
}:
mkDerivation {
  pname = "neorg";
  version = "0.2.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base containers megaparsec optics-core pandoc-types text
    transformers
  ];
  executableHaskellDepends = [
    aeson base bytestring containers optics-core optparse-applicative
    pandoc-types text transformers
  ];
  testHaskellDepends = [
    aeson base containers directory filepath hspec HUnit optics-core
    text transformers typed-process
  ];
  homepage = "https://github.com/Simre1/neorg-haskell-parser";
  description = "Transform norg documents into PDFs with pandoc";
  license = lib.licenses.mit;
  mainProgram = "neorg-pandoc";
}
