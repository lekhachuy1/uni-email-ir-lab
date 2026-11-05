# CL-01 — Checklist xác minh danh tính

Nguyên tắc chung (NIST SP 800-63A): **không bao giờ xác minh qua chính kênh mà người yêu cầu chủ động liên hệ.**
Luôn gọi lại / đối chiếu qua kênh đã có trong hồ sơ.

## Mức 1 — Tự phục vụ (quên mật khẩu)
- ☐ OTP gửi tới **email/SĐT khôi phục đã xác minh** (không phải hộp thư đang bị khóa)
- ☐ Email/SĐT khôi phục **không** bị đổi trong 7 ngày gần đây → nếu có, **chuyển L2**

## Mức 2 — Helpdesk (chủ yếu cho SV)
- ☐ Đúng **≥ 2** thông tin định danh (MSSV/MSCB, ngày sinh, đơn vị/lớp)
- ☐ **Gọi lại** đúng số điện thoại trong hồ sơ (không dùng số người gọi đến cung cấp)
- ☐ Ghi lại người thực hiện + thời điểm

## Mức 3 — GV/NV/IT, hoặc đặt lại MFA
- ☐ Gặp trực tiếp có thẻ GV/CCCD **hoặc** gọi video + gọi lại số trong hồ sơ nhân sự
- ☐ Có **duyệt của trưởng đơn vị**
- ☐ **Hai người** cùng thực hiện (four-eyes)
- ☐ Ghi biên bản

## Chống mạo danh (bắt buộc đánh giá)
- ☐ Người yêu cầu tạo áp lực gấp gáp bất thường? (coi thi, sắp họp…) → tăng cảnh giác
- ☐ Yêu cầu bỏ qua bước xác minh? → **từ chối**
- Kết luận: ☐ Đạt, tiếp tục YC-02  ☐ Không đạt, từ chối + mở sự cố nếu nghi mạo danh

Người kiểm tra: ________  Thời điểm (UTC): ________
