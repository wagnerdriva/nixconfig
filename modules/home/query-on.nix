{ lib, queryOnPackage ? null, ... }: {
  # Keep Query On off hosts that use the minimal agent setup.
  home.packages = lib.optional (queryOnPackage != null) queryOnPackage;
}
