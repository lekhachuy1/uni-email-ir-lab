# Chương 6 — Kịch bản tấn công và diễn tập

*Phụ trách: Lê Khắc Huy (phối hợp Trần Quốc Kiệt về đo lường). Phần thiết kế kịch bản và ca kiểm thử*
*đã hoàn chỉnh; các bảng kết quả là khung chờ điền số liệu sau khi chạy diễn tập.*

## 6.1 Phương pháp diễn tập

Diễn tập bắt buộc chạy trên cấu hình đã áp chính sách (v1); phần nâng cao có thể chạy thêm một vòng trên
v0 để so sánh mức cải thiện. Khi chạy hai vòng, để tránh thiên lệch do học thuộc kịch bản, nhóm tách
chỉ số điều khiển được (tấn công thành công hay không, kẻ tấn công còn quyền sau kiểm soát) khỏi chỉ số
phụ thuộc tốc độ con người, và thay đổi nạn nhân/mồi/thời điểm ở vòng sau.

**Phân vai khi diễn tập:** Điều phối + bên tấn công (Đỏ); Người xử lý sự cố (chạy quy trình Chương 4);
Người đo lường & thư ký (tính T1–T6, điền biểu mẫu); Người quan sát chính sách (ghi chính sách nào chặn
được). Toàn bộ buổi diễn tập được quay màn hình làm bằng chứng dự phòng.

## 6.2 Diễn tập 1 — Chiếm quyền tài khoản do phishing

**Mục tiêu:** tái hiện chuỗi phishing → chiếm quyền → thiết lập điểm bám trụ, và kiểm chứng chính sách
MFA chặn được ở v1.

| Bước | Hành động bên tấn công | Kỳ vọng v0 | Kỳ vọng v1 |
|---|---|---|---|
| 1 | Gửi thư lừa đảo kèm link trang đăng nhập giả | nạn nhân nhập mật khẩu | như v0 |
| 2 | Dùng thông tin vừa lấy đăng nhập | **thành công** (không MFA) | **bị chặn** (yêu cầu MFA) |
| 3 | Lập quy tắc chuyển tiếp, tạo app password, tự đăng ký MFA | thiết lập được điểm bám trụ | không tới được bước này |

**Kết quả (chờ điền):**

| Mục | v0 | v1 |
|---|---|---|
| Đăng nhập trái phép thành công? | | |
| Thiết lập được điểm bám trụ? | | |
| Nhật ký nào ghi lại? | | |

## 6.3 Diễn tập 2 — Sử dụng trái phép tài khoản (đăng nhập / gửi email)

**Mục tiêu:** tái hiện rải mật khẩu để chiếm một tài khoản rồi lạm dụng gửi thư spam/phishing nội bộ; và
kiểm chứng khóa brute-force + giới hạn gửi ở v1.

| Bước | Hành động | Kỳ vọng v0 | Kỳ vọng v1 |
|---|---|---|---|
| 1 | Rải vài mật khẩu phổ biến trên nhiều tài khoản | có tài khoản bị chiếm | bị khóa tạm thời / không trúng |
| 2 | Dùng tài khoản chiếm được gửi thư hàng loạt | gửi được nhiều | bị giới hạn tần suất |
| 3 | Gửi tới danh sách all-staff/all-student | gửi được | bị chặn quyền |

**Kết quả (chờ điền):**

| Mục | v0 | v1 |
|---|---|---|
| Số tài khoản bị chiếm | | |
| Số thư gửi được trước khi bị chặn | | |
| Nhật ký/cảnh báo ghi lại | | |

## 6.4 Diễn tập 3 — Người dùng hợp lệ: đổi thiết bị / quên mật khẩu / mất MFA

**Mục tiêu:** kiểm chứng quy trình phục vụ người dùng hợp lệ vẫn thông suốt và an toàn, và quy trình
chống mạo danh (lừa đảo qua điện thoại helpdesk phải bị từ chối). Đây là phép đo **tác động tới người
dùng hợp lệ (Q5)**.

| Tình huống | Nội dung | Kết quả mong đợi |
|---|---|---|
| 3a Đổi thiết bị | Đăng nhập từ thiết bị mới | không bị khóa nhầm, hoặc xác minh nhẹ nhàng |
| 3b Quên mật khẩu | Tự khôi phục qua email/SĐT khôi phục đã xác minh | khôi phục được, không lặp về hộp thư đang khóa |
| 3c Mất MFA, IT vắng | Dùng mã khôi phục / quy trình break-glass | có đường khôi phục có kiểm soát |
| 3d Vishing helpdesk | Kẻ giả danh gọi đòi đặt lại MFA gấp | **bị từ chối** theo quy trình xác minh |

**Kết quả (chờ điền):**

| Tình huống | Khôi phục/ xử lý thành công? | Thời gian | Ghi chú |
|---|---|---|---|
| 3a | | | |
| 3b | | | |
| 3c | | | |
| 3d (phải bị từ chối) | | | |

## 6.5 Ca kiểm thử cấu hình (chứng minh chính sách được cưỡng chế — Q1)

Mỗi ca ghi theo mẫu: điều khoản chính sách | các bước | kết quả mong đợi | kết quả thực tế | ảnh chụp.

| Mã | Nội dung kiểm thử | Kết quả (chờ điền) |
|---|---|---|
| TC-01 | Lần đăng nhập đầu ép đổi mật khẩu + đăng ký MFA | |
| TC-02 | Mật khẩu < 12 ký tự bị từ chối | |
| TC-03 | Mật khẩu trong danh sách lộ bị từ chối | |
| TC-04 | Lịch sử 5 mật khẩu | |
| TC-05 | 10 lần sai → khóa tạm thời | |
| TC-06 | Loại MFA theo vai trò | |
| TC-07 | Tài khoản quản trị tách biệt | |
| TC-08 | Helpdesk mở khóa SV nhưng không đặt lại MFA của GV | |
| TC-09 | SV không gửi all-staff | |
| TC-10 | SV không chuyển tiếp ra ngoài (v1) | |
| TC-11 | SV không dùng IMAP/SMTP bằng mật khẩu (v1) | |
| TC-12 | Giới hạn gửi 30 thư/giờ | |
| TC-13 | Trạng thái đình chỉ: nhận thư, không đăng nhập | |
| TC-14 | Quy trình người rời trường | |
| TC-15 | Đăng nhập break-glass sinh cảnh báo | |
| TC-16 | Nhật ký có đủ trường bắt buộc | |
| TC-17 | Xóa log cục bộ vẫn còn bản thu thập tập trung | |

## 6.6 Kiểm thử âm tính (bắt buộc)

Sau khi kiểm soát (T3), bên tấn công thử lại **năm đường** — tất cả phải bị chặn mới coi là đã kiểm soát
(trả lời Q4): (1) phiên webmail đang mở; (2) mật khẩu cũ; (3) MFA kẻ tấn công tự đăng ký; (4) app
password trên IMAP; (5) quy tắc chuyển tiếp. Sau khi khôi phục (T5), kiểm tra người dùng hợp lệ gửi/nhận
lại được bình thường.

**Kết quả (chờ điền):**

| Phép thử sau T3 | Bị chặn? | Bằng chứng |
|---|---|---|
| 1. Phiên webmail đang mở | | |
| 2. Mật khẩu cũ | | |
| 3. MFA kẻ tấn công | | |
| 4. App password (IMAP) | | |
| 5. Quy tắc chuyển tiếp | | |
