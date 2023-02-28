$ErrorActionPreference = 'Stop'

Invoke-WebRequest -OutFile 'app\license.rtf' -Uri "https://www.gnu.org/licenses/gpl-$(Get-Content -Path 'VERSIONS\LICENSE_VERSION').rtf"

Invoke-WebRequest -OutFile 'app\geosite.db' -Uri 'https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db'
Invoke-WebRequest -OutFile 'app\geoip.db' -Uri 'https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db'


git clone https://github.com/haishanh/yacd.git
Set-Location -Path 'yacd'
#Checkout lateat yacd release
git checkout $(Get-Content -Path '..\VERSIONS\YACD_VERSION')

yarn install
yarn build
Move-Item -Path 'public' -Destination '..\app\yacd'

Set-Location -Path '..'

git clone https://github.com/sagernet/sing-box.git
Set-Location -Path 'sing-box'
git checkout $(Get-Content -Path '..\VERSIONS\VERSION')

$env:CGO_ENABLED = '0'
$env:GOOS = 'windows'
foreach ($i in 'amd64', 'arm64') {
    $env:GOARCH = $i
    go build -trimpath -v -o "../app/sing-box-$i.exe" -tags "with_quic,with_grpc,with_wireguard,with_ech,with_utls,with_clash_api,with_gvisor" -ldflags " -X 'github.com/sagernet/sing-box/constant.Commit=$(Get-Content -Path '..\VERSIONS\VERSION')' -w -s -buildid=" ./cmd/sing-box
}

Set-Location -Path '..'
