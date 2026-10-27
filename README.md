# Đồ án: Phản ứng sự cố chiếm quyền tài khoản email đại học

Lab mô phỏng và quy trình ứng phó sự cố (IR) cho tình huống **chiếm quyền / lạm dụng tài khoản email**
trong trường đại học. Toàn bộ chạy **trong lab cô lập, dữ liệu và tài khoản đều giả**.

Ánh xạ theo NIST SP 800-61r3 (Detect / Respond / Recover):
- **Chính sách & phân quyền** (IAM, mật khẩu, MFA, vòng đời tài khoản)
- **Quy trình ứng phó sự cố** (tiếp nhận → kiểm soát → điều tra → khôi phục → đóng)
- **Lab & diễn tập** (dựng hệ thống, tấn công giả lập, thu log/bằng chứng)
- **Biểu mẫu, đo lường & báo cáo** (T0–T6, MTTD/MTTA/MTTC/MTTR, v0 vs v1)

## Cấu trúc

```
lab/
  README.md     sơ đồ mạng, thứ tự dựng, giới hạn single-host
  certs/        CA nội bộ (make-ca.sh)
  dns/          phân giải *.lab + MX/SPF/DKIM/DMARC
  keycloak/     Keycloak 26.8.1 + PostgreSQL + script dựng realm (IdP)
  gophish/      GoPhish (phía tấn công) — compose; bản binary tải riêng
  attacker/     MTA kẻ tấn công (evil.lab / uni-lab.support)
  mailcow/      override đẩy log (mailcow cài bằng trình cài riêng)
  wazuh/        cấu hình thu log + decoder/rule (SIEM)
  baseline/     sinh đăng nhập hợp lệ nền
```

## Lưu ý bảo mật
- `.env`, khoá private (`*.key`), cert, `*.db`, log, `users.csv` **không** được đưa lên repo (xem `.gitignore`).
- Mật khẩu trong `*.example` chỉ là mẫu — đổi toàn bộ khi triển khai thật.
- Bản GoPhish (`lab/gophish-win/`) là release tải từ GitHub, không nằm trong repo.

## Trạng thái triển khai
Keycloak (realm `uni`, cấu hình v0) đã dựng trên VM lab; GoPhish dựng trên máy tấn công.
Xem `lab/README.md` để biết chi tiết và các bước còn lại (mailcow, Wazuh, cấu hình v1).
