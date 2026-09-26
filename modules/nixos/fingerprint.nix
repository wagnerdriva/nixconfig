{ ... }: {
  # Enabling fprintd turns on pam_fprintd for every PAM service by default.
  # Keep it for sudo and polkit, but not for the session login: only a password
  # unlocks the GNOME keyring, and tuigreet would otherwise wait for a finger
  # before asking for the password. The DMS lock screen runs its own fingerprint
  # PAM context in parallel with the password, so login needs no fprintd.
  services.fprintd.enable = true;

  security.pam.services = {
    login.fprintAuth = false;
    greetd.fprintAuth = false;
  };
}
