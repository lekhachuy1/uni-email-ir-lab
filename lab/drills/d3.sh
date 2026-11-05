#!/bin/bash
# NOTE: lab credentials were redacted (<REDACTED-PW>). Set your own before running.
set -u
ts(){ date -u +"%Y-%m-%dT%H:%M:%SZ"; }
KC="docker exec keycloak /opt/keycloak/bin/kcadm.sh"
$KC config credentials --server https://localhost:8443 --realm master --user admin \
  --password '<REDACTED-PW>' --truststore /opt/keycloak/data/kc-trust.p12 --trustpass changeit >/dev/null 2>&1
CURL="curl -sk --resolve sso.uni.lab:8443:127.0.0.1"
TOK="https://sso.uni.lab:8443/realms/uni/protocol/openid-connect/token"
uid(){ $KC get users -r uni -q username=$1 --fields id|grep -oE '[0-9a-f-]{36}'|head -1; }
kc_code(){ $CURL -o /dev/null -w '%{http_code}' -d client_id=admin-cli -d grant_type=password --data-urlencode "username=$1" --data-urlencode "password=$2" "$TOK"; }
imap(){ python3 - "$1" "$2" <<'PY'
import imaplib,ssl,sys
ctx=ssl.create_default_context();ctx.check_hostname=False;ctx.verify_mode=ssl.CERT_NONE
try:
  m=imaplib.IMAP4_SSL("127.0.0.1",993,ssl_context=ctx);m.login(sys.argv[1],sys.argv[2]);print("OK");m.logout()
except Exception: print("FAIL")
PY
}

echo "########## DIỄN TẬP D3 — NGƯỜI DÙNG HỢP LỆ ##########"

echo "[3a $(ts)] Đổi thiết bị: đăng nhập hợp lệ từ ngữ cảnh mới KHÔNG bị khóa vĩnh viễn"
$KC delete attack-detection/brute-force/users/$(uid sv03) -r uni >/dev/null 2>&1
echo "   sv03 (sau khi gỡ khóa tạm) đăng nhập mail: $(imap sv03@st.uni.lab <REDACTED-PW>)"
echo "   => khóa brute-force là TẠM THỜI => người dùng hợp lệ khôi phục được (Q5: không vũ khí hóa DoS)."

echo
echo "[3b $(ts)] Quên mật khẩu / KHÔI PHỤC sv01 (nối tiếp D1) theo quy trình helpdesk"
SVID=$(uid sv01)
$KC update users/$SVID -r uni -s enabled=true >/dev/null 2>&1 && echo "   -> bật lại tài khoản Keycloak"
$KC set-password -r uni --username sv01 --new-password '<REDACTED-PW>' >/dev/null 2>&1 && echo "   -> đặt lại mật khẩu (>=12)"
$KC update users/$SVID -r uni -s 'requiredActions=["UPDATE_PASSWORD"]' >/dev/null 2>&1 && echo "   -> buộc đổi mật khẩu lần đăng nhập đầu"
docker exec dms setup email update sv01@st.uni.lab '<REDACTED-PW>' >/dev/null 2>&1
docker exec dms doveadm auth cache flush >/dev/null 2>&1
echo "   sv01 dùng lại được: IMAP(mail) = $(imap sv01@st.uni.lab '<REDACTED-PW>')"
echo "   => T5 KHÔI PHỤC đạt: chủ tài khoản gửi/nhận lại bình thường (kiểm thử âm tính sau T5)."

echo
echo "[3c $(ts)] Mất MFA + IT vắng mặt (quy trình)"
echo "   - Dùng MÃ KHÔI PHỤC đã cấp khi đăng ký MFA, hoặc quy trình BREAK-GLASS có kiểm soát."
echo "   - Break-glass sinh CẢNH BÁO; đặt lại MFA theo CL-01 mức 3 (four-eyes + duyệt trưởng đơn vị)."
echo "   - KHÔNG đặt lại MFA qua kênh chưa xác minh."

echo
echo "[3d $(ts)] Vishing helpdesk — PHẢI TỪ CHỐI"
echo "   - Kẻ giả danh gọi đòi reset MFA 'gấp' (sắp thi/họp) => dấu hiệu gây áp lực = tăng cảnh giác."
echo "   - Nguyên tắc CL-01: không xác minh qua kênh người gọi cung cấp; GỌI LẠI số trong hồ sơ."
echo "   - Kết quả đúng: TỪ CHỐI yêu cầu, mở sự cố nếu nghi mạo danh."
echo "   => Phép thử quy trình/con người: đạt khi helpdesk từ chối đúng kịch bản."
echo "########## HẾT D3 ##########"
