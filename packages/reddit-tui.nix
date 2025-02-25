{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "reddit-tui";
  version = "0.1.0";  # You may want to update this based on latest release

  src = fetchFromGitHub {
    owner = "tonymajestro";
    repo = "reddit-tui";
    rev = "master";  # You might want to pin this to a specific commit or tag
    sha256 = "sha256-Lby1SwOHi96zNL4GD+1n/VKVAd1r78e9FvJzTRN6XtA=";
  };

  vendorHash = "sha256-L3iJXcs98A3fUw8vLVb5JWlku8+vGaICsUxKRCuRph0=";

  meta = with lib; {
    description = "Terminal UI for Reddit";
    homepage = "https://github.com/tonymajestro/reddit-tui";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "reddittui";
    platforms = platforms.unix;
  };
}
