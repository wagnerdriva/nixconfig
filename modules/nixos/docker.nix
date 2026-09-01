{ pkgs, primaryUser, ... }: {
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;

    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
  };

  users.users.${primaryUser}.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    docker-buildx
    docker-compose
  ];
}
