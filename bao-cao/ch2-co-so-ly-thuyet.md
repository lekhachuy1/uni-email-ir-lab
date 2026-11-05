# Chương 2 — Cơ sở lý thuyết và chuẩn tham chiếu

## 2.1 Vòng đời ứng phó sự cố — NIST SP 800-61r3

NIST SP 800-61r3 mô tả ứng phó sự cố không còn là một quy trình tuyến tính tách rời mà là một phần của
quản trị rủi ro an ninh mạng, ánh xạ vào sáu hàm của Khung An ninh mạng CSF 2.0:

| Hàm CSF | Nội dung | Thể hiện trong đồ án |
|---|---|---|
| Govern (Quản trị) | vai trò, trách nhiệm, chính sách | mô hình vai trò, phân mức sự cố, nghĩa vụ pháp lý |
| Identify (Nhận diện) | tài sản, rủi ro | phân loại tài khoản, phân tích nguy cơ |
| Protect (Bảo vệ) | biện pháp phòng ngừa | chính sách mật khẩu/MFA/phân quyền (Chương 3) |
| Detect (Phát hiện) | giám sát, cảnh báo | nhật ký đăng nhập, use case phát hiện (Chương 4) |
| Respond (Ứng phó) | kiểm soát, loại bỏ | chuỗi kiểm soát hai lớp, loại bỏ điểm bám trụ |
| Recover (Khôi phục) | phục hồi, bài học | điều kiện khôi phục, hotwash, cải tiến |

Đồ án dùng khung này làm "xương sống": chính sách thuộc Govern/Protect, quy trình thuộc Detect/Respond/
Recover, lab kiểm chứng cả hai, đo lường khép lại vòng cải tiến.

## 2.2 Xác thực và danh tính — NIST SP 800-63B-4

NIST SP 800-63B-4 thay đổi căn bản quan niệm cũ về mật khẩu:

- **Ưu tiên độ dài hơn độ phức tạp:** khuyến nghị tối thiểu 8–12 ký tự, cho phép tới ≥64, chấp nhận mọi
  ký tự in được kể cả khoảng trắng; **không** bắt buộc quy tắc thành phần (hoa/thường/ký tự đặc biệt).
- **Chặn danh sách mật khẩu đã lộ/phổ biến** thay vì bắt đổi định kỳ vô nghĩa.
- **Bỏ xoay vòng mật khẩu định kỳ;** chỉ đổi khi có dấu hiệu lộ.
- **Phân mức đảm bảo xác thực (AAL):** AAL2 yêu cầu xác thực đa yếu tố; khuyến khích yếu tố **chống lừa
  đảo** (WebAuthn/khóa cứng) cho tài khoản giá trị cao.

Những nguyên tắc này được cụ thể hóa thành các điều khoản chính sách có thể cưỡng chế trong Chương 3.

## 2.3 Chuỗi tấn công chiếm quyền tài khoản email

Các kỹ thuật chiếm quyền phổ biến:

- **Phishing:** dẫn dụ người dùng nhập thông tin đăng nhập vào trang giả mạo trang đăng nhập của trường.
- **Rải mật khẩu (password spraying):** thử một vài mật khẩu phổ biến trên **nhiều** tài khoản để né cơ
  chế khóa theo tài khoản.
- **Đánh cắp cookie phiên:** lấy cookie phiên đã xác thực để vượt qua cả xác thực đa yếu tố.
- **Lạm dụng quyền quản trị:** dùng chức năng "đăng nhập thay" (impersonate) để truy cập hộp thư người khác.

Sau khi chiếm được, kẻ tấn công thiết lập **điểm bám trụ (persistence)** — phần nguy hiểm nhất vì tồn tại
kể cả sau khi đổi mật khẩu: quy tắc tự chuyển tiếp thư ra ngoài (Sieve), tự đăng ký thiết bị xác thực đa
yếu tố, tạo mật khẩu ứng dụng (app password), đổi email khôi phục, ủy quyền/chia sẻ hộp thư, đặt trả lời
tự động. Quy trình ứng phó (Chương 4) phải rà soát và loại bỏ toàn bộ các điểm này.

## 2.4 Thiết kế diễn tập — NIST SP 800-84 và HSEEP 2020

NIST SP 800-84 và HSEEP 2020 cung cấp phương pháp thiết kế, tổ chức và đánh giá diễn tập: phân biệt diễn
tập trên bàn (tabletop) với diễn tập thực hành (functional/full-scale), vai trò (người điều khiển, người
đánh giá, người chơi, ô mô phỏng), bộ tài liệu diễn tập, và cách tách **chỉ số điều khiển được** (tấn công
thành công hay không, kẻ tấn công còn quyền sau kiểm soát) khỏi **chỉ số phụ thuộc tốc độ con người**
(để tránh thiên lệch do học thuộc kịch bản giữa các vòng).

## 2.5 Công nghệ sử dụng trong phòng lab

| Thành phần | Vai trò |
|---|---|
| **Keycloak 26.x** | Hệ thống quản lý định danh (IdP/OIDC): realm, nhóm, chính sách mật khẩu/MFA, khóa brute-force, nhật ký sự kiện đăng nhập. |
| **mailcow (dockerized)** | Hệ thống thư (Postfix/Dovecot/SOGo webmail) — đối tượng bị tấn công; tích hợp đăng nhập qua Keycloak. |
| **GoPhish v0.12.1 + MTA riêng** | Bên tấn công: chiến dịch phishing, trang đăng nhập giả, rải mật khẩu — tạo nhật ký thật phục vụ diễn tập. |
| **Wazuh 4.x** *(tùy chọn – nâng cao)* | SIEM thu nhật ký, decoder/rule phát hiện và đo thời gian phát hiện. Không bắt buộc; nhật ký gốc đã đáp ứng yêu cầu ghi/thu thập log. |

## 2.6 Khung pháp lý Việt Nam

Email trường chứa dữ liệu cá nhân, nên sự cố chiếm quyền có thể đồng thời là (a) sự cố an ninh mạng và
(b) vi phạm dữ liệu cá nhân, kéo theo hai nhóm nghĩa vụ thông báo/báo cáo:

- **Luật An ninh mạng 2018 và Nghị định 53/2022/NĐ-CP:** nghĩa vụ thông báo/báo cáo sự cố an ninh mạng
  tới cơ quan chuyên trách.
- **Nghị định 13/2023/NĐ-CP về bảo vệ dữ liệu cá nhân:** nếu hộp thư bị chiếm làm lộ dữ liệu cá nhân,
  phát sinh nghĩa vụ thông báo vi phạm trong thời hạn quy định (Mẫu 08 kèm Nghị định).

> Các mốc thời hạn cụ thể và cơ quan tiếp nhận sẽ được trích dẫn chính xác theo văn bản trong báo cáo cuối.
