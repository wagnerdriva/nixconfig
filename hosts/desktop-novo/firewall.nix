{ config, lib, ... }:
let
  # Ingress policy for servidor-principal (WP-67): outbound is free; inbound is
  # accepted only on tailscale0 (trusted, see ./tailscale.nix). NetBird (wt0)
  # only gets the Driva proxy middleware; LAN and every other interface get
  # nothing.
  netbirdIf = config.services.netbird.clients.default.interface;
  netbirdTCPPorts = [ 8317 ];

  # Docker publishes ports on these addresses, which skips the INPUT chain.
  tailscaleAddrs4 = [ "100.116.195.114" ];
  tailscaleAddrs6 = [ "fd7a:115c:a1e0::aa2d:c373" ];
  # Local traffic (lo) and containers (docker bridges) may also target them.
  tailscaleAddrSources = [ "tailscale0" "lo" "docker0" "br-+" ];

  # Only containers and tailnet peers may open forwarded connections.
  forwardSources = [ "tailscale0" "docker0" "br-+" ];

  forEach = list: f: lib.concatMapStrings f list;

  # NetBird's nftables manager inserts `-i wt0 -j ACCEPT` at the top of the
  # iptables filter INPUT and FORWARD chains, ahead of nixos-fw and DOCKER-USER.
  # These chains live in raw/mangle, separate base chains where a DROP is final
  # no matter what filter accepts later.
  removeIngressChains = ''
    ingress_unhook() {
      while $1 -w -t "$2" -D "$3" -j "$4" 2>/dev/null; do :; done
      $1 -w -t "$2" -F "$4" 2>/dev/null || true
      $1 -w -t "$2" -X "$4" 2>/dev/null || true
    }
    for ipt in iptables ip6tables; do
      ingress_unhook "$ipt" raw PREROUTING ingress-pre
      ingress_unhook "$ipt" mangle INPUT ingress-in
      ingress_unhook "$ipt" mangle FORWARD ingress-fwd
    done
  '';
in
{
  networking.firewall = {
    allowPing = false;
    interfaces.${netbirdIf}.allowedTCPPorts = netbirdTCPPorts;

    extraCommands = ''
      ${removeIngressChains}
      ip46tables -t raw -N ingress-pre
      ip46tables -t mangle -N ingress-in
      ip46tables -t mangle -N ingress-fwd

      # Weak host model: on wt0 accept only destinations assigned to wt0 itself.
      ip46tables -t raw -A ingress-pre -i ${netbirdIf} -m addrtype ! --dst-type LOCAL --limit-iface-in -j DROP
      iptables -w -t raw -A ingress-pre -d 127.0.0.0/8 ! -i lo -j DROP
      ${forEach tailscaleAddrs4 (addr: ''
        ${forEach tailscaleAddrSources (iface: ''
          iptables -w -t raw -A ingress-pre -d ${addr} -i ${iface} -j RETURN
        '')}
        iptables -w -t raw -A ingress-pre -d ${addr} -j DROP
      '')}
      ${forEach tailscaleAddrs6 (addr: ''
        ${forEach tailscaleAddrSources (iface: ''
          ip6tables -w -t raw -A ingress-pre -d ${addr} -i ${iface} -j RETURN
        '')}
        ip6tables -w -t raw -A ingress-pre -d ${addr} -j DROP
      '')}

      ip46tables -t mangle -A ingress-in -i ${netbirdIf} -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN
      ${forEach netbirdTCPPorts (port: ''
        ip46tables -t mangle -A ingress-in -i ${netbirdIf} -p tcp --dport ${toString port} -j RETURN
      '')}
      ip46tables -t mangle -A ingress-in -i ${netbirdIf} -j DROP

      ip46tables -t mangle -A ingress-fwd -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN
      ${forEach forwardSources (iface: ''
        ip46tables -t mangle -A ingress-fwd -i ${iface} -j RETURN
      '')}
      ip46tables -t mangle -A ingress-fwd -j DROP

      ip46tables -t raw -I PREROUTING 1 -j ingress-pre
      ip46tables -t mangle -I INPUT 1 -j ingress-in
      ip46tables -t mangle -I FORWARD 1 -j ingress-fwd
    '';
    extraStopCommands = removeIngressChains;
  };

  # SSH only through tailscale0 (trusted).
  services.openssh.openFirewall = lib.mkForce false;
  # Drops mDNS (5353/udp) on the LAN: no more .local discovery of this host.
  services.avahi.openFirewall = lib.mkForce false;
  services.netbird.clients.default = {
    # WireGuard 51820/udp: P2P still works through outbound hole punching
    # (conntrack), and falls back to the NetBird relay otherwise.
    openFirewall = false;
    # 5353/22054 udp on wt0 is the DNS forwarder of routing peers; this host
    # routes nothing (Networks: -).
    openInternalFirewall = false;
  };
}
