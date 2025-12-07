spec:
  git submodule update --init
  cabal run neorg-pandoc -- -f ./norg-specs/1.0-specification.norg
