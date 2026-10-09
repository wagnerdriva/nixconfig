# Migração para o desktop novo

## Estado e escopo

O novo PC já está instalado e testado com NixOS 26.05, arquitetura
`x86_64` e inicialização UEFI. O hardware é Ryzen 7 5700X, AMD Radeon
Navi 32 e 64 GB de RAM.

O disco WDC de 1 TB usa LUKS2 e Btrfs, com subvolumes `@root`, `@home` e
`@nix`, além de uma partição EFI de 1 GiB. O Kingston de 500 GB está
reservado para Windows e deve ser preservado.

Esta migração adapta o sistema, os aplicativos e a configuração declarativa
ao novo host. Ela não transfere automaticamente dados e estado de usuário.

## Configuração NixOS

- Reutilizar os módulos de desktop e Home Manager existentes e o `flake.lock`
  atual.
- `agentProfile = "ryzen"` e `minimalAgentSetup = true` preservam o comportamento
  atual das ferramentas de agentes, sem mudar providers nem o hostname real.
- Não importar para este host configurações de hardware, disko, NVIDIA ou
  Broadcom do `ryzen`.
- O repositório de configuração preserva o `flake.lock`; a origem antiga não
  recebe rebuild como parte desta migração.
- O host importa temporariamente `migration.nix` para a conexão Ethernet
  `enp5s0`, com IP `10.203.0.2/24` e gateway `10.203.0.1`.
- Manter ligada a máquina de origem que compartilha essa rede durante a etapa
  temporária.
- NetBird e ZeroTier ficam desativados no novo host até a migração e o registro
  das identidades próprias serem concluídos.
- Uma chave pública temporária de acesso pode constar em `migration.nix`.
  Nunca colocar uma chave privada no arquivo ou no repositório.
- A conta local e a senha já criadas devem ser preservadas; não registrar a
  senha neste documento nem compartilhá-la no chat.
- GC automática, Docker prune e limpeza de snapshots ficam temporariamente
  desativados para preservar gerações e dados durante a restauração.

O hardware usa o LUKS UUID `17a0fe8b-72ea-4de0-8cf6-127869db1e65` e a EFI
`B9BF-0245`. O Btrfs mantém `@root`, `@home` e `@nix`. O script de ativação cria
somente o subvolume aninhado `/home/.snapshots` se ele não existir, sem mover
cache ou reformatar partições.

## Build e ativação

O build será feito no destino sem atualizar o lock. Para evitar interromper a
sessão atual, ativar com a opção `boot` usando `sudo` local. Manter a geração
base anterior do NixOS disponível como rollback até validar o novo sistema.

No PC novo, após o build e a revisão:

```bash
sudo bash ~/nixos-config/hosts/desktop-novo/ativar-boot.sh
```

O script verifica hostname e UUIDs antes de agir, fixa a geração base como
GC root e executa `nixos-rebuild boot` sem atualizar o lock. Ele não reinicia
a máquina nem ativa a nova sessão imediatamente. Depois de reiniciar, a geração
base permanece selecionável no menu de boot em caso de falha.

Rollback da geração reverte o sistema, mas não desfaz mudanças no diretório
pessoal. Home Manager conserva arquivos conflitantes com a extensão
`.hm-backup`; se o login gráfico falhar, usar um TTY para revisar o serviço e
recuperar a configuração anterior do Niri, sem apagar o restante do home.

### Comando padrão, sem o facilitador

No terminal do `desktop-novo` ou conectado por SSH a ele, a primeira ativação
também pode usar os comandos normais. Antes, confirmar `hostname` como
`desktop-novo`. Se `/home/.snapshots` ainda não existir, criar o subvolume
aninhado uma única vez, sem apagar ou substituir um caminho existente:

```bash
cd ~/nixos-config
sudo btrfs subvolume create /home/.snapshots
sudo nixos-rebuild boot --flake .#desktop-novo --no-update-lock-file --no-write-lock-file
```

Se o caminho de snapshots já existir, revisar seu tipo e estado antes de
prosseguir; não remover dados para repetir o comando. O facilitador acima
faz essa verificação e também fixa a geração base como GC root.

Depois de validar o primeiro boot, os rebuilds habituais podem usar:

```bash
cd ~/nixos-config
git pull --ff-only
sudo nixos-rebuild switch --flake .#desktop-novo --no-update-lock-file --no-write-lock-file
```

Não usar `#ryzen` no PC novo e não executar estes comandos no computador
antigo para aplicar o host novo. `build` sozinho apenas compila; `boot` prepara
o próximo boot e `switch` aplica imediatamente. Reiniciar somente quando houver
acesso ao PC novo para desbloquear o LUKS.

Não executar scripts de instalação, scripts de disko ou comandos de
particionamento e formatação. O disco do sistema já está instalado e testado;
o Kingston reservado para Windows deve permanecer intacto.

## Dados e serviços fora do escopo

Não são migrados automaticamente:

- Conteúdo do diretório pessoal e restaurações de dados.
- Históricos e estados locais do Codex, Herdr e ai-memory.
- Bancos de dados e containers ativos.
- Credenciais, keyrings e processos que existiam apenas na memória RAM.

Planejar a restauração de dados separadamente e com consistência adequada para
cada aplicação. Não copiar identidades VPN vivas para manter a origem e o novo
host ativos ao mesmo tempo; registrar uma identidade individual no novo host.

## Tarefas finais

- Confirmar o boot no desktop e verificar atalhos e aplicativos esperados.
- Planejar e validar separadamente a restauração consistente dos dados.
- Ao cortar o cabo da rede temporária, configurar e confirmar a rede final.
- Registrar individualmente as identidades NetBird e ZeroTier no novo host.
- Depois de testar o acesso definitivo, remover a importação de
  `migration.nix` e a chave pública de bootstrap.
- Reativar as políticas normais de GC, Docker prune e limpeza de snapshots
  somente após validar restauração e rollback.
- Manter a origem até validar sistema, aplicativos, dados necessários e acesso
  no novo desktop.
