#!/usr/bin/env bash
# instalar.sh — instala o kit da Guilda numa VERSÃO FIXA, conferindo o SHA-256 do pacote ANTES de abrir.
# Mac, Linux e Git Bash (Windows). Nada de curl | bash: baixe este arquivo e o SHA256SUMS, confira, e rode.
#
#   bash instalar.sh --versao 2.5.1 [--destino DIR]
#
# O pacote (guilda-<versao>.tar.gz) vem da release da versão no repositório do kit, pelo `gh` com o seu login
# (quem tem acesso ao kit). O hash esperado vem do SHA256SUMS deste repositório — uma fonte diferente da do pacote.
# Se o hash não bater, ou a versão não existir, nada é instalado.
#
# Saídas: 0 instalado · 2 uso errado · 3 checksum não bate · 4 versão inexistente · 5 falta ferramenta (gh, tar, sha256)
set -euo pipefail

REPO_KIT="${GUILDA_REPO_KIT:-camilooscargbaptista/guilda}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
SOMAS="${GUILDA_SOMAS:-$AQUI/SHA256SUMS}"
VERSAO=""
DESTINO=""

erro() { echo "ERRO: $2" >&2; exit "$1"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --versao) VERSAO="${2:-}"; shift 2 ;;
    --destino) DESTINO="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) erro 2 "opção desconhecida: $1 (use --versao X.Y.Z [--destino DIR])" ;;
  esac
done
[ -n "$VERSAO" ] || erro 2 "falta --versao (ex.: --versao 2.5.1) — a versão é sempre fixa"
case "$VERSAO" in
  [0-9]*.[0-9]*.[0-9]*) ;;
  *) erro 2 "versão inválida: '$VERSAO' (esperado X.Y.Z)" ;;
esac
DESTINO="${DESTINO:-$HOME/.guilda/kits/$VERSAO}"
PACOTE="guilda-$VERSAO.tar.gz"

[ -f "$SOMAS" ] || erro 5 "não achei o SHA256SUMS ($SOMAS): baixe-o junto com este instalador"
ESPERADO="$(awk -v p="$PACOTE" '$2 == p || $2 == "*"p { print $1 }' "$SOMAS" | head -1)"
[ -n "$ESPERADO" ] || erro 4 "a versão $VERSAO não existe (o SHA256SUMS não lista $PACOTE) — veja as versões no README"

if command -v sha256sum >/dev/null 2>&1; then hash_de() { sha256sum "$1" | awk '{print $1}'; }
elif command -v shasum >/dev/null 2>&1; then hash_de() { shasum -a 256 "$1" | awk '{print $1}'; }
else erro 5 "falta sha256sum (ou shasum) nesta máquina"; fi
command -v tar >/dev/null 2>&1 || erro 5 "falta tar nesta máquina"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
if [ -n "${GUILDA_INSTALADOR_FONTE:-}" ]; then          # testes: uma pasta local no lugar da release
  [ -f "$GUILDA_INSTALADOR_FONTE/$PACOTE" ] || erro 4 "a versão $VERSAO não existe na fonte ($PACOTE)"
  cp "$GUILDA_INSTALADOR_FONTE/$PACOTE" "$TMP/"
else
  command -v gh >/dev/null 2>&1 || erro 5 "falta o gh (GitHub CLI) — o pacote do kit vem pela sua conta: gh auth login"
  gh release download "$VERSAO" -R "$REPO_KIT" -p "$PACOTE" -D "$TMP" >/dev/null 2>&1 \
    || erro 4 "não consegui baixar a versão $VERSAO de $REPO_KIT (ela existe? o seu gh tem acesso? gh auth status)"
fi

OBTIDO="$(hash_de "$TMP/$PACOTE")"
if [ "$OBTIDO" != "$ESPERADO" ]; then
  erro 3 "o SHA-256 do pacote NÃO bate — nada foi instalado.
  esperado: $ESPERADO
  obtido:   $OBTIDO"
fi
echo "SHA-256 conferido: $PACOTE ($OBTIDO)"

[ ! -e "$DESTINO" ] || erro 2 "o destino já existe: $DESTINO (escolha outro com --destino, ou mova o antigo)"
mkdir -p "$DESTINO"
tar -xzf "$TMP/$PACOTE" -C "$DESTINO" --strip-components=1
echo "Guilda $VERSAO instalada em $DESTINO"
echo "Próximo passo: python3 \"$DESTINO/laco/guilda.py\" doctor"
