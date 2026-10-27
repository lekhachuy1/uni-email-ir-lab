# mailcow trong lab — cài và đẩy log

mailcow có `docker-compose` RIÊNG của dự án mailcow; ở đây chỉ hướng dẫn cài và phần đẩy log. KHÔNG sửa
compose gốc của mailcow.

## Cài (tóm tắt — xem skill `mailcow-lab` để đầy đủ)
```bash
git clone https://github.com/mailcow/mailcow-dockerized /opt/mailcow-dockerized
cd /opt/mailcow-dockerized
./generate_config.sh          # MAILCOW_HOSTNAME=mail.uni.lab, TZ=UTC
# mailcow.conf: SKIP_LETS_ENCRYPT=y  (dùng cert CA lab) ; đặt API_KEY, API_ALLOW_FROM=<IP siem/admin>
# Dùng cert nội bộ: chép lab/certs/mail.uni.lab/tls.{crt,key} vào data/assets/ssl/cert.pem và key.pem
docker compose pull && docker compose up -d
```

## DNS cần có (trên dns/ của lab)
MX cho `uni.lab`, `st.uni.lab` → mail.uni.lab; bản ghi SPF/DKIM/DMARC (DKIM lấy khoá public từ UI mailcow
sau khi tạo domain). Xem `../dns/dnsmasq.conf`.

## Đẩy log sang Wazuh
Chép `docker-compose.override.yml` (cùng thư mục này) vào `/opt/mailcow-dockerized/`, rồi:
```bash
cd /opt/mailcow-dockerized && docker compose down && docker compose up -d
```
Trên siem.uni.lab, rsyslog nhận UDP/514 ghi ra `/var/log/mailcow.log` (xem `../wazuh/mailcow-rsyslog.conf`),
và Wazuh agent đọc file đó (xem `../wazuh/mailcow-agent.conf`).

## Tích hợp Identity Provider (PA1)
UI mailcow → Configuration → Identity Provider → Keycloak. Kiểm tra 5 mục go/no-go của PA1 trong skill
`uni-email-ir` trước khi chốt kiến trúc. Nếu không đạt trong tuần 1 → chuyển PA2 (chỉ mailcow).
