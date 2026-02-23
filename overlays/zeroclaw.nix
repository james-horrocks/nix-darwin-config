{ lib, rustPlatform, pkgs }: rustPlatform.buildRustPackage {  
  inherit (pkgs.zeroclaw) version;  
  pname = "zeroclaw";  
  src = rustPlatform.fetchRustCrateOverridden {  
    inherit version;  
    source = pkgs.fetchFromGitHub {  
      owner = "zeroclaw-labs";  
      repo = "zeroclaw";  
      rev = "v0.1.6";  
      src = "https://github.com/zeroclaw-labs/zeroclaw/archive/v0.1.6.tar.gz";  
    };  
  };  
  nativeBuildInputs = [ pkgs.pkg-config ];  
  doCheck = false;  
  cargoLock.lockFile = pkgs.fetchFromGitHub {  
    owner = "zeroclaw-labs";  
    repo = "zeroclaw";  
    rev = "v0.1.6";  
    path = "Cargo.lock";  
  };  
}