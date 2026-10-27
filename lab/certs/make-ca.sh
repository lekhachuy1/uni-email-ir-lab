#!/usr/bin/env bash
# Tạo CA nội bộ cho lab và cấp cert cho các host .lab. Chỉ dùng trong lab offline.
# Chạy trên Linux/WSL/Git-Bash có openssl:  ./make-ca.sh
# Kết quả:
#   lab-root-ca.crt / .key        -> cài lab-root-ca.crt vào trust store MỌI trình duyệt client (cần cho WebAuthn)
#   <host>/tls.crt  <host>/tls.key (fullchain = leaf + root)
#   ../keycloak/certs/tls.crt|tls.key  (copy cho stack Keycloak)
set -euo pipefail
cd "$(dirname "$0")"
DAYS=${DAYS:-825}
HOSTS=("sso.uni.lab" "mail.uni.lab" "login.uni-lab.support")   # thêm host khác nếu cần

if [[ ! -f lab-root-ca.key ]]; then
  echo "[*] tạo Root CA"
  openssl genrsa -out lab-root-ca.key 4096
  openssl req -x509 -new -nodes -key lab-root-ca.key -sha256 -days 3650 \
    -subj "/C=VN/O=UNI Lab/CN=UNI Lab Root CA" -out lab-root-ca.crt
fi

issue() {
  local h=$1; mkdir -p "$h"
  echo "[*] cấp cert cho $h"
  openssl genrsa -out "$h/tls.key" 2048
  openssl req -new -key "$h/tls.key" -subj "/C=VN/O=UNI Lab/CN=$h" -out "$h/tls.csr"
  cat > "$h/tls.ext" <<EOF
basicConstraints=CA:FALSE
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=DNS:$h,DNS:localhost,IP:127.0.0.1
EOF
  openssl x509 -req -in "$h/tls.csr" -CA lab-root-ca.crt -CAkey lab-root-ca.key \
    -CAcreateserial -days "$DAYS" -sha256 -extfile "$h/tls.ext" -out "$h/tls.leaf.crt"
  cat "$h/tls.leaf.crt" lab-root-ca.crt > "$h/tls.crt"     # fullchain
  rm -f "$h/tls.csr" "$h/tls.ext" "$h/tls.leaf.crt"
}

for h in "${HOSTS[@]}"; do issue "$h"; done

echo "[*] copy cert của sso.uni.lab cho stack Keycloak"
cp sso.uni.lab/tls.crt sso.uni.lab/tls.key ../keycloak/certs/ 2>/dev/null || {
  mkdir -p ../keycloak/certs && cp sso.uni.lab/tls.crt sso.uni.lab/tls.key ../keycloak/certs/; }

echo
echo "XONG. Việc cần làm tay:"
echo "  - Cài lab-root-ca.crt vào trust store của mọi trình duyệt client (WebAuthn cần HTTPS tin cậy)."
echo "  - mailcow: dùng mail.uni.lab/tls.{crt,key} (SKIP_LETS_ENCRYPT=y) — xem mailcow/README-override.md"
echo "  - GoPhish phish server: dùng login.uni-lab.support/tls.{crt,key}"
