# Instalador da Guilda

Instala o kit da **Guilda** (Arkolabs) numa **versão fixa**, conferindo o **SHA-256** do pacote antes de abrir.
Este repositório tem só o instalador — nenhum código do kit.

## Antes: o acesso ao kit

**O pacote do kit exige acesso ao repositório `camilooscargbaptista/guilda`** (privado). O instalador baixa o pacote de
cada versão da release desse repositório pelo **GitHub CLI (`gh`)**, com o seu login:

```bash
gh auth login          # com uma conta que tenha acesso ao camilooscargbaptista/guilda
gh auth status         # confira a conta antes de instalar
```

Sem esse acesso, o instalador para com um erro claro e não instala nada.

## Mac, Linux e Git Bash (Windows)

```bash
curl -fsSLO https://install.arkolabs.ia.br/instalar.sh     # ou baixe da release deste repositório
curl -fsSLO https://install.arkolabs.ia.br/SHA256SUMS
sha256sum -c SHA256SUMS --ignore-missing                   # no Mac: shasum -a 256 -c SHA256SUMS --ignore-missing
bash instalar.sh --versao 2.5.1
```

## Windows (PowerShell)

```powershell
Invoke-WebRequest https://install.arkolabs.ia.br/windows -OutFile instalar.ps1
Invoke-WebRequest https://install.arkolabs.ia.br/SHA256SUMS -OutFile SHA256SUMS
(Get-FileHash instalar.ps1 -Algorithm SHA256).Hash          # compare com a linha do instalar.ps1 no SHA256SUMS
powershell -ExecutionPolicy Bypass -File instalar.ps1 -Versao 2.5.1
```

## O que o instalador faz

1. Lê no `SHA256SUMS` o hash esperado do pacote da versão pedida (`guilda-<versão>.tar.gz`). Versão que não está lá:
   **para**, com erro claro (saída 4).
2. Baixa o pacote da release daquela versão no repositório do kit, com o seu `gh`.
3. Confere o SHA-256. **Não bateu: para e não instala nada** (saída 3).
4. Abre o pacote em `~/.guilda/kits/<versão>` (ou em `--destino`), sem sobrescrever o que já existe.

Nunca use `curl … | bash`: baixe, confira o hash e só então rode.

## Versões

| versão | pacote |
|---|---|
| 2.6.1 | `guilda-2.6.1.tar.gz` |
| 2.6.0 | `guilda-2.6.0.tar.gz` |
| 2.5.2 | `guilda-2.5.2.tar.gz` |
| 2.5.1 | `guilda-2.5.1.tar.gz` |
| 2.5.0 | `guilda-2.5.0.tar.gz` |

Os hashes estão no `SHA256SUMS`, que também lista o próprio `instalar.sh` e o `instalar.ps1`.
