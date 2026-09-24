{ ... }: {
  # NetworkManager passes each Wi-Fi network's DNS servers to resolved. NetBird
  # can then register its domains per interface instead of retaining a stale
  # resolvconf upstream after roaming to a different network.
  services.resolved.enable = true;

  services.netbird = {
    enable = true;
    ui.enable = true;

    # Authentication stays local to the machine; only the Driva management
    # endpoint is part of the public configuration.
    # NetBird 0.71 stores net/url.URL values as JSON objects rather than
    # strings in config.json.
    clients.default.config.ManagementURL = {
      Scheme = "https";
      Host = "netbird.driva.io:443";
    };
  };
}
