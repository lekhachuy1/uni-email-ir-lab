# CL-02 — Checklist điều tra phiên & quyền truy cập

Mục tiêu: xác định phạm vi và **mọi điểm bám trụ** của kẻ tấn công trước khi khôi phục.
Tài khoản: ____________  INC: ____________

| # | Mục kiểm tra | Nguồn | Phát hiện | Đã xử lý |
|---|---|---|---|---|
| 1 | Phiên đang hoạt động (IP, user-agent, thời gian) | Keycloak `users/{id}/sessions` | | ☐ |
| 2 | App password | mailcow `get/app-passwd/all/{mbox}` | | ☐ |
| 3 | Thiết bị MFA (có cái nào tạo gần đây/lạ?) | Keycloak `users/{id}/credentials` | | ☐ |
| 4 | Email/SĐT khôi phục có bị đổi? | Keycloak thuộc tính user | | ☐ |
| 5 | Quy tắc chuyển tiếp / lọc (Sieve) | mailcow `get/active-user-sieve`, `get/filters` | | ☐ |
| 6 | Trả lời tự động (vacation) | SOGo | | ☐ |
| 7 | Ủy quyền / chia sẻ hộp thư (delegation) | SOGo/mailcow | | ☐ |
| 8 | Thư đã gửi & thư đã xóa (spam/phishing nội bộ) | Postfix log, hộp thư | | ☐ |
| 9 | Thay đổi nhóm/quyền trong 30 ngày | Keycloak admin events | | ☐ |
| 10 | Lần đăng nhập gần đây & IP | mailcow `get/last-login`, Keycloak events | | ☐ |

Kết luận phạm vi: ☐ Chỉ 1 tài khoản  ☐ Lan sang tài khoản khác  ☐ Có dữ liệu cá nhân bị lộ
Người kiểm tra: ________  Thời điểm (UTC): ________
