{ config, pkgs, inputs}

{
  programs.nixvim = {
    colorschemes.gruvbox.enable = true;
    plugins = { 
      lightline.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      
    ];

    opts = {
      number = true;         # Show line numbers
      relativenumber = true; # Show relative line numbers
      shiftwidth = 2;        # Tab width should be 2
    };
  };  
}
