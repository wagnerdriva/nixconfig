{ ... }: {
  # The upstream module already opens UDP 9993 and ships zerotier-cli in the
  # system profile. Networks are joined out of band with `zerotier-cli join`
  # so the network IDs stay out of this public repository; the resulting
  # membership lives in /var/lib/zerotier-one.
  services.zerotierone.enable = true;

  # Every authorized member of the network is a machine we own, so the zt
  # interfaces are trusted instead of punching a per-service hole in the
  # firewall for each of them.
  networking.firewall.trustedInterfaces = [ "zt+" ];
}
