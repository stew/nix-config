
self: super: {
  stew = {

    emacs =
      let
        emacs = self.emacsPackagesNg.overrideScope' (eself: esuper: {
          lsp-mode = eself.melpaBuild {
            pname = "lsp-mode";
            version = "20190606.1958";
            src = fetchGit {
              url = "https://github.com/emacs-lsp/lsp-mode.git";
              rev = "34b769cebde2b7ba3f11230636a1fcd808551323";
            };
            packageRequires = with eself; [
              dash
              dash-functional
              eself.emacs
              f
              ht
              markdown-mode
              spinner
            ];
            recipe = self.writeText "recipe" ''
              (lsp-mode :repo "emacs-lsp/lsp-mode" :fetcher github)
            '';
          };

          lsp-ui = eself.melpaBuild {
            pname = "lsp-ui";
            version = "20190523.1521";
            src = fetchGit {
              url = "https://github.com/emacs-lsp/lsp-ui.git";
              rev = "3ccc3e3386732c3ee22c151e6b5215a0e4c99173";
            };
            packageRequires = with eself; [
              dash
              dash-functional
              eself.emacs
              lsp-mode
              markdown-mode
            ];
            recipe = self.writeText "recipe" ''
              (lsp-ui :repo "emacs-lsp/lsp-ui"
                      :fetcher github
                      :files (:defaults "lsp-ui-doc.html"))
            '';
          };

          company-lsp = eself.melpaBuild {
            pname = "company-lsp";
            version = "20190525.207";
            src = fetchGit {
              url = "https://github.com/tigersoldier/company-lsp.git";
              rev = "cd1a41583f2d71baef44604a14ea71f49b280bf0";
            };
            packageRequires = with eself; [
              company
              dash
              eself.emacs
              lsp-mode
              s
            ];
            recipe = self.writeText "recipe" ''
              (company-lsp :repo "tigersoldier/company-lsp" :fetcher github)
            '';
          };
        });

        scala-metals = self.stdenv.mkDerivation rec {
          name = "scala-metals-${version}";
          version = "0.6.1";
          phases = "buildPhase";
          buildInputs = [ self.coursier ];
          buildPhase = ''
            mkdir -p $out/bin
            tmp_cache=$(mktemp -d)
            COURSIER_CACHE=$tmp_cache coursier bootstrap \
              --java-opt -Xss4m \
              --java-opt -Xms100m \
              --java-opt -Dmetals.client=emacs \
              org.scalameta:metals_2.12:${version} \
              -r bintray:scalacenter/releases \
              -r sonatype:snapshots \
              -o $out/bin/metals-emacs -f
          '';
        };

        aspellDict = self.aspellDicts.en;
        
      in
        {
          inherit (self) coreutils direnv fira-code multimarkdown aspell;
          inherit scala-metals aspellDict;

          emacs = emacs.emacsWithPackages (epkgs: (with epkgs; [
            ace-jump-mode
            ansible
            avy
            cargo
            company
            company-lsp
            company-racer
            dante
            direnv
            exec-path-from-shell
            flycheck
            flycheck-rust
            flymake-rust
            groovy-mode
            haskell-mode
            hcl-mode
            hydra
            json-mode
            key-chord
            lsp-haskell
            lsp-mode
            lsp-ui
            lua-mode
            magit
            magithub
            markdown-mode
            multiple-cursors
            mustache-mode
            neotree
            nix-mode
            paredit
            powerline
            projectile
            racer
            rust-mode
            sbt-mode
            scala-mode
            smex
            use-package
            which-key
            yaml-mode
          ]));
        };



    essentials = with self; { inherit
        pkg-config
        pstree
        shellcheck
        watch
        inetutils
        tmux
        git
        coreutils
        gnupg
        wget
        findutils
        yq
        jq;
    };

    
    haskell = with self; { inherit cabal-install cabal2nix ghc; };

    scala = { inherit (self) sbt jekyll; };

    tex = { inherit (self.texlive.combined) scheme-full; };

    rust = { inherit (self) cargo carnix rustfmt; };
  };
}
