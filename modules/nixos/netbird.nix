{ ... }: {
  services.netbird = {
    enable = true;
    ui.enable = true;

    # Authentication stays local to the machine; only the Driva management
    # endpoint is part of the public configuration.
    clients.default.config.ManagementURL = "https://netbird.driva.io";
  };
}
