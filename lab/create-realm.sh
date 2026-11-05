#!/usr/bin/env bash
# Tạo realm "uni": 5 nhóm, 11 tài khoản (email + tên đầy đủ), đặt mật khẩu từ biến môi trường.
# Áp cấu hình v1 nếu APPLY_V1=1. Idempotent: bỏ qua thứ đã tồn tại.
# Cần: Keycloak container "keycloak" đang chạy + truststore /opt/keycloak/data/kc-trust.p12.
set -euo pipefail
: "${KC_ADMIN:?dat trong .env}"; : "${KC_ADMIN_PASSWORD:?}"; : "${USER_PW:?}"
KC="docker exec keycloak /opt/keycloak/bin/kcadm.sh"
$KC config credentials --server https://localhost:8443 --realm master \
  --user "$KC_ADMIN" --password "$KC_ADMIN_PASSWORD" \
  --truststore /opt/keycloak/data/kc-trust.p12 --trustpass changeit

# Realm
$KC get realms/uni >/dev/null 2>&1 || $KC create realms -s realm=uni -s enabled=true

# 5 nhóm
for g in SinhVien GiangVien NhanVien IT-Helpdesk IT-MailAdmin; do
  if ! $KC get groups -r uni --fields name 2>/dev/null | grep -q "\"$g\""; then
    $KC create groups -r uni -s name="$g"
  fi
done

gid_of(){ $KC get groups -r uni 2>/dev/null | grep -B2 "\"name\" : \"$1\"" | grep -oE '[0-9a-f-]{36}' | head -1; }
uid_of(){ $KC get users -r uni -q username="$1" --fields id 2>/dev/null | grep -oE '[0-9a-f-]{36}' | head -1; }

mkuser(){ # username email first last group
  local u="$1" e="$2" f="$3" l="$4" g="$5" id
  id=$(uid_of "$u")
  if [ -z "$id" ]; then
    $KC create users -r uni -s username="$u" -s enabled=true -s email="$e" \
      -s emailVerified=true -s firstName="$f" -s lastName="$l"
    id=$(uid_of "$u")
  fi
  $KC set-password -r uni --username "$u" --new-password "$USER_PW"
  local gid; gid=$(gid_of "$g")
  [ -n "$gid" ] && $KC update "users/$id/groups/$gid" -r uni -s realm=uni -s userId="$id" -s groupId="$gid" -n 2>/dev/null || true
  echo "  user $u -> $e [$g]"
}

for n in 1 2 3 4 5 6; do mkuser "sv0$n" "sv0$n@st.uni.lab" "SinhVien" "0$n" "SinhVien"; done
mkuser gv01 gv01@uni.lab GiangVien 01 GiangVien
mkuser gv02 gv02@uni.lab GiangVien 02 GiangVien
mkuser nv01 nv01@uni.lab NhanVien 01 NhanVien
mkuser it.helpdesk it.helpdesk@uni.lab IT Helpdesk IT-Helpdesk
mkuser adm.mail adm.mail@uni.lab IT MailAdmin IT-MailAdmin

if [ "${APPLY_V1:-0}" = "1" ]; then
  echo "Ap cau hinh v1..."
  $KC update realms/uni \
    -s "passwordPolicy=length(12) and passwordHistory(5) and notUsername(undefined)" \
    -s bruteForceProtected=true -s permanentLockout=false \
    -s failureFactor=10 -s waitIncrementSeconds=60
  for u in gv01 gv02 nv01 it.helpdesk adm.mail; do
    id=$(uid_of "$u"); $KC update "users/$id" -r uni -s 'requiredActions=["CONFIGURE_TOTP"]'
  done
fi
echo "Realm uni san sang (APPLY_V1=${APPLY_V1:-0})."
