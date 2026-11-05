# Chương 8 — Kết luận và hướng phát triển

## 8.1 Trả lời các câu hỏi nghiên cứu

Đồ án xây dựng một chuỗi khép kín — chính sách → quy trình → lab kiểm chứng → đo lường → cải tiến — cho
tình huống chiếm quyền tài khoản email đại học. Căn cứ kết quả diễn tập (Chương 6, 7), nhóm trả lời sáu
câu hỏi nghiên cứu:

| Mã | Câu hỏi | Kết luận (tổng hợp từ Chương 6–7) |
|---|---|---|
| Q1 | Chính sách có cưỡng chế được bằng kỹ thuật? | *(điền từ kết quả TC-01…TC-17)* |
| Q2 | Tấn công bị chặn khi áp chính sách? | *(điền từ D1/D2)* |
| Q3 | Phát hiện qua nhật ký nào, nhanh ra sao? | *(điền từ nhật ký + MTTD nếu có SIEM)* |
| Q4 | Kẻ tấn công mất quyền sau kiểm soát? | *(điền từ kiểm thử âm tính 5 đường)* |
| Q5 | Ảnh hưởng người dùng hợp lệ? | *(điền từ D3)* |
| Q6 | Bằng chứng đủ dựng lại sự cố? | *(điền từ §7.4)* |

## 8.2 Đóng góp chính

- Một **bộ chính sách an toàn tài khoản** bám NIST SP 800-63B-4, kèm **bảng phân quyền, vòng đời tài
  khoản và sơ đồ phân quyền**, được cưỡng chế bằng cấu hình thực tế.
- Một **quy trình phản ứng sự cố** riêng cho chiếm quyền email, với đóng góp phương pháp quan trọng:
  **chuỗi kiểm soát hai lớp** (vì vô hiệu hóa ở một kho định danh không đủ) và **năm phép thử âm tính**
  định nghĩa thế nào là "đã kiểm soát".
- Một **phòng lab tái lập được** từ mã nguồn cấu hình, và **bộ biểu mẫu + mô hình đo lường** cho phép
  định lượng hiệu quả ứng phó.

## 8.3 Hạn chế

- Lab triển khai gần single-host nên tín hiệu "đăng nhập từ IP lạ" kém thực tế hơn môi trường phân vùng.
- Một số hành vi của công cụ (đặc biệt việc đóng phiên webmail khi khóa tài khoản) cần kiểm chứng kỹ và
  có thể phụ thuộc phiên bản.
- Diễn tập trong môi trường biết trước kịch bản nên các chỉ số phụ thuộc tốc độ con người chỉ mang tính
  tham khảo.

## 8.4 Hướng phát triển

- Triển khai **SIEM (Wazuh)** đầy đủ để đo thời gian phát hiện (MTTD) và tự động hóa cảnh báo.
- Áp dụng **xác thực chống lừa đảo (WebAuthn/khóa cứng)** cho tài khoản giá trị cao.
- Nghiên cứu **PA3** (Dovecot OAuth2) để thu hồi phiên triệt để hơn.
- Mở rộng quy trình sang nền tảng thật (Microsoft 365 / Google Workspace) và tích hợp phản ứng tự động
  có kiểm soát.
