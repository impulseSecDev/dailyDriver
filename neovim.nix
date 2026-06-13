{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    colorschemes.tokyonight = {
      enable = true;
      settings = {
        transparent = false;
        styles = {
          comments = { italic = true; };
          keywords = { bold = true; italic = true; };
          functions = { italic = true; };
          variables = {};
          sidebars = "dark";
          floats = "dark";
        };
        italic_comments = true;
        italic_keywords = true;
        italic_functions = true;
        italic_variables = false;
      };
    };

    opts = {
      number = true;
      relativenumber = true;
      cursorline = true;
      list = true;
      termguicolors = true;
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;
      smartindent = true;
      wrap = true;
      scrolloff = 8;
      signcolumn = "yes";
      updatetime = 50;
      colorcolumn = "80";
    };

    globals = {
      mapleader = " ";
    };

    keymaps = [
      { mode = "n"; key = "<leader>e"; action = "<cmd>NvimTreeToggle<CR>"; options = { silent = true; noremap = true; desc = "Toggle file tree"; }; }
      { mode = "n"; key = "<leader>h"; action = "<cmd>ToggleTerm<CR>"; options = { silent = true; noremap = true; desc = "Toggle terminal"; }; }
      { mode = "t"; key = "<Esc>"; action = "<C-\\><C-n>"; options = { silent = true; noremap = true; }; }
      { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<CR>"; options = { silent = true; noremap = true; desc = "Find files"; }; }
      { mode = "n"; key = "<leader>fw"; action = "<cmd>Telescope live_grep<CR>"; options = { silent = true; noremap = true; desc = "Live grep"; }; }
      { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<CR>"; options = { silent = true; noremap = true; desc = "Buffers"; }; }
      { mode = "n"; key = "<leader>fh"; action = "<cmd>Telescope help_tags<CR>"; options = { silent = true; noremap = true; desc = "Help tags"; }; }
      { mode = "n"; key = "<leader>w"; action = ":w<CR>"; options = { silent = true; noremap = true; desc = "Save"; }; }
      { mode = "n"; key = "<leader>q"; action = ":q<CR>"; options = { silent = true; noremap = true; desc = "Quit"; }; }
      { mode = "n"; key = "<leader>Q"; action = ":qa!<CR>"; options = { silent = true; noremap = true; desc = "Force quit all"; }; }
      { mode = "n"; key = "<C-d>"; action = "<C-d>zz"; options = { silent = true; noremap = true; }; }
      { mode = "n"; key = "<C-u>"; action = "<C-u>zz"; options = { silent = true; noremap = true; }; }
      { mode = "n"; key = "n"; action = "nzzzv"; options = { silent = true; noremap = true; }; }
      { mode = "n"; key = "N"; action = "Nzzzv"; options = { silent = true; noremap = true; }; }
      { mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv"; options = { silent = true; noremap = true; }; }
      { mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv"; options = { silent = true; noremap = true; }; }
      { mode = "v"; key = "<"; action = "<gv"; options = { silent = true; noremap = true; }; }
      { mode = "v"; key = ">"; action = ">gv"; options = { silent = true; noremap = true; }; }
      { mode = "n"; key = "K"; action.__raw = "vim.lsp.buf.hover"; options = { silent = true; noremap = true; desc = "Hover"; }; }
      { mode = "n"; key = "gd"; action.__raw = "vim.lsp.buf.definition"; options = { silent = true; noremap = true; desc = "Go to definition"; }; }
      { mode = "n"; key = "<leader>ca"; action.__raw = "vim.lsp.buf.code_action"; options = { silent = true; noremap = true; desc = "Code action"; }; }
      { mode = "n"; key = "<leader>rn"; action.__raw = "vim.lsp.buf.rename"; options = { silent = true; noremap = true; desc = "Rename"; }; }
      { mode = "n"; key = "gr"; action.__raw = "vim.lsp.buf.references"; options = { silent = true; noremap = true; desc = "References"; }; }
    ];

    # Installs the plugin binary package without executing the default Nixvim configuration wrapper
    extraPlugins = with pkgs.vimPlugins; [
      indent-blankline-nvim
    ];

    plugins = {
      web-devicons.enable = true;
      lualine.enable = true;
      rainbow-delimiters.enable = true;

      nvim-tree = {
        enable = true;
        settings = {
          sort_by = "name";
          hijack_netrw = true;
          view = {
            width = 30;
            side = "left";
          };
          renderer.icons.show = {
            git = true;
            folder = true;
            file = true;
            folder_arrow = true;
          };
          update_focused_file = {
            enable = true;
            update_cwd = true;
          };
        };
      };

      toggleterm.enable = true;
      telescope.enable = true;

      which-key = {
        enable = true;
        settings.spec = [
          { __unkeyed-1 = "<leader>s"; group = "Snippets"; }
        ];
      };

      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          incremental_selection.enable = true;
          indent.enable = true;
        };
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          lua
          nix
          bash
          json
          yaml
          markdown
          python
          javascript
          typescript
          html
          css
        ];
      };

      treesitter-textobjects.enable = true;

      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          lua_ls = {
            enable = true;
            settings.Lua.diagnostics.globals = [ "vim" ];
          };
          pyright.enable = true;
          bashls.enable = true;
          jsonls.enable = true;
          marksman.enable = true;
          ts_ls.enable = true;
        };
      };

      cmp = {
        enable = true;
        settings = {
          snippet.expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
          window = {
            completion.__raw = "require('cmp').config.window.bordered()";
            documentation.__raw = "require('cmp').config.window.bordered()";
          };
          mapping = {
            "<C-b>".__raw = "require('cmp').mapping.scroll_docs(-4)";
            "<C-f>".__raw = "require('cmp').mapping.scroll_docs(4)";
            "<C-Space>".__raw = "require('cmp').mapping.complete()";
            "<C-e>".__raw = "require('cmp').mapping.abort()";
            "<CR>".__raw = "require('cmp').mapping.confirm({ select = true })";
            "<Tab>".__raw = ''
              require('cmp').mapping(function(fallback)
                local cmp = require('cmp')
                local luasnip = require('luasnip')
                if cmp.visible() then
                  cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                else
                  fallback()
                end
              end, { 'i', 's' })
            '';
            "<S-Tab>".__raw = ''
              require('cmp').mapping(function(fallback)
                local cmp = require('cmp')
                local luasnip = require('luasnip')
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                  luasnip.jump(-1)
                else
                  fallback()
                end
              end, { 'i', 's' })
            '';
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "nvim_lsp_signature_help"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
        };
      };

      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp-cmdline.enable = true;
      cmp-nvim-lsp-signature-help.enable = true;

      lspkind = {
        enable = true;
        settings.cmp = {
          max_width = 50;
          ellipsis_char = "...";
          menu = {};
        };
      };

      luasnip = {
        enable = true;
        settings.enable_autosnippets = true;
        fromVscode = [{}];
      };
      friendly-snippets.enable = true;
    };

    # Run the exact Lua snippet sequentially to completely avoid VIMINIT load errors
    extraConfigLua = ''
      local highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
      end)
      
      require("ibl").setup {
        indent = {
          highlight = highlight,
          char = "│",
        },
        scope = {
          enabled = true;
          show_start = true;
          show_end = true;
        }
      }
    '';
  };
}

