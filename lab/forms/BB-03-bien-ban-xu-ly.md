# BB-03 — Biên bản xử lý sự cố

| Trường | Nội dung |
|---|---|
| Mã sự cố | INC-YYYYMMDD-NN |
| Mức độ | P__ |
| Tài khoản / phạm vi | |
| Người chỉ huy xử lý | |

## 1. Tóm tắt
(2–3 câu: chuyện gì xảy ra, ảnh hưởng, kết quả)

## 2. Dòng thời gian (UTC)
| Mốc | Thời điểm | Mô tả |
|---|---|---|
| T0 bắt đầu tấn công | | |
| T1 tiếp nhận/cảnh báo | | |
| T2 xác minh, phân mức | | |
| T3 kiểm soát xong | | |
| T4 loại bỏ xong | | |
| T5 người dùng dùng lại được | | |
| T6 đóng sự cố | | |

Chỉ số: MTTD = T1−T0 = ___ · MTTA = T2−T1 = ___ · MTTC = T3−T1 = ___ · MTTR = T5−T1 = ___

## 3. Phạm vi ảnh hưởng
(tài khoản khác, dữ liệu cá nhân, thư đã gửi, người nhận nội bộ…)

## 4. Nguyên nhân gốc
(phishing / lộ mật khẩu / rải mật khẩu / lạm dụng quyền…)

## 5. Hành động
- Kiểm soát: (khóa 2 lớp, thu hồi phiên, xóa app password, chặn IP…)
- Loại bỏ: (xóa rule chuyển tiếp, gỡ MFA lạ, thu hồi thư phishing…)
- **5 phép thử sau T3 đều chặn?** ☐ Có ☐ Không — chi tiết: ____
- Khôi phục: (mật khẩu mới, đăng ký lại MFA, mở khóa)

## 6. Bằng chứng
| ID | Mô tả | Nguồn | SHA-256 | Đường dẫn |
|---|---|---|---|---|
| | | | | |

## 7. Báo cáo pháp lý (nếu có)
- ☐ Sự cố ANM: thông báo ≤24h / báo cáo ≤72h tới cơ quan chuyên trách Bộ Công an
- ☐ Vi phạm dữ liệu cá nhân: thông báo ≤72h (Mẫu 08)
- Đã thực hiện: ____________________

## 8. Bài học & cải tiến
| # | Bài học | Hành động cải tiến | Người phụ trách | Hạn | Sửa ở tài liệu nào (chính sách/quy trình/cấu hình/luật SIEM) |
|---|---|---|---|---|---|
| 1 | | | | | |

## 9. Chữ ký
Người chỉ huy xử lý: ________  Trưởng nhóm ATTT (P1/P2): ________  Ngày: ________
