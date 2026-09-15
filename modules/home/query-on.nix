{ lib, queryOnPackage ? null, ... }: {
  # Query On is an optional private input. Keep the module harmless when the
  # package is not supplied by the flake, which is the default installation
  # path for new machines.
  home.packages = lib.optional (queryOnPackage != null) queryOnPackage;
}
