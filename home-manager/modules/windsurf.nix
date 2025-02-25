{ pkgs, ... }:
let
  # https://windsurf-stable.codeiumdata.com/linux-x64/stable/d08b8ea13d580d24be204c76e5dd1651d7234cd2/Windsurf-linux-x64-1.2.6.tar.gz
  version = "1.2.6"; # "windsurfVersion"
  urlHash = "d08b8ea13d580d24be204c76e5dd1651d7234cd2"; # "version"
  hash = "sha256-rXHrArkwLUzxQTwKg3Y/Rf5FXlvnTunhR3vqLoWgLKo=";

  windsurf = pkgs.callPackage (pkgs.path + "/pkgs/applications/editors/vscode/generic.nix") {
    pname = "windsurf";
    executableName = "windsurf";
    longName = "Windsurf";
    shortName = "windsurf";
    version = version;
    src = pkgs.fetchurl {
      inherit hash;
      url = "https://windsurf-stable.codeiumdata.com/linux-x64/stable/${urlHash}/Windsurf-linux-x64-${version}.tar.gz";
    };
    sourceRoot = "Windsurf";
    commandLineArgs = "";
    meta = {
      description = "The first agentic IDE, and then some";
    };
    updateScript = "";
  };
in
{
  home.packages = with pkgs; [
    windsurf
  ];
}

