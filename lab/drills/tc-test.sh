#!/bin/bash
# Credentials tu ../.env (copy tu env.example). Khong commit secret.
set -a; . "$(dirname "$0")/../.env" 2>/dev/null || true; set +a
CONTAIN_PW="Contained_$(openssl rand -hex 4 2>/dev/null || echo abcd1234)"
RECOVER_PW="Recovered_$(openssl rand -hex 4 2>/dev/null || echo abcd1234)"
# Ca kiểm thử cấu hình v1: TC-02 (mật khẩu yếu bị từ chối), TC-05 (khóa brute-force).
set -u
KC="docker exec keycloak /opt/keycloak/bin/kcadm.sh"
$KC config credentials --server https://localhost:8443 --realm master \
  --user admin --password "${KC_ADMIN_PASSWORD:?set in .env}" \
  --truststore /opt/keycloak/data/kc-trust.p12 --trustpass changeit >/dev/null 2>&1

RES="https://sso.uni.lab:8443"
CURL="curl -sk --resolve sso.uni.lab:8443:127.0.0.1"

echo "########## TC-02: mật khẩu < 12 ký tự / yếu phải BỊ TỪ CHỐI ##########"
echo "--- thử đặt mật khẩu 'weak' cho sv02 ---"
$KC set-password -r uni --username sv02 --new-password 'weak' 2>&1 | sed 's/^/  /'
echo "--- thử đặt 'password' (trong ý nghĩa yếu) cho sv02 ---"
$KC set-password -r uni --username sv02 --new-password 'short1' 2>&1 | sed 's/^/  /'
echo "--- đặt mật khẩu HỢP LỆ (>=12) cho sv01 (đồng bộ với mail) ---"
$KC set-password -r uni --username sv01 --new-password "${USER_PW:?set in .env}" 2>&1 | sed 's/^/  /'
echo "  => nếu không in lỗi là đặt THÀNH CÔNG (mật khẩu mạnh được chấp nhận)"

echo
echo "########## TC-05: khóa tạm thời sau 10 lần sai (brute-force) ##########"
# xóa trạng thái khóa cũ của sv01 nếu có
SVID=$($KC get users -r uni -q username=sv01 --fields id 2>/dev/null | grep -oE '[0-9a-f-]{36}' | head -1)
$KC delete attack-detection/brute-force/users/$SVID -r uni >/dev/null 2>&1

kc_try(){ # user pass -> OK|FAIL|LOCKED|NOFORM
  local CJ; CJ=$(mktemp)
  local auth="$RES/realms/uni/protocol/openid-connect/auth?client_id=account-console&redirect_uri=$RES/realms/uni/account/&response_type=code&scope=openid"
  local page; page=$($CURL -c "$CJ" "$auth")
  local action; action=$(printf '%s' "$page" | grep -oE 'action="[^"]*login-actions/authenticate[^"]*"' | head -1 | sed 's/action="//; s/"$//; s/&amp;/\&/g')
  if [ -z "$action" ]; then echo "NOFORM"; rm -f "$CJ"; return; fi
  local code; code=$($CURL -b "$CJ" -c "$CJ" -o /tmp/kcresp -w '%{http_code}' \
     --data-urlencode "username=$1" --data-urlencode "password=$2" --data "credentialId=" "$action")
  if [ "$code" = "302" ]; then echo "OK";
  elif grep -qiE 'disabled' /tmp/kcresp; then echo "LOCKED";
  else echo "FAIL"; fi
  rm -f "$CJ"
}

echo "--- 11 lần đăng nhập SAI mật khẩu cho sv01 ---"
for i in $(seq 1 11); do
  r=$(kc_try "sv01" "WrongPass#$i$i$i")
  echo "  lần $i: $r"
done
echo "--- thử mật khẩu ĐÚNG ("$USER_PW") khi đang bị khóa ---"
echo "  kết quả: $(kc_try "sv01" ""$USER_PW"")  (mong đợi LOCKED => chứng minh khóa có hiệu lực)"
echo "--- trạng thái brute-force (kcadm) ---"
$KC get attack-detection/brute-force/users/$SVID -r uni 2>&1 | sed 's/^/  /'
echo "--- gỡ khóa rồi thử lại mật khẩu ĐÚNG ---"
$KC delete attack-detection/brute-force/users/$SVID -r uni >/dev/null 2>&1
echo "  kết quả sau khi gỡ khóa: $(kc_try "sv01" ""$USER_PW"")  (mong đợi OK)"

echo
echo "########## Bằng chứng phát hiện (Q3): LOGIN_ERROR trong log Keycloak ##########"
docker logs keycloak 2>&1 | grep -iE 'LOGIN_ERROR|USER_DISABLED|invalid_user_credentials' | tail -5 | sed 's/^/  /'
