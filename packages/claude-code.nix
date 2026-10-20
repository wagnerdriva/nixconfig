{ claude-code }:

# Track the official native release independently of the pinned NixOS channel,
# while keeping Nixpkgs' runtime dependencies, sandbox helpers and version check.
# Checksums: https://downloads.claude.ai/claude-code-releases/2.1.304/manifest.json
claude-code.override {
  manifest = {
    version = "2.1.304";
    platforms = {
      linux-x64.checksum = "ea0f135784631619a7a409d07322ecec964f9cc4fd377508ed1ba3f141f27912";
      linux-arm64.checksum = "c487117526509ab6d2ee6013e14f181faf68d6d6afe6bb0d4b2b4a9feca5ecb3";
      darwin-x64.checksum = "f2ae409b46b1bdc1dec7afa12c6a094ff64e7d4ca272ca09f69dd0080c846703";
      darwin-arm64.checksum = "b9ac5374839f14abf3f1f45610637c332b5daee5ce0d1634726cef87aab78e6a";
    };
  };
}
