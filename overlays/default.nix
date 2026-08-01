final: prev: {
  swaynotificationcenter = prev.swaynotificationcenter.overrideAttrs (old: {
    patches = (old.patches or []) ++ [../patches/swaync-remove-close-button.patch];
  });

  vimPlugins =
    prev.vimPlugins
    // {
      codestats-nvim = final.vimUtils.buildVimPlugin {
        pname = "codestats-nvim";
        version = "0.0.1";
        src = final.fetchFromGitHub {
          owner = "YannickFricke";
          repo = "codestats.nvim";
          rev = "076b101e9e1b97007e3a29dfd03d2148883b024d";
          sha256 = "sha256-CVM2rDVDLfSaWX3TrWK4EAFgaUK+AAX19jYZXhfKYVQ=";
        };
        dependencies = [ final.vimPlugins.plenary-nvim ];
      };
      harpoon = final.vimUtils.buildVimPlugin {
        pname = "harpoon";
        version = "2";
        src = final.fetchFromGitHub {
          owner = "ThePrimeagen";
          repo = "harpoon";
          rev = "87b1a3506211538f460786c23f98ec63ad9af4e5";
          sha256 = "sha256-qQSPVMdldksNZDPZvnTiXxty+GSUqMGz8nYEFDRezrQ=";
        };
        dependencies = [ final.vimPlugins.plenary-nvim ];
      };
    };
}
