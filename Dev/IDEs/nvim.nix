{
  pkgs,
  lib,
  ...
}: let
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    ref = "nixos-25.11"; # match your NixOS version
    # optionally pin a specific commit:
    # get latest by running the following command
    # git ls-remote https://github.com/nix-community/nixvim refs/heads/nixos-25.11
    rev = "b8f76bf5751835647538ef8784e4e6ee8deb8f95";
  });
in {
  imports = [nixvim.nixosModules.nixvim];

  programs.nixvim = {
    enable = true;

    # ============================================================================
    # APPEARANCE
    # ============================================================================

    # Closest maintained dark theme to "Lukin Theme" (custom dark)
    colorschemes.gruvbox = {
      enable = true;
      settings.contrast_dark = "hard";
    };

    # Iosevka font is set in your terminal emulator, not nvim itself.
    # Nvim inherits the terminal font automatically.

    opts = {
      # Line numbers
      number = true;
      relativenumber = false;

      # Indentation
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;

      # Search
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;

      # Editing feel
      wrap = false;
      scrolloff = 8;
      splitright = true; # mirrors VSCode sidebar-on-right feel
      splitbelow = true;

      # Performance / misc
      updatetime = 250;
      termguicolors = true;
      signcolumn = "yes"; # always show, prevents layout shift (like VSCode gutter)
      cursorline = true;

      clipboard = "unnamedplus";
      mouse = "a"; # "a" = all modes
    };

    # ============================================================================
    # FILE EXPLORER (mirrors VSCode Explorer panel)
    # neo-tree gives you a sidebar file tree, equivalent to VSCode's Explorer
    # ============================================================================
    plugins.neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        window = {
          position = "right"; # sidebar on the right, matching your VSCode layout
          width = 35;
        };
        filesystem = {
          filtered_items = {
            visible = true; # show hidden files (you set files.exclude .git = false)
            hide_gitignored = false;
          };
          follow_current_file = {
            enabled = true;
            leave_dirs_open = true;
          };
        };
      };

      # symbols = {
      #     added     = "+";
      #     modified  = "~";
      #     deleted   = "-";
      #     renamed   = "R";
      #     untracked = "?";
      #     ignored   = "!";
      #     unstaged  = "U";
      #     staged    = "S";
      #     conflict  = "X";
      #   };
    };

    # ============================================================================
    # FILE TABS (bufferline = VSCode editor tabs)
    # ============================================================================
    plugins.bufferline = {
      enable = true;
      settings.options = {
        diagnostics = "nvim_lsp";
        show_buffer_close_icons = true;
        show_close_icon = false;
        separator_style = "slant";
      };
    };

    # ============================================================================
    # STATUS LINE (replaces VS Code's bottom status bar)
    # ============================================================================
    plugins.lualine = {
      enable = true;
      settings.options = {
        theme = "gruvbox";
        globalstatus = true;
      };
    };

    # ============================================================================
    # ICONS (material-icon-theme equivalent)
    # nvim-web-devicons provides file-type icons used by neo-tree, bufferline etc.
    # ============================================================================
    plugins.web-devicons.enable = true;

    # ============================================================================
    # SYNTAX HIGHLIGHTING (Tree-sitter — equivalent to VSCode's built-in grammar)
    # ============================================================================
    plugins.treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
        ensureInstalled = [
          "nix"
          "python"
          "c"
          "cpp"
          "rust"
          "dart"
          "zig"
          "bash"
          "lua"
          "json"
          "yaml"
          "toml"
          "markdown"
          "markdown_inline"
          "cmake"
          "sql"
          "typescript"
          "javascript"
          "tsx"
          "html"
          "css"
          "go"
          "java"
          "ruby"
          "haskell"
        ];
      };
    };

    # Rainbow bracket colorization (matches editor.bracketPairColorization)
    plugins.rainbow-delimiters.enable = true;

    # ============================================================================
    # FUZZY FINDER (replaces VSCode Ctrl+P / Ctrl+Shift+F)
    # ============================================================================
    plugins.telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
    };

    # ============================================================================
    # GIT (replaces GitLens / built-in Git panel)
    # ============================================================================
    # plugins.gitsigns = {
    #   enable = true;
    #   settings = {
    #     current_line_blame = true; # inline blame like GitLens
    #     current_line_blame_opts = {delay = 500;};
    #   };
    # };

    plugins.gitsigns = {
      enable = true;
      settings = {
        current_line_blame = true;
        current_line_blame_opts = {
          delay = 500;
        };
      };
    };

    plugins.neogit = {
      enable = true;
      settings = {
        integrations = {
          diffview = true;
        };
      };
    };

    plugins.diffview.enable = true;

    # ============================================================================
    # Multi-line editing
    # ============================================================================
    plugins.visual-multi.enable = true;

    # ============================================================================
    # LSP
    # Mirrors your VSCode language servers exactly
    # ============================================================================
    plugins.lsp = {
      enable = true;
      servers = {
        # Nix — nixd with alejandra formatter (matches your nix.serverPath = "nixd")
        nixd = {
          enable = true;
          settings = {
            formatting.command = ["alejandra"];
            # options.enable     = true;
          };
        };

        # Python — ruff as LSP (matches ruff.nativeServer = "on")
        ruff = {
          enable = true;
        };

        # C/C++ — clangd (matches clangd.arguments)
        clangd = {
          enable = true;
          extraOptions.cmd = [
            "clangd"
            "--compile-commands-dir=${toString ./.}"
          ];
        };

        # Rust — rust-analyzer
        rust_analyzer = {
          enable = true;
          installRustc = false; # use system rustc
          installCargo = false;
          settings = {
            restartServerOnConfigChange = true;
          };
        };

        # Zig — zls (matches zig.zls.enabled = "on")
        zls.enable = true;

        # Bash — bash-language-server (matches bashIde extension)
        bashls.enable = true;

        # YAML
        yamlls.enable = true;

        # JSON
        jsonls.enable = true;

        # CMake (matches cmake extension)
        cmake.enable = true;

        # Dart
        dartls.enable = true;

        # Markdown / markdownlint via ltex or efm
        # Using efm-langserver to wire markdownlint (mirrors your defaultFormatter)
        efm = {
          enable = true;
          extraOptions.filetypes = ["markdown"];
        };
      };
    };

    # ============================================================================
    # FORMATTING (conform.nvim = VSCode's "format on save")
    # ============================================================================
    plugins.conform-nvim = {
      enable = true;
      settings = {
        # format_on_save = {
        #   enable = false;
        #   timeoutMs = 500;
        #   lspFallback = true;
        # };
        format_on_save = {};
        formatters_by_ft = {
          nix = ["alejandra"];
          python = ["ruff_format"];
          markdown = ["markdownlint"];
          c = ["clang_format"];
          cpp = ["clang_format"];
          rust = ["rustfmt"];
          sh = ["shfmt"];
          bash = ["shfmt"];
          json = ["jq"];
          yaml = ["yamlfmt"];
        };
      };
    };

    # ============================================================================
    # LINTING (nvim-lint = VSCode's problem panel)
    # ============================================================================
    plugins.lint = {
      enable = true;
      lintersByFt = {
        python = ["ruff"];
        markdown = ["markdownlint"];
        sh = ["shellcheck"];
        bash = ["shellcheck"];
        nix = ["nix"];
        c = ["clangtidy"];
        cpp = ["clangtidy"];
      };
    };

    # ============================================================================
    # AUTOCOMPLETION (replaces VSCode's IntelliSense popup)
    # ============================================================================
    plugins.cmp = {
      enable = true;
      settings = {
        sources = [
          {name = "nvim_lsp";}
          {name = "buffer";}
          {name = "path";}
          {name = "luasnip";}
        ];
        mapping = {
          "<Tab>" = "cmp.mapping.select_next_item()";
          "<S-Tab>" = "cmp.mapping.select_prev_item()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<C-Space>" = "cmp.mapping.complete()";
        };
      };
    };

    plugins.luasnip.enable = true; # snippet engine used by cmp

    # ============================================================================
    # COMMENT HIGHLIGHTING
    # todo-comments = Better Comments extension equivalent
    # Matches your tags: ! (error/red), ? (question/blue), todo (warning/orange),
    # * (green), > (yellow/note), - (brown/deprecated)
    # ============================================================================
    plugins.todo-comments = {
      enable = true;
      settings = {
        keywords = {
          FIX = {
            icon = " ";
            color = "#FF2D00";
            alt = ["!" "FIXME" "BUG" "FIXIT" "ISSUE"];
          };
          TODO = {
            icon = " ";
            color = "#FF8C00";
          };
          HACK = {
            icon = " ";
            color = "#F4CE14";
            alt = [">"];
          };
          WARN = {
            icon = " ";
            color = "#F4CE14";
            alt = ["WARNING" "XXX"];
          };
          PERF = {
            icon = " ";
            color = "#98C379";
            alt = ["*" "OPTIM" "PERFORMANCE" "OPTIMIZE"];
          };
          NOTE = {
            icon = " ";
            color = "#3498DB";
            alt = ["?" "INFO"];
          };
          TEST = {
            icon = "⏲ ";
            color = "#8C6A5D";
            alt = ["-" "TESTING" "PASSED" "FAILED"];
          };
        };
      };
    };

    # ============================================================================
    # WHICH-KEY (shows available keybindings — replaces VSCode's command palette hints)
    # ============================================================================
    plugins.which-key.enable = true;

    # ============================================================================
    # AUTOPAIRS (auto-close brackets like VSCode)
    # ============================================================================
    plugins.nvim-autopairs.enable = true;

    # ============================================================================
    # INDENT GUIDES (matches editor.guides.bracketPairs = "active")
    # ============================================================================
    plugins.indent-blankline = {
      enable = true;
      settings = {
        scope.enabled = true; # highlights active indent scope like VSCode
      };
    };

    # ============================================================================
    # KEYMAPS
    # ============================================================================
    keymaps = [
      # Do / UnDO
      {
        mode = "n";
        key = "<C-z>";
        action = "u";
      }
      {
        mode = "i";
        key = "<C-z>";
        action = "<Esc>u";
      }

      {
        mode = "n";
        key = "<C-y>";
        action = "<C-r>";
      }
      {
        mode = "i";
        key = "<C-y>";
        action = "<Esc><C-r>";
      }

      {
        mode = "n";
        key = "<C-a>";
        action = "gg<S-v>G";
        options.silent = true;
      }


{
  mode = "v";
  key = "<C-c>";
  action = ''"*y'';
  options.silent = true;
}


# Paste in insert mode (while typing)
{
  mode = "i";
  key = "<C-v>";
  action = ''<Esc>"*pa'';
  options.silent = true;
}

      # File explorer toggle (like VSCode Ctrl+B)
      {
        mode = "n";
        key = "<C-b>";
        action = ":Neotree toggle<CR>";
        options.silent = true;
      }

      # Telescope (like VSCode Ctrl+P / Ctrl+Shift+P / Ctrl+Shift+F)
      {
        mode = "n";
        key = "<C-p>";
        action = ":Telescope find_files<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<C-S-p>";
        action = ":Telescope commands<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<C-S-f>";
        action = ":Telescope live_grep<CR>";
        options.silent = true;
      }
{
  mode = "n";
  key = "<C-f>";
  action = "/";
  options.silent = true;
}



# Shift+Up to select upward
{
  mode = "n";
  key = "<S-Up>";
  action = "<S-v><Up>";
  options.silent = true;
}

# Shift+Down to select downward
{
  mode = "n";
  key = "<S-Down>";
  action = "<S-v><Down>";
  options.silent = true;
}

# Keep extending selection while holding shift
{
  mode = "v";
  key = "<S-Up>";
  action = "<Up>";
  options.silent = true;
}
{
  mode = "v";
  key = "<S-Down>";
  action = "<Down>";
  options.silent = true;
}




      # Buffer tabs (like VSCode Ctrl+Tab / Ctrl+W)
      {
        mode = "n";
        key = "<Tab>";
        action = ":BufferLineCycleNext<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<S-Tab>";
        action = ":BufferLineCyclePrev<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<C-w>";
        action = ":bdelete<CR>";
        options.silent = true;
      }

      # LSP actions (like VSCode F12 / Shift+F12 / F2)
      {
        mode = "n";
        key = "gd";
        action = ":lua vim.lsp.buf.definition()<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "gr";
        action = ":lua vim.lsp.buf.references()<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<F2>";
        action = ":lua vim.lsp.buf.rename()<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>ca";
        action = ":lua vim.lsp.buf.code_action()<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "K";
        action = ":lua vim.lsp.buf.hover()<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>f";
        action = ":lua vim.lsp.buf.format()<CR>";
        options.silent = true;
      }

      # Diagnostics (like VSCode Problems panel)
      {
        mode = "n";
        key = "<leader>d";
        action = ":Telescope diagnostics<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "[d";
        action = ":lua vim.diagnostic.goto_prev()<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "]d";
        action = ":lua vim.diagnostic.goto_next()<CR>";
        options.silent = true;
      }

      # Git (like GitLens)
      # {
      #   mode = "n";
      #   key = "<leader>gb";
      #   action = ":Gitsigns blame_line<CR>";
      #   options.silent = true;
      # }
      {
        mode = "n";
        key = "<leader>gd";
        action = ":Gitsigns diffthis<CR>";
        options.silent = true;
      }

      {
        mode = "n";
        key = "<leader>gs";
        action = ":Telescope git_status<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>gb";
        action = ":Telescope git_branches<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>gc";
        action = ":Telescope git_commits<CR>";
        options.silent = true;
      }

      {
        mode = "n";
        key = "<leader>gg";
        action = ":Neogit<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>gc";
        action = ":Neogit commit<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>gl";
        action = ":Neogit log<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>gh";
        action = ":DiffviewFileHistory %<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>go";
        action = ":DiffviewOpen<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>gq";
        action = ":DiffviewClose<CR>";
        options.silent = true;
      }

      # Save (like VSCode Ctrl+S)
      {
        mode = "n";
        key = "<C-s>";
        action = ":w<CR>";
        options.silent = true;
      }
      {
        mode = "i";
        key = "<C-s>";
        action = "<Esc>:w<CR>";
        options.silent = true;
      }
    ];

    # ============================================================================
    # EXTRA PACKAGES (tools the LSPs/formatters call out to)
    # These need to be on PATH — nixvim puts them in the nvim wrapper's PATH
    # ============================================================================
    extraPackages = with pkgs; [
      # Nix
      nixd
      alejandra

      # Python
      ruff

      # C/C++
      clang-tools # provides clangd + clang-format + clang-tidy

      # Rust (use the system toolchain; remove if you manage rust via rustup)
      rust-analyzer

      # Zig
      zls

      # Shell
      bash-language-server
      shellcheck
      shfmt

      # Web / misc
      # nodePackages.yaml-language-server
      # nodePackages.vscode-json-languageserver
      # nodePackages.markdownlint-cli
      cmake-language-server

      # Formatters
      jq
    ];
  };
}
