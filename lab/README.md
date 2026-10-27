# Lab dựng cho đồ án — phần của Huy

Bộ `docker-compose` cho lab email đại học giả lập, phục vụ diễn tập chiếm quyền/lạm dụng tài khoản.
Mọi thứ chạy **offline trong lab**, tài khoản và dữ liệu đều giả. Giờ hệ thống dùng **UTC** (log để UTC,
báo cáo quy đổi UTC+7).

> Các thông số ở đây lấy từ reference đã kiểm chứng trong các skill (`~/.claude/skills/*`). Những hành vi
> đánh dấu UNVERIFIED trong reference **phải kiểm thử lại trên lab** trước khi khẳng định trong báo cáo.

## 1. Hai cách triển khai

| | Khuyến nghị: nhiều VM | Dự phòng: một host |
|---|---|---|
| Phân vùng mạng | Thật (router OPNsense/pfSense, VLAN) | Giả lập bằng docker network |
| IP nguồn trong log Keycloak/mailcow | **IP thật của client** → luật "đăng nhập IP lạ" có nghĩa | Thường là gateway của docker → **kém thực tế** |
| Khi nào dùng | Chạy diễn tập chính thức, lấy số liệu | Kiểm thử chức năng, máy yếu |

**Giới hạn single-host cần ghi vào báo cáo:** khi attacker và Keycloak nằm trên cùng một host Docker nhưng
khác network, Keycloak thường thấy IP nguồn là gateway của Docker, không phải IP "công cộng" của attacker.
Muốn UC3 (đăng nhập IP lạ) và MTTD có ý nghĩa, hãy tách VM như sơ đồ dưới.

## 2. Sơ đồ (nhiều VM — khuyến nghị)

```
            Router/FW (OPNsense): DNS(dnsmasq) · NTP · syslog · chặn egress Internet
 NET-SRV 10.10.20.0/24                         NET-INET-A 203.0.113.0/24
   sso.uni.lab    .11  keycloak/ (stack này)     attacker .66  gophish/ + attacker/ (Postfix evil.lab)
   mail.uni.lab   .10  mailcow (compose riêng)    home-gv01 .20 (GV hợp lệ ở nhà - baseline/)
   siem.uni.lab   .12  Wazuh (installer riêng)    ext-mail .30  external.lab (hộp thư khôi phục)
   ca.uni.lab     .5   step-ca/ hoặc make-ca.sh  NET-INET-B 198.51.100.0/24  spray-node .77
 NET-CAMPUS 10.10.10.0/24: client sv01/gv01/helpdesk (trình duyệt + baseline logins)
```
RFC 5737 (203.0.113.0/24, 198.51.100.0/24) là dải địa chỉ "dành cho tài liệu": trông như IP công cộng mà
không đụng tới ai.

## 3. Thứ tự dựng (từng bước)

1. **Mạng + hạ tầng**: tạo VM/router, đồng bộ NTP mọi máy, DNS `dns/`.
2. **CA nội bộ**: `certs/make-ca.sh` → cấp cert cho `sso.uni.lab`, `mail.uni.lab`, `login.uni-lab.support`;
   cài cert gốc (`lab-root-ca.crt`) vào trust store của **mọi trình duyệt client** (bắt buộc cho WebAuthn).
3. **mailcow** (compose riêng của dự án mailcow — KHÔNG sửa): cài theo `mailcow/README-override.md`, rồi thêm
   `mailcow/docker-compose.override.yml` để đẩy log syslog.
4. **Keycloak**: `cd keycloak && cp .env.example .env && (sửa mật khẩu) && docker compose up -d`.
   Sau đó dựng realm bằng `~/.claude/skills/keycloak-iam-lab/scripts/kc-setup-realm.sh` (v0, rồi `--v1`).
5. **Tích hợp IdP**: bật Identity Provider → Keycloak trong mailcow (xem skill `mailcow-lab`), kiểm tra 5 mục
   go/no-go của PA1.
6. **Wazuh**: cài all-in-one (`wazuh-install.sh -a`) trên siem; cài agent trên sso & mail; nạp cấu hình trong
   `wazuh/` và decoder/rule từ skill `wazuh-email-detection/assets/`.
7. **GoPhish + attacker MTA**: `cd gophish && docker compose up -d`; `cd attacker && docker compose up -d`.
8. **Baseline**: `cd baseline && docker compose up -d` để tạo đăng nhập hợp lệ nền (giờ hành chính từ CAMPUS,
   buổi tối từ home-gv01) — nếu không có nền này thì mọi đăng nhập đều bất thường.
9. **Snapshot S0 (v0) và S1 (v1)**: chụp snapshot VM / `helper-scripts/backup_and_restore.sh` trước diễn tập.

## 4. Mạng Docker dùng chung (single-host)

Tạo một lần trước khi `up` bất kỳ stack nào:
```bash
docker network create labnet            # các dịch vụ server (sso/mail/siem)
docker network create labinet           # "bên ngoài" (gophish/attacker) — xem giới hạn ở mục 1
```
Mỗi stack join `labnet` và đặt network alias trùng tên `.lab`, nên các container gọi nhau bằng
`sso.uni.lab`, `mail.uni.lab` như thật.

## 5. Tài nguyên

mailcow ~6 GB · Wazuh ~8 GB · Keycloak+Postgres ~3 GB · GoPhish/attacker ~1 GB · client/baseline 2–4 GB.
Tổng ~28–32 GB → chia cho 2–3 laptop (bridged) hoặc mượn máy phòng lab.

## 6. Cây thư mục

```
lab/
  certs/      make-ca.sh                      CA nội bộ + cấp cert
  dns/        dnsmasq.conf                     phân giải *.lab + MX, kèm ghi chú SPF/DKIM/DMARC
  keycloak/   docker-compose.yml .env.example  Keycloak 26.8.1 + PostgreSQL + log file cho Wazuh
  gophish/    docker-compose.yml               GoPhish (DB có volume)
  attacker/   docker-compose.yml postfix/      MTA của kẻ tấn công (evil.lab, uni-lab.support)
  mailcow/    docker-compose.override.yml      chỉ phần đẩy log; mailcow cài riêng
  wazuh/      *.conf *.xml                      localfile cho agent + remote syslog cho manager
  baseline/   docker-compose.yml normal-logins.py   sinh đăng nhập hợp lệ nền
```
