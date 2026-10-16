# instalar.ps1 — instala o kit da Guilda numa VERSÃO FIXA, conferindo o SHA-256 do pacote ANTES de abrir (Windows).
# Nada de "irm | iex": baixe este arquivo e o SHA256SUMS, confira, e rode.
#
#   powershell -ExecutionPolicy Bypass -File instalar.ps1 -Versao 2.5.1 [-Destino DIR]
#
# O pacote (guilda-<versao>.tar.gz) vem da release da versão no repositório do kit, pelo gh com o seu login.
# O hash esperado vem do SHA256SUMS deste repositório. Se o hash não bater, ou a versão não existir, nada é instalado.
# Saídas: 0 instalado · 2 uso errado · 3 checksum não bate · 4 versão inexistente · 5 falta ferramenta
param(
  [Parameter(Mandatory = $true)][string]$Versao,
  [string]$Destino = ""
)
$ErrorActionPreference = "Stop"
function Erro([int]$codigo, [string]$msg) { [Console]::Error.WriteLine("ERRO: $msg"); exit $codigo }

$RepoKit = if ($env:GUILDA_REPO_KIT) { $env:GUILDA_REPO_KIT } else { "camilooscargbaptista/guilda" }
$Aqui = Split-Path -Parent $MyInvocation.MyCommand.Path
$Somas = if ($env:GUILDA_SOMAS) { $env:GUILDA_SOMAS } else { Join-Path $Aqui "SHA256SUMS" }

if ($Versao -notmatch '^\d+\.\d+\.\d+$') { Erro 2 "versão inválida: '$Versao' (esperado X.Y.Z)" }
if (-not $Destino) { $Destino = Join-Path $HOME ".guilda\kits\$Versao" }
$Pacote = "guilda-$Versao.tar.gz"

if (-not (Test-Path $Somas)) { Erro 5 "não achei o SHA256SUMS ($Somas): baixe-o junto com este instalador" }
$Esperado = $null
foreach ($l in Get-Content $Somas) {
  $p = $l -split '\s+', 2
  if ($p.Count -eq 2 -and ($p[1] -eq $Pacote -or $p[1] -eq "*$Pacote")) { $Esperado = $p[0].ToLower(); break }
}
if (-not $Esperado) { Erro 4 "a versão $Versao não existe (o SHA256SUMS não lista $Pacote) — veja as versões no README" }
$TarExe = Join-Path $env:SystemRoot "System32\tar.exe"     # o tar do Windows (o de outro PATH, ex. o do Git, não lê C:\...)
if (-not (Test-Path $TarExe)) {
  $c = Get-Command tar -ErrorAction SilentlyContinue
  if (-not $c) { Erro 5 "falta o tar (Windows 10 ou mais novo traz o tar.exe)" }
  $TarExe = $c.Source
}

$Tmp = Join-Path ([IO.Path]::GetTempPath()) ("guilda-inst-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $Tmp | Out-Null
try {
  if ($env:GUILDA_INSTALADOR_FONTE) {
    $origem = Join-Path $env:GUILDA_INSTALADOR_FONTE $Pacote
    if (-not (Test-Path $origem)) { Erro 4 "a versão $Versao não existe na fonte ($Pacote)" }
    Copy-Item $origem $Tmp
  } else {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Erro 5 "falta o gh (GitHub CLI) — o pacote do kit vem pela sua conta: gh auth login" }
    & gh release download $Versao -R $RepoKit -p $Pacote -D $Tmp 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { Erro 4 "não consegui baixar a versão $Versao de $RepoKit (ela existe? o seu gh tem acesso? gh auth status)" }
  }
  $Obtido = (Get-FileHash -Algorithm SHA256 (Join-Path $Tmp $Pacote)).Hash.ToLower()
  if ($Obtido -ne $Esperado) { Erro 3 "o SHA-256 do pacote NÃO bate — nada foi instalado. esperado: $Esperado obtido: $Obtido" }
  Write-Output "SHA-256 conferido: $Pacote ($Obtido)"
  if (Test-Path $Destino) { Erro 2 "o destino já existe: $Destino (escolha outro com -Destino, ou mova o antigo)" }
  New-Item -ItemType Directory -Path $Destino | Out-Null
  & $TarExe -xzf (Join-Path $Tmp $Pacote) -C $Destino --strip-components=1
  if ($LASTEXITCODE -ne 0) { Erro 5 "o tar não conseguiu abrir o pacote" }
  Write-Output "Guilda $Versao instalada em $Destino"
  Write-Output "Próximo passo: python `"$Destino\laco\guilda.py`" doctor"
} finally {
  Remove-Item -Recurse -Force $Tmp -ErrorAction SilentlyContinue
}
