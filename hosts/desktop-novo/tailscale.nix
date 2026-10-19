{ ... }: {
  # Tailscale: acesso do Jarvis/Shuri.
  services.tailscale.enable = true;
  # As regras netfilter do Tailscale descartam 100.64.0.0/10 fora do tailscale0 e quebram o NetBird (100.90.0.0/16).
  services.tailscale.extraSetFlags = [ "--netfilter-mode=off" ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
