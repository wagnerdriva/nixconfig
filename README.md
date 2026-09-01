# nixos-config

Configuração declarativa do Dell Precision 5530 de Wagner, construída a partir
das ideias do [`ramosrafh/nixconfig`](https://github.com/ramosrafh/nixconfig),
sem carregar os usuários, pacotes locais ou ajustes de hardware daquele
repositório.

## Máquina

- Dell Precision 5530;
- Intel Core i7-8850H, 32 GiB de RAM;
- Intel UHD 630 como GPU principal;
- NVIDIA Quadro P2000 sob demanda com `nvidia-offload`;
- NVMe SK hynix PC401 de 1 TB em `/dev/nvme0n1`;
- NixOS 26.05, Niri e Home Manager.

## Como ler esta configuração

`flake.nix` fixa as dependências e monta a configuração chamada `precision`.
`hosts/precision` contém tudo que depende deste notebook. `modules/nixos`
descreve o sistema compartilhável e `modules/home` descreve a sessão gráfica e
as preferências do usuário `wagner`.

O visual usa a paleta Broken Pine, Niri, Waybar, Fuzzel, SwayNC, Hyprlock e o
wallpaper local em `assets/wallpapers/black-hole.png`.

## Ferramentas de desenvolvimento

O Home Manager instala Zed (`zed`), Orca (`orca-ide`), Codex, Claude Code,
`btop`, Node.js, pnpm e utilitários básicos de desenvolvimento. `codex` já abre
usando o proxy da Driva; `codex-openai` preserva o cliente sem esse override.
Para Claude Code, há também os aliases `claude-max`, `claude-codex` e
`claude-glm`.

A credencial compartilhada pelos dois clientes fica somente na máquina, em
`~/.config/driva/proxy-key`, com permissão `0600`. Esse arquivo não pertence ao
repo e nunca passa pelo Nix store.

## Armazenamento planejado

O instalador apaga o NVMe inteiro e cria:

- GPT e uma partição EFI de 1 GiB;
- LUKS2 no restante do disco;
- Btrfs com subvolumes separados para `/`, `/home`, `/nix`, `/var/log`, cache
  e snapshots;
- zram, sem swap em disco e sem hibernação nesta primeira versão.

O script destrutivo não deve ser executado antes da revisão descrita em
[`install.md`](install.md).

## Comandos depois da instalação

Aplicar uma alteração:

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#precision
```

Testar a avaliação sem trocar o sistema atual:

```bash
sudo nixos-rebuild dry-build --flake ~/nixos-config#precision
```

Rodar um programa com a Quadro P2000:

```bash
nvidia-offload programa
```

## Primeiros atalhos do Niri

O `Mod` do Niri é a tecla `Super` (Windows). As teclas `Alt` permanecem em suas
funções normais.

- `Mod+Enter`: terminal;
- `Mod+R`: buscar aplicativo;
- `Mod+E`: arquivos;
- `Mod+Q`: fechar janela;
- `Mod+H/J/K/L` ou setas: navegar;
- `Mod+1` até `Mod+9`: trocar de workspace;
- `Mod+Shift+1` até `Mod+Shift+9`: mover a janela;
- `Alt+L`: bloquear a sessão;
- `Mod+Shift+/`: mostrar todos os atalhos.

O teclado mantém `Esc`, `Caps Lock` e `Alt` em suas funções normais.
