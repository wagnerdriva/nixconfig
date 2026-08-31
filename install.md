# Instalação limpa do Precision 5530

> **Não execute ainda.** O procedimento abaixo apaga por completo o SK hynix
> PC401 de 1 TB em `/dev/nvme0n1`.

## Antes de apagar

1. Faça backup de qualquer arquivo necessário.
2. No firmware Dell, use UEFI. Desabilite Secure Boot temporariamente, sem
   limpar as chaves de fábrica.
3. Se o live USB não enxergar o NVMe, altere `SATA Operation` de `RAID On` para
   `AHCI`. Como o disco será apagado, não precisamos preservar o boot atual.
4. Inicie o ISO gráfico do NixOS 26.05 e conecte-o à internet.

Não abra nem monte as partições do NVMe pelo gerenciador de arquivos. O
instalador aborta se detectar qualquer partição do disco em uso, inclusive se
for executado por engano a partir do NixOS instalado.

No terminal do live USB, confirme os endereços das GPUs:

```bash
lspci -D | grep -E 'VGA|3D'
```

O esperado é Intel em `0000:00:02.0` e NVIDIA em `0000:01:00.0`. Se forem
diferentes, ajuste `hosts/precision/nvidia.nix` antes da instalação.

Confirme novamente o disco:

```bash
lsblk -o NAME,PATH,SIZE,MODEL,TYPE
```

O alvo esperado é `/dev/nvme0n1`, modelo PC401, com aproximadamente 954 GiB.

## Instalação

No live USB, abra um terminal e execute:

```bash
git clone https://github.com/wagnerdriva/nixconfig.git /tmp/n && cd /tmp/n && sudo bash scripts/install-precision /dev/nvme0n1
```

O script exige que o modelo do NVMe corresponda ao PC401 e pede a confirmação
textual `APAGAR /dev/nvme0n1`. Depois, ele solicita a senha LUKS e a senha do
usuário `wagner`.

Ao terminar:

```bash
reboot
```

Retire o live USB. Secure Boot e desbloqueio via TPM serão configurados apenas
depois de confirmarmos boot, vídeo, áudio, Wi-Fi, suspensão e retomada.
