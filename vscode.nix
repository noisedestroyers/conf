{ pkgs }:
let


  ms-vscode-csharp = pkgs.callPackage ./ms-vscode-csharp.nix { };

  extensions = (with pkgs.vscode-extensions; [
    ms-vscode-csharp
    ms-vscode-remote.remote-ssh
  ])
  ++
  pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "python";
      publisher = "ms-python";
      version = "2023.7.10881020";
      sha256 = "sha256-5NqgYonHbNFu6W/Ue68AXGJ7nAC98c8w8q3CVVbrygs=";
    }
    {
      name = "vscode-coverage-gutters";
      publisher = "ryanluker";
      version = "2.4.2";
      sha256 = "1351ix5vp1asny6c2dihf8n18gdqsg5862z6wx2b5yflvslsqjx2";
    }
    {
      name = "nix-ide";
      publisher = "jnoortheen";
      version = "0.1.16";
      sha256 = "04ky1mzyjjr1mrwv3sxz4mgjcq5ylh6n01lvhb19h3fmwafkdxbp";
    }
    {
      name = "direnv";
      publisher = "mkhl";
      version = "0.14.0";
      sha256 = "T+bt6ku+zkqzP1gXNLcpjtFAevDRiSKnZaE7sM4pUOs=";
    }
    {
      name = "powershell";
      publisher = "ms-vscode";
      version = "2023.3.2";
      sha256 = "sha256-0ueodXRwYnelSwP1MMbgHJFio41kVf656dg6Yro8+hE=";
    }
  ];
  vscode = pkgs.vscode-with-extensions.override {
    vscodeExtensions = extensions;
  };
in
vscode


