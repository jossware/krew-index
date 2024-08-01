{
  description = "krew-index";

  inputs = {
    nixpkgs.url = "nixpkgs"; # Resolves to github:NixOS/nixpkgs
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib;

        krew-release-bot = pkgs.buildGoModule rec {
          pname = "krew-release-bot";
          version = "0.0.46";

          src = pkgs.fetchFromGitHub {
            rev = "v${version}";
            owner = "rajatjindal";
            repo = "krew-release-bot";
            sha256 = "sha256-73r4kT+J5DeAx0g5RcLBIJwBrXfmRwjRXFoEhmEVu/M=";
          };

          vendorHash = null;

          nativeBuildInputs = [ pkgs.installShellFiles ];

          subPackages = [ "cmd/action" ];

          CGO_ENABLED = 0;

          ldflags = [
            "-s"
            "-w"
          ];

          # Rename the output binary
          postInstall = ''
            mv $out/bin/action $out/bin/krew-release-bot
          '';

          doCheck = false;
        };
      in
      with pkgs;
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            kubectl
            krew
            krew-release-bot
          ];
        };
      }
    );
}
