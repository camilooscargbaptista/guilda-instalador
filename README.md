# Instalador da Guilda

Instala o kit da **Guilda** (Arkolabs) numa **versão fixa**, conferindo o **SHA-256** do pacote antes de abrir.
Este repositório tem só o instalador — nenhum código do kit.

**Licença do kit:** Copyright (c) 2026 Arkolabs. Todos os direitos reservados. Uso permitido conforme os termos de assinatura da Guilda. O texto está no `LICENSE` do pacote.

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
| 2.8.3 | `guilda-2.8.3.tar.gz` |
| 2.8.2 | `guilda-2.8.2.tar.gz` |
| 2.8.1 | `guilda-2.8.1.tar.gz` |
| 2.8.0 | `guilda-2.8.0.tar.gz` |
| 2.7.7 | `guilda-2.7.7.tar.gz` |
| 2.7.6 | `guilda-2.7.6.tar.gz` |
| 2.7.5 | `guilda-2.7.5.tar.gz` |
| 2.7.4 | `guilda-2.7.4.tar.gz` |
| 2.7.3 | `guilda-2.7.3.tar.gz` |
| 2.7.2 | `guilda-2.7.2.tar.gz` |
| 2.7.1 | `guilda-2.7.1.tar.gz` |
| 2.7.0 | `guilda-2.7.0.tar.gz` |
| 2.6.4 | `guilda-2.6.4.tar.gz` |
| 2.6.3 | `guilda-2.6.3.tar.gz` |
| 2.6.2 | `guilda-2.6.2.tar.gz` |
| 2.6.1 | `guilda-2.6.1.tar.gz` |
| 2.6.0 | `guilda-2.6.0.tar.gz` |
| 2.5.2 | `guilda-2.5.2.tar.gz` |
| 2.5.1 | `guilda-2.5.1.tar.gz` |
| 2.5.0 | `guilda-2.5.0.tar.gz` |

Os hashes estão no `SHA256SUMS`, que também lista o próprio `instalar.sh` e o `instalar.ps1`.

## Do zero a uma tarefa real

Depois de instalar o kit (acima), o caminho até o primeiro PR. `<KIT>` é a pasta do kit (`~/.guilda/kits/<versão>`, ou
o seu clone); `<PASTA_DO_PROJETO>` é absoluta; `<REPO>` é a URL do repositório do projeto.

**O que já foi medido e o que não foi.** No Windows, o caminho inteiro roda: a prova completa, o laço de verdade e o
serviço. No Mac, a prova mediu a instalação, a guarda, o `--atualizar` e o doctor (E0 a E8). **Ainda NUNCA foram testados
num Mac de verdade:** o laço com as abas e as voltas do despachante, e o serviço (`guilda religar`). No Mac, use as abas,
e anote cada erro.

### 1. Os pré-requisitos
| | Mac (zsh) | Windows (Git Bash) |
|---|---|---|
| python 3.9+ | `python3 --version` | `python --version` |
| as bibliotecas | `python3 -m pip install --user markdown pyyaml` | `python -m pip install --user markdown pyyaml` |
| o GitHub | `gh auth status` | `gh auth status` |
| o Claude Code, com login | `claude -p "responda só OK" --model haiku --max-turns 1` → `OK` | o mesmo |

Sem login (`Failed to authenticate`, `OAuth`, `/login`), rode `claude`, faça o `/login` e repita.

### 2. A instalação no projeto (um comando)
```bash
python3 <KIT>/laco/guilda.py novo <REPO> --raiz <PASTA_DO_PROJETO> --dono "Seu Nome" ; echo EXIT=$?
```
Ele clona o repo, cria as abas (dev e qa), o rito, a guarda e o board, e termina com os **próximos passos do seu
sistema**. O serviço fica desligado. No Windows, o comando é `python` em vez de `python3`.

### 3. Ligar o laço
1. **Confira:** `python3 <KIT>/laco/guilda.py doctor <PASTA_DO_PROJETO>`. Nada pode estar em "bloqueia".
2. **A máquina não pode dormir:**
   - no Mac, `caffeinate -dims` numa aba própria;
   - no Windows, Configurações → Energia → Suspender: Nunca.
3. **As abas:** siga `<PASTA_DO_PROJETO>/oraculo/laco/ABRIR-ABAS.md`, na coluna do seu sistema e na ordem (o oráculo
   primeiro). No Mac, Cmd+T abre uma aba nova.
4. **O serviço**, opcional: no Windows, `python <KIT>/laco/guilda.py religar <PASTA_DO_PROJETO>` roda o despachante a cada 5 min. No Mac,
   nunca foi testado.

### 4. A tarefa
Peça ao oráculo, na aba dele, ou crie o card com
`python3 <PASTA_DO_PROJETO>/oraculo/board/novo_card.py --help`. Acompanhe com
`python3 <KIT>/laco/guilda.py board <PASTA_DO_PROJETO> --vivo`. O que depende de você aparece no ⏱.

### 5. O fim
O laço leva a tarefa até o PR, passando pelos portões: o contrato, o vermelho, a implementação, a verificação, a revisão
e o PR. **O merge é sempre seu:** revise o PR no GitHub e faça o merge. Depois dele, o card vai a done.

### O que pode dar errado
| sintoma | o que fazer |
|---|---|
| o `claude` sem login | `claude`, depois `/login` |
| o laço parou à noite | a máquina dormiu: veja o item 2 do passo 3 |
| um caminho `/var/…` × `/private/var/…` barrado (Mac) | copie a linha de `oraculo/_log/guarda/<data>.jsonl`: é um BUG |
| `python3`, `gh` ou `claude` não encontrado numa aba | abra a aba pelo terminal, e não pelo Finder ou pelo Explorer; confira com `which` |
| o doctor diz "bloqueia" | rode o comando que ele mostra na mesma linha |
| o serviço não roda no Mac | ele nunca foi testado lá: use as abas e anote o erro |
