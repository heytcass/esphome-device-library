{
  description = "ESPHome Device Library - Community device configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # ESPHome for validation and development
            esphome

            # Git for version control
            git

            # Python for any scripting needs
            python311

            # YAML linting (optional but helpful)
            yamllint
          ];

          shellHook = ''
            echo "🏠 ESPHome Device Library Development Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📦 Available commands:"
            echo "  • esphome config <file>  - Validate configuration"
            echo "  • esphome compile <file> - Compile firmware"
            echo "  • git                    - Version control"
            echo "  • yamllint <file>        - Lint YAML files"
            echo ""
            echo "📝 Quick validation:"
            echo "  esphome config examples/local-development/wyzeoutdoor1.yaml"
            echo ""
            echo "💡 See docs/DEVELOPMENT.md for full workflow"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          '';
        };

        # Optional: Add a formatter for nix files
        formatter = pkgs.nixpkgs-fmt;
      });
}
