# Chương 1 — Mở đầu

## 1.1 Bối cảnh và tính cấp thiết

Trong trường đại học, tài khoản email không chỉ là công cụ liên lạc mà còn đóng vai trò **danh tính
gốc (root identity)** của người dùng. Phần lớn dịch vụ nội bộ (hệ thống quản lý học tập, thư viện số,
cổng thông tin sinh viên, lưu trữ đám mây) và nhiều dịch vụ bên ngoài sử dụng địa chỉ email của trường
để đăng ký và để khôi phục mật khẩu. Hệ quả là khi một tài khoản email bị chiếm quyền (account takeover),
kẻ tấn công không dừng ở việc đọc trộm thư: chúng có thể đặt lại mật khẩu của nhiều dịch vụ khác, phát
tán thư lừa đảo trong nội bộ dưới danh nghĩa một người đáng tin (giảng viên, phòng đào tạo), đánh cắp dữ
liệu cá nhân và tạo bàn đạp cho các cuộc tấn công sâu hơn.

Môi trường giáo dục đặc biệt dễ bị nhắm tới vì số lượng người dùng rất lớn, nhận thức an toàn thông tin
không đồng đều, và chính sách xác thực thường còn yếu — nhiều tài khoản sinh viên chưa bật xác thực đa
yếu tố, mật khẩu đặt đơn giản, các giao thức cũ (IMAP/SMTP) vẫn cho đăng nhập bằng mật khẩu. Trong khi
đó, phần lớn tài liệu về ứng phó sự cố hoặc quá chung chung, hoặc tập trung vào mã độc và tấn công từ
chối dịch vụ, mà thiếu một quy trình được kiểm chứng dành riêng cho tình huống chiếm quyền tài khoản —
vốn có đặc thù rất khác: điểm bám trụ (persistence) của kẻ tấn công vẫn tồn tại ngay cả sau khi đổi mật
khẩu, và việc "khóa tài khoản" phải thực hiện xuyên nhiều lớp hệ thống mới thực sự có hiệu lực.

Vì vậy, đề tài có tính cấp thiết cả về thực tiễn (bảo vệ tài sản số của nhà trường và dữ liệu cá nhân
của người học) lẫn học thuật (xây dựng và kiểm chứng một quy trình ứng phó có bằng chứng, đo lường được).

## 1.2 Phát biểu bài toán

Thay vì giải quyết "tấn công mạng" nói chung — phạm vi quá rộng cho một đồ án — nhóm thu hẹp vào một lớp
sự cố cụ thể, có ranh giới rõ ràng và giàu bài học: **chiếm quyền và lạm dụng tài khoản email đại học**.
Bài toán gồm bốn phần gắn kết thành một chuỗi khép kín:

1. **Chính sách:** thiết kế chính sách an toàn tài khoản (mật khẩu, xác thực đa yếu tố, phân quyền,
   khôi phục) đủ mạnh và quan trọng hơn là *có thể cưỡng chế bằng kỹ thuật*.
2. **Quy trình:** xây dựng quy trình phản ứng sự cố từ phát hiện đến đóng, phù hợp đặc thù chiếm quyền email.
3. **Kiểm chứng:** dựng phòng lab mô phỏng để chứng minh chính sách được cưỡng chế và quy trình thực sự
   loại trừ được kẻ tấn công.
4. **Đo lường & cải tiến:** đo hiệu quả (thời gian tiếp nhận, kiểm soát, khôi phục; tác động tới người
   dùng hợp lệ) và đưa bài học quay lại hoàn thiện chính sách/quy trình.

## 1.3 Mục tiêu và câu hỏi nghiên cứu

**Mục tiêu tổng quát:** xây dựng và kiểm chứng một bộ giải pháp hoàn chỉnh — chính sách, quy trình và
khả năng phát hiện — để phản ứng hiệu quả với sự cố chiếm quyền tài khoản email đại học, có bằng chứng
và số liệu định lượng.

Phòng lab được thiết kế để trả lời sáu câu hỏi nghiên cứu; bất kỳ hạng mục nào không phục vụ câu hỏi
nào đều bị coi là vượt phạm vi:

| Mã | Câu hỏi nghiên cứu |
|---|---|
| Q1 | Chính sách an toàn tài khoản có thực sự được cưỡng chế bằng kỹ thuật không? |
| Q2 | Các kịch bản tấn công thành công ở mức nào khi chính sách yếu, và bị chặn ra sao khi áp chính sách? |
| Q3 | Sự cố được phát hiện qua nhật ký nào và nhanh đến đâu? |
| Q4 | Sau mỗi bước kiểm soát, kẻ tấn công có thực sự mất quyền truy cập không? |
| Q5 | Các biện pháp có ảnh hưởng tiêu cực đến người dùng hợp lệ không? |
| Q6 | Bằng chứng thu được có đủ để dựng lại dòng thời gian và phạm vi sự cố không? |

## 1.4 Đối tượng và phạm vi

**Đối tượng:** quy trình và biện pháp phản ứng sự cố đối với việc chiếm quyền/lạm dụng tài khoản email
đại học, cùng hạ tầng định danh và thư điện tử liên quan.

**Trong phạm vi:** chiếm quyền/lạm dụng tài khoản (phishing, rải mật khẩu, đánh cắp phiên, lạm dụng
quyền); chính sách xác thực và khôi phục; phát hiện qua nhật ký; kiểm soát và khôi phục; đo lường hiệu quả.

**Ngoài phạm vi:** mã độc/ransomware, tấn công từ chối dịch vụ hạ tầng, khai thác lỗ hổng ứng dụng web
ngoài luồng đăng nhập, an toàn vật lý.

**Giới hạn:** phòng lab cô lập hoàn toàn, không kết nối Internet, mọi dữ liệu và tài khoản là giả. Do
điều kiện phần cứng, lab triển khai theo hướng gần single-host thay vì phân vùng nhiều VLAN như thiết kế
lý tưởng; điều này được nêu rõ như một giới hạn và được bù bằng việc đặt máy tấn công trên một máy vật lý
tách biệt để vẫn có địa chỉ nguồn khác nhau trong nhật ký.

## 1.5 Phương pháp thực hiện

Đồ án thực hiện theo một chuỗi khép kín: **nghiên cứu chuẩn → thiết kế chính sách và quy trình → dựng
lab → diễn tập → đo lường → rút kinh nghiệm quay lại chính sách/quy trình.** Cơ sở phương pháp gồm khung
ứng phó sự cố NIST SP 800-61r3, chuẩn xác thực NIST SP 800-63B-4, và phương pháp thiết kế diễn tập NIST
SP 800-84 / HSEEP 2020.

## 1.6 Đóng góp và phân công

Đồ án do nhóm bốn thành viên thực hiện, mỗi người phụ trách một trụ gắn kết thành chuỗi và ánh xạ theo
các hàm của NIST SP 800-61r3 (CSF 2.0):

| Thành viên | Trụ / Hàm CSF | Chương phụ trách |
|---|---|---|
| Đỗ Quốc Huynh | Chính sách & IAM (Govern/Identify/Protect) | Chương 3 |
| Nguyễn Bá Khánh | Quy trình IR (Detect/Respond/Recover) | Chương 4 |
| Lê Khắc Huy | Phòng lab & diễn tập (kiểm chứng) | Chương 5, 6 |
| Trần Quốc Kiệt | Biểu mẫu, đo lường & báo cáo | Chương 7, biểu mẫu, tổng hợp |

## 1.7 Cấu trúc báo cáo

Báo cáo gồm tám chương: (1) Mở đầu; (2) Cơ sở lý thuyết và chuẩn; (3) Chính sách và quản trị danh tính;
(4) Quy trình phản ứng sự cố; (5) Xây dựng phòng lab mô phỏng; (6) Kịch bản tấn công và diễn tập;
(7) Đo lường, kết quả và đánh giá; (8) Kết luận và hướng phát triển. Phần phụ lục chứa bộ biểu mẫu, trích
cấu hình, bảng ca kiểm thử và gói bằng chứng.
