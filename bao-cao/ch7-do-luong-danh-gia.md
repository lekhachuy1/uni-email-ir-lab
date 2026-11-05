# Chương 7 — Đo lường, kết quả và đánh giá

*Phụ trách: Trần Quốc Kiệt. Mô hình đo lường đã hoàn chỉnh; các bảng số liệu là khung chờ điền sau khi*
*chạy diễn tập, kèm hướng dẫn nguồn lấy từng số.*

## 7.1 Mô hình đo lường

Mỗi sự cố mô phỏng gắn các mốc thời gian (ghi theo UTC, báo cáo quy đổi UTC+7):

| Mốc | Ý nghĩa | Nguồn xác định |
|---|---|---|
| T0 | Bắt đầu tấn công | kịch bản diễn tập (biết trước) |
| T1 | Tiếp nhận báo cáo / cảnh báo | BC-01 hoặc nhật ký/cảnh báo |
| T2 | Phân mức xong | BB-03 |
| T3 | Kiểm soát xong | nhật ký script kiểm soát |
| T4 | Loại bỏ điểm bám trụ xong | CL-02 |
| T5 | Người dùng dùng lại được | CL-03 + kiểm thử âm tính |
| T6 | Đóng sự cố | BB-03 |

Các chỉ số bắt buộc theo đề tài:

- **MTTA** (tiếp nhận) = T2 − T1
- **MTTC** (kiểm soát) = T3 − T1
- **MTTR** (khôi phục) = T5 − T1
- **Tác động người dùng hợp lệ:** tỷ lệ báo động giả, thời gian khôi phục hợp lệ (Q5)

Chỉ số nâng cao (chỉ khi dùng SIEM): **MTTD** (phát hiện) = T1 − T0.

> **Lưu ý phương pháp:** cần tách rõ chỉ số *điều khiển được* (tấn công thành công hay không, kẻ tấn công
> còn quyền sau kiểm soát) khỏi chỉ số *phụ thuộc tốc độ con người* — chỉ số sau chỉ mang tính tham khảo
> vì phụ thuộc người chơi và việc biết trước kịch bản.

## 7.2 Kết quả theo diễn tập (chờ điền)

**Bảng chỉ số thời gian:**

| Diễn tập | T1−T0 (MTTD*) | MTTA | MTTC | MTTR | Ghi chú |
|---|---|---|---|---|---|
| D1 (phishing) | | | | | |
| D2 (dùng trái phép) | | | | | |
| D3 (người dùng hợp lệ) | | | | | |

*(MTTD chỉ điền nếu có SIEM.)*

**Bảng kết quả định tính:**

| Câu hỏi | D1 | D2 | D3 |
|---|---|---|---|
| Q2 Tấn công bị chặn ở v1? | | | |
| Q3 Phát hiện qua nhật ký nào? | | | |
| Q4 Kẻ tấn công mất quyền sau kiểm soát? | | | |
| Q5 Tác động tới người dùng hợp lệ? | | | |
| Q6 Dựng lại được T0 từ nhật ký? | | | |

## 7.3 So sánh v0 vs v1 (nâng cao — nếu có chạy hai vòng)

| Chỉ tiêu | v0 | v1 | Nhận xét |
|---|---|---|---|
| Tỷ lệ tấn công thành công | | | |
| Số thư spam gửi được (D2) | | | |
| Thiết lập được điểm bám trụ? | | | |
| Cảnh báo có kích hoạt? | | | |

## 7.4 Đánh giá bằng chứng (Q6)

Đánh giá xem **chỉ từ nhật ký** (không dùng thông tin biết trước của kịch bản) có dựng lại được thời
điểm bắt đầu tấn công T0 và phạm vi ảnh hưởng hay không. Nếu không, đó là một **phát hiện về khoảng
trống ghi log** và được đưa vào phần bài học.

**Gói bằng chứng:** toàn bộ nhật ký, ảnh chụp, video và biểu mẫu đã điền được tổ chức theo cây thư mục
`Evidence/D{1,2,3}/` kèm tệp `SHA256SUMS.txt` để bảo toàn tính toàn vẹn. Ảnh chụp đặt tên theo quy ước
`D<n>_<mốc>_<nội dung>.png`.

## 7.5 Bài học và cải tiến (hotwash → AAR)

Sau diễn tập, nhóm tổ chức họp rút kinh nghiệm (hotwash) và lập báo cáo sau hành động (AAR). Mỗi bài học
phải chỉ rõ **sửa ở tài liệu nào**: chính sách (Chương 3), quy trình (Chương 4), cấu hình lab, hay luật
phát hiện. Đây chính là bước khép vòng "đo lường → cải tiến quay lại chính sách/quy trình".

**Bảng bài học (chờ điền):**

| # | Bài học | Hành động cải tiến | Sửa ở đâu | Người phụ trách | Hạn |
|---|---|---|---|---|---|
| 1 | | | | | |
