{ ... }: {
  # Usuário dedicado do Jarvis (assistente), acesso só por chave SSH.
  users.users.jarvis = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjpONWCsh2Sk/JmiROWtncIxB82ZzFPOtr5bG31KNZy jarvis-box" ];
  };
  security.sudo.extraRules = [{
    users = [ "jarvis" ];
    commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
  }];
}
