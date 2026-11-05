#!/usr/bin/env bash
# Bootstrap toàn bộ lab bằng một lệnh: mạng + CA + Keycloak + realm/user + mail + hộp thư.
# Dùng: cp env.example .env ; sửa .env ; ./setup-all.sh
# Yêu cầu: Docker + Compose v2, openssl, curl. Chạy ở thư mục lab/.
set -euo pipefail
cd "$(dirname "$0")"
[ -f .env ] || { echo "Chua co .env. Chay: cp env.example .env roi sua mat khau."; exit 1; }
set -a; . ./.env; set +a

echo "== 1) Mang Docker =="
docker network create labnet 2>/dev/null || echo "  labnet da ton tai"

echo "== 2) CA noi bo + chung chi TLS =="
[ -f certs/sso.uni.lab/tls.crt ] || ( cd certs && ./make-ca.sh )

echo "== 3) Keycloak + PostgreSQL =="
docker compose --env-file ./.env -f keycloak/docker-compose.yml up -d
echo "  cho Keycloak san sang..."
for i in $(seq 1 40); do curl -sk https://localhost:8443/realms/master >/dev/null 2>&1 && { echo "  OK"; break; }; sleep 5; done

echo "== 4) Truststore cho kcadm =="
docker exec keycloak sh -c '[ -f /opt/keycloak/data/kc-trust.p12 ] || keytool -import -trustcacerts -alias lab-ca \
  -file /opt/keycloak/conf/certs/tls.crt -keystore /opt/keycloak/data/kc-trust.p12 \
  -storetype PKCS12 -storepass changeit -noprompt'

echo "== 5) Realm + 11 tai khoan (+ v1 neu APPLY_V1=1) =="
./create-realm.sh

echo "== 6) Mail server (docker-mailserver) =="
cd mail-lite
mkdir -p dms/mail-data dms/mail-state dms/mail-logs dms/config roundcube/db
docker compose up -d dms
echo "  cho Dovecot (tao hop thu truoc khi no khoi dong)..."
sleep 5
for u in sv01 sv02 sv03 sv04 sv05 sv06; do docker exec dms setup email add "${u}@st.uni.lab" "$MAIL_PW" 2>/dev/null || true; done
for u in gv01 gv02 nv01 it.helpdesk adm.mail; do docker exec dms setup email add "${u}@uni.lab" "$MAIL_PW" 2>/dev/null || true; done
echo "== 7) Webmail (Roundcube) =="
docker compose up -d roundcube
cd ..

IP=$(hostname -I 2>/dev/null | awk '{print $1}')
echo
echo "XONG. Webmail: http://${IP:-<VM_IP>}:8080  |  Keycloak: https://${IP:-<VM_IP>}:8443"
echo "Tai khoan vi du: sv01@st.uni.lab / (MAIL_PW trong .env). Chay dien tap: bash drills/d1.sh"
