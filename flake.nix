{
  description = "Delopy";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    # Helpers for system-specific outputs
    flake-utils.url = "github:numtide/flake-utils";
    
  };

  outputs = { self, nixpkgs, flake-utils }: {
    defaultPackage.x86_64-darwin = self.packages.x86_64-darwin.chk-setup;

    packages.x86_64-darwin.chk-setup = 
      let
        system = "x86_64-darwin";
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            self.overlays.default
          ];
        };
        var-name = "chk-setup";
        var-source = builtins.readFile ./deploy.sh;
        setup-machines = (pkgs.writeScriptBin var-name var-source).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
        var-buildInputs = with pkgs; [
          jdk11_headless
          python310Full
          python310Packages.PyLD
          python310Packages.pipx
          python310Packages.pytest
          python310Packages.pyhocon
          python310Packages.pyparsing
          python310Packages.sphinx
          python310Packages.tox
          python310Packages.ansible-runner
        ]; 
      in {
        overlays.default =  (self: super: rec {});
        pkgs.symlinkJoin = {
          name = var-name;
          paths = [ setup-machines ] ++ var-buildInputs;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${var-name} --prefix PATH : $out/bin";
        };
      };
  };
}

