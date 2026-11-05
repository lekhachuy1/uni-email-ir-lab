# Checklist cài đặt & cấu hình để chạy demo / hoàn thành đồ án

Tổng quan: phạm vi bắt buộc (Keycloak + mail server) chạy trong **~6 GB RAM**, vừa VM hiện tại.
Lệnh chi tiết nằm trong các skill: `keycloak-iam-lab`, `mailcow-lab`, `phishing-sim-lab`, `account-takeover-response`.

## 1. Đã có — không cần cài lại
- [x] VM Ubuntu + Docker + Compose.
- [x] Keycloak 26.8.1 + PostgreSQL 18 (realm `uni`, 5 nhóm, 11 tài khoản) — tự chạy lại nhờ `restart: unless-stopped`.
- [x] CA nội bộ + chứng chỉ TLS.
- [x] GoPhish v0.12.1 (trên máy Windows).
- [x] DNS (dnsmasq), kịch bản baseline, attacker MTA (compose đã có).

## 2. Cần CÀI thêm
- [ ] **Mail server (mailcow)** trên VM — phần cài lớn còn lại. Khi cài, sửa `mailcow.conf`:
  - `SKIP_CLAMD=y` (tắt quét virus — tiết kiệm ~2 GB)
  - `SKIP_SOLR=y` (tắt full-text — tiết kiệm RAM)
  - đặt `MAILCOW_HOSTNAME=mail.uni.lab`, dùng chứng chỉ CA nội bộ (`SKIP_LETS_ENCRYPT=y`)
- [ ] **Attacker MTA** khởi động (compose đã có) để thư phishing qua SPF/DMARC thật.
- [ ] *(Tùy chọn/nâng cao)* **Wazuh** — xem mục 6.

## 3. Cần SET (cấu hình v1 — áp chính sách của Huynh)

### 3a. Keycloak (dùng `kcadm`, công thức ở skill `keycloak-iam-lab`)
- [ ] **Password policy:** `length(12)`, `passwordHistory(5)`, `notUsername`, `passwordBlacklist(<file>)`
      — KHÔNG bật yêu cầu hoa/thường/ký tự đặc biệt (theo NIST 800-63B).
- [ ] **Brute-force detection:** bật, `permanentLockout=false`, `maxLoginFailures=10`, khóa tạm thời tăng dần.
- [ ] **MFA theo nhóm:** bắt buộc TOTP cho GiangVien/NhanVien/IT (required action `CONFIGURE_TOTP`
      hoặc conditional flow); SV khuyến nghị.
- [ ] **Tắt Direct Grant** trên client người dùng (chỉ để Standard flow) — chặn đường bỏ qua MFA.
- [ ] **Required actions lần đầu:** `UPDATE_PASSWORD` + `CONFIGURE_TOTP`.
- [ ] **Email khôi phục** của user trỏ địa chỉ cá nhân đã xác minh (không phải hộp thư trường).
- [ ] *(nâng cao)* WebAuthn cho tài khoản IT.
- [ ] Xác nhận ghi sự kiện LOGIN/LOGIN_ERROR/UPDATE_CREDENTIAL/IMPERSONATE ở mức `info`.

### 3b. Mail server (mailcow — skill `mailcow-lab`)
- [ ] Tích hợp **OIDC Identity Provider** trỏ Keycloak (đăng nhập webmail qua SSO).
- [ ] **SV:** tắt đăng nhập IMAP/SMTP bằng mật khẩu (chỉ app password có kiểm soát / hoặc chặn hẳn).
- [ ] **SV:** chặn chuyển tiếp ra ngoài miền (Sieve/forwarding).
- [ ] **Ratelimit gửi** 30 thư/giờ cho SV.
- [ ] Tạo hộp thư cho 11 tài khoản mẫu; chuẩn bị 1 hộp thư cá nhân "ngoài trường" (external.lab).

### 3c. GoPhish (skill `phishing-sim-lab`)
- [ ] **Sending profile** trỏ attacker MTA (không gửi từ chính máy chủ lab).
- [ ] **Landing page** sao chép trang đăng nhập Keycloak (bắt thông tin → chuyển hướng về thật).
- [ ] **Campaign** nhắm các hộp thư lab; export kết quả làm bằng chứng D1.

## 4. Chuẩn bị cho BUỔI DEMO / DIỄN TẬP
- [ ] **Snapshot VM** trạng thái "v1 sẵn sàng" (để revert chạy lại nếu hỏng).
- [ ] **OBS** quay màn hình (bằng chứng + dự phòng khi bảo vệ).
- [ ] **NTP** đồng bộ mọi máy (mốc T0–T6 khớp giữa các nguồn log).
- [ ] Cây thư mục `Evidence/D{1,2,3}/{logs,screenshots,video,forms}/` + chuẩn bị `SHA256SUMS.txt`.
- [ ] In sẵn biểu mẫu BC-01/BB-03/CL-01..03 (hoặc mở file) để điền khi diễn tập.
- [ ] **Dry-run** 1 lần D1 trước buổi chính thức.
- [ ] Script `contain.sh` (skill `account-takeover-response`) sẵn sàng cho bước kiểm soát.

## 5. Thứ tự chạy khi demo (tối thiểu → đầy đủ)
1. Mở Keycloak (https://192.168.238.128:8443) — cho xem realm, chính sách, log sự kiện.
2. D1: GoPhish gửi phish → đăng nhập trái phép (v0 được / v1 bị MFA chặn) → chụp log.
3. D2: rải mật khẩu → gửi spam (v0) vs bị khóa/giới hạn (v1).
4. D3: người dùng đổi thiết bị/quên mật khẩu/mất MFA + từ chối vishing.
5. Chạy `contain.sh` kiểm soát 2 lớp → **5 phép thử âm tính** → khôi phục.
6. Điền biểu mẫu + đo T1–T6 → gói bằng chứng.

**Demo tối thiểu (nếu thiếu thời gian/RAM):** chỉ Keycloak — chính sách v0/v1 + đăng nhập từ IP tấn công
+ log sự kiện + `contain.sh` + khôi phục. Vẫn thể hiện đủ 4 trụ.

## 6. (Tùy chọn — nâng cao) Wazuh
- [ ] Cài Wazuh (manager-only để nhẹ, hoặc single-node đầy đủ nếu nâng RAM lên ~10–12 GB).
- [ ] Nạp decoder Keycloak + rule UC1–UC9 (assets trong skill `wazuh-email-detection`).
- [ ] Kiểm bằng `wazuh-logtest` với log thật → có MTTD cho báo cáo.
