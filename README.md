# nixos-config

Configuração declarativa das máquinas de Wagner, construída a partir
das ideias do [`ramosrafh/nixconfig`](https://github.com/ramosrafh/nixconfig),
sem carregar os usuários, pacotes locais ou ajustes de hardware daquele
repositório.

## Máquinas

O notebook principal é o ASUS Zenbook 14 OLED UX3402ZA (`zenbook`):

- Intel Core i7-1260P, 16 GiB de RAM e Intel Iris Xe;
- tela OLED 2880x1800, usada com escala 1,75;
- NVMe Intel SSD 670p de 1 TB em `/dev/nvme0n1`.

O Dell Precision 5530 (`precision`) é o notebook anterior:

- Intel Core i7-8850H, 32 GiB de RAM;
- Intel UHD 630 como GPU principal;
- NVIDIA Quadro P2000 sob demanda com `nvidia-offload`;
- NVMe SK hynix PC401 de 1 TB em `/dev/nvme0n1`.

Todos usam NixOS 26.05, Niri e Home Manager.

## Como ler esta configuração

`flake.nix` fixa as dependências e monta as configurações `zenbook`, `precision`
e `ryzen`.
Os módulos em `hosts/` contêm o que depende de cada máquina. `modules/nixos`
descreve o sistema compartilhável e `modules/home` descreve a sessão gráfica e
as preferências do usuário `wagner`.

O visual usa a paleta Nord no terminal, no DankMaterialShell e nos clientes de
desenvolvimento, com Niri e o wallpaper padrão em
`assets/wallpapers/1330829.jpeg`. `Mod+W` abre o seletor dos sete wallpapers
disponíveis e mantém a escolha entre reinícios.

## Ferramentas de desenvolvimento

O Home Manager instala Zed (`zed`) e Orca (`orca-ide`). Query On (`query-on`)
é opcional e não é instalado por padrão, pois seu repositório de origem pode
exigir autenticação. Também são instalados Codex, Claude Code, `btop`, Node.js,
pnpm e utilitários básicos de desenvolvimento. `codex` já abre usando o proxy
da Driva; `codex-openai`
preserva o cliente sem esse override.
O Home Manager também persiste `model_provider = "driva_proxy"` no arquivo de
configuração do Codex, preservando as demais preferências. O app recarrega esse
arquivo ao criar conversas; apenas definir o provedor no wrapper não basta.
`codex-openai` seleciona explicitamente o provedor oficial.
Conversas existentes preservam o provedor de criação. Ao mudar o provedor,
inicie uma conversa nova ou crie uma cópia do histórico com o provedor desejado.
O wrapper respeita o modelo e o nível de raciocínio salvos no Codex. A chave é
lida antes de iniciar o cliente e fornecida por `env_key`, evitando executar
um comando de autenticação durante a atualização do catálogo de modelos.
Para Claude Code, há também os aliases `claude-max`, `claude-codex` e
`claude-glm`. O tema Nord desses clientes é persistido pelo Home Manager.

O Pi (`pi`) também abre usando o proxy da Driva e é instalado nos dois hosts.
O Home Manager escreve `~/.pi/agent/models.json` com o catálogo do proxy: os
modelos GPT, GLM e Kimi ficam no provedor `driva`, que fala Responses, e os
modelos Claude ficam em `driva-claude`, que fala Anthropic Messages. O proxy só
roteia Claude pelo prefixo `claude/`, o mesmo usado em
`ANTHROPIC_DEFAULT_*_MODEL`. Cada modelo declara a janela de contexto que o
endpoint aceita e apenas os níveis de raciocínio que ele suporta. O Pi relê esse
arquivo sempre que o seletor de modelos abre.

A credencial compartilhada por esses clientes fica somente na máquina, em
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
[`install.md`](install.md). A política de energia que alterna entre
`performance` na tomada e `power-saver` na bateria fica em
`modules/nixos/laptop-power.nix` e é importada pelos notebooks.

## Comandos depois da instalação

Aplicar uma alteração:

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#zenbook
```

Para atualizar o Pi, altere `version` e `hash` em
[`packages/pi.nix`](packages/pi.nix), usando o hash SRI do asset
`pi-linux-x64.tar.gz` da release desejada. Depois valide e aplique:

```bash
nix flake check
sudo nixos-rebuild switch --flake ~/nixos-config#zenbook
```

O `pi update` não altera essa instalação porque o executável vem do Nix Store;
o wrapper `pi` é recriado pelo Home Manager quando a geração do sistema muda.

No desktop Ryzen, use o alvo correspondente:

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#ryzen
```

O perfil Ryzen mantém a mesma configuração visual, mas deixa o Niri detectar
automaticamente os monitores conectados. `minimalAgentSetup` reduz apenas as
ferramentas de agentes e não remove o tema, o terminal, o DMS ou os wallpapers.

No Ryzen, o Codex substitui o Pi. Execute `codex` e use `/model` para escolher
entre os modelos GPT, Claude, GLM e Kimi do proxy Driva. A chave continua em
`~/.config/driva/proxy-key`, fora do Git e do Nix Store; a VPN precisa estar
conectada. O Fable usa o identificador `claude/claude-fable-5-1` para selecionar
a rota correta do proxy. `codex-openai` continua disponível para acesso direto
à OpenAI, com autenticação própria. O rebuild remove o Pi e seus arquivos
declarativos apenas do Ryzen, preservando as sessões e os demais dados locais
em `~/.pi`. A instalação do Pi no Precision não muda.

O `ai-memory` registra o próprio MCP e os próprios hooks escrevendo direto em
`~/.codex`, fora do controle do Nix. Ligar `minimalAgentSetup` em um host que já
rodou o perfil completo remove o pacote e o serviço, mas deixa para trás
`~/.codex/hooks.json`, a entrada `[mcp_servers.ai-memory]` e
`~/.local/share/ai-memory`. Os hooks seguem gravando no spool sem nenhum daemon
para drená-lo, então essa limpeza precisa ser feita à mão no host.

O DMS lê `settings.json` uma única vez, na inicialização. O `switch` troca o
symlink para a nova geração, mas o processo em execução continua com os valores
antigos, então qualquer alteração em `modules/home/dank-material-shell.nix`
exige um restart explícito em qualquer host:

```bash
systemctl --user restart dms.service
```

Testar a avaliação sem trocar o sistema atual:

```bash
sudo nixos-rebuild dry-build --flake ~/nixos-config#zenbook
```

Rodar um programa com a Quadro P2000 no Precision:

```bash
nvidia-offload programa
```

## Primeiros atalhos do Niri

O `Mod` do Niri é a tecla `Super` (Windows). As teclas `Alt` permanecem em suas
funções normais.

- `Mod+Enter`: terminal;
- `Mod+R`: buscar aplicativo;
- `Mod+W`: escolher o wallpaper;
- `Mod+Shift+4`: capturar uma imagem da tela;
- `Mod+Shift+5`: selecionar uma área, escolher o áudio e iniciar/parar a
  gravação da tela (salva em `~/Videos/Gravações`);
- `Mod+E`: arquivos;
- `Mod+Q`: fechar janela;
- `Mod+V`: abrir o histórico e colar o item selecionado;
- `Mod+H/J/K` ou setas: navegar;
- `Mod+1` até `Mod+9`: trocar de workspace;
- `Mod+Shift+1` até `Mod+Shift+9`: mover a janela;
- `Mod+L`: bloquear a sessão;
- `Mod+Shift+/`: mostrar todos os atalhos.

O teclado mantém `Esc`, `Caps Lock` e `Alt` em suas funções normais.
`´` + `c` produz `ç` (e `´` + `C` produz `Ç`).
