# Chương 5 — Xây dựng phòng lab mô phỏng

*Phụ trách: Lê Khắc Huy. Chương này mô tả việc dựng môi trường kiểm chứng. Các mục đánh dấu*
*「đã triển khai」 là kết quả thực tế; mục 「kế tiếp」 là phần đang hoàn thiện theo kế hoạch.*

## 5.1 Kiến trúc: thiết kế mục tiêu và thực tế triển khai

Thiết kế lý tưởng là một mạng phân vùng sau router (DNS, NTP, tường lửa, syslog): vùng máy trạm, vùng
máy chủ (mail, định danh, SIEM, CA), và các vùng "Internet" mô phỏng cho máy tấn công và hộp thư cá
nhân bên ngoài, dùng dải địa chỉ RFC 5737 để trông như công cộng trong nhật ký mà không chạm tới ai.

Do điều kiện phần cứng, đồ án triển khai gọn hơn và **nêu rõ đây là một giới hạn**:

| Thành phần | Thiết kế mục tiêu | Thực tế triển khai |
|---|---|---|
| Keycloak (IdP) | sso.uni.lab, vùng máy chủ | VM Ubuntu (Docker) — **đã triển khai** |
| Máy tấn công (GoPhish) | vùng "Internet" riêng | Máy vật lý tách biệt — **đã triển khai** |
| Mail server | vùng máy chủ | **kế tiếp** |
| Phân vùng mạng | router + nhiều VLAN | một subnet (NAT), máy tấn công tách máy vật lý |

**Hệ quả cần nêu:** vì chạy gần single-host, địa chỉ nguồn trong một số nhật ký có thể là gateway nội bộ
thay vì IP "công cộng", làm luật phát hiện "đăng nhập từ IP lạ" kém thực tế hơn. Bù lại, máy tấn công nằm
trên một máy vật lý khác nên vẫn có một địa chỉ nguồn tách biệt phục vụ phân tích.

## 5.2 Lựa chọn phương án kiến trúc

Ba phương án được cân nhắc: **PA1** mail server + Keycloak làm IdP (khuyến nghị); **PA2** chỉ mail server
(một kho định danh, dự phòng); **PA3** Keycloak + webmail OIDC + Dovecot OAuth2 (thu hồi phiên tốt nhất,
khó nhất). Nhóm chọn **PA1** vì phản ánh đúng mô hình trường hiện đại (đăng nhập một lần qua IdP) và cho
phép nghiên cứu một đặc thù quan trọng: **hệ thống có hai kho định danh**, nên khóa ở một lớp không đủ.

Tiêu chí go/no-go khi chọn PA1 (giai đoạn thử nghiệm — spike): đăng nhập webmail đi qua Keycloak; xác
định được đường xác thực IMAP/SMTP; vô hiệu hóa trong Keycloak chặn được đăng nhập web; biết chính xác
hành động nào đóng được phiên webmail; cả hai lớp đều ghi địa chỉ nguồn.

## 5.3 Triển khai Keycloak + PostgreSQL + TLS (đã triển khai)

Hệ thống định danh chạy bằng Docker Compose gồm Keycloak 26.8.1 và PostgreSQL 18, dùng chứng chỉ TLS do
một CA nội bộ cấp. Realm `uni` đã tạo với:

- **5 nhóm:** SinhVien, GiangVien, NhanVien, IT-Helpdesk, IT-MailAdmin.
- **11 tài khoản mẫu:** sv01–sv06, gv01–gv02, nv01, it.helpdesk, adm.mail.
- Ghi sự kiện LOGIN / LOGIN_ERROR / UPDATE_CREDENTIAL / IMPERSONATE ra tệp để phục vụ phân tích; nâng
  mức ghi sự kiện thành công lên `info` (mặc định bị ẩn ở mức DEBUG).

**Ba bài học triển khai (đã khắc phục và ghi lại trong mã nguồn cấu hình):**
1. PostgreSQL 18 đổi quy ước thư mục dữ liệu → phải gắn volume tại `/var/lib/postgresql`.
2. Chứng chỉ của máy chủ định danh cần thêm `localhost` + `127.0.0.1` vào SAN để công cụ dòng lệnh
   `kcadm` hoạt động.
3. `kcadm` cần một truststore tạo từ chứng chỉ CA nội bộ để tin tưởng kết nối TLS.

## 5.4 Triển khai mail server + tích hợp đăng nhập (kế tiếp)

Mail server (mailcow) sẽ được dựng ở cấu hình gọn cho lab: **tắt quét virus (ClamAV) và full-text (Solr)**
để chạy trong khoảng 6 GB RAM, tích hợp đăng nhập qua Keycloak (OIDC Identity Provider). Các điểm cần
kiểm chứng thực nghiệm: đường xác thực IMAP/SMTP dùng app password; việc đặt hộp thư về trạng thái "đình
chỉ" (nhận thư nhưng không đăng nhập) có đóng được phiên webmail đang mở không.

## 5.5 Hạ tầng phụ trợ

- **CA nội bộ:** cấp chứng chỉ cho máy chủ định danh, mail và trang phishing; cài chứng chỉ gốc vào trình
  duyệt máy trạm (cần cho HTTPS tin cậy và WebAuthn).
- **Máy tấn công:** GoPhish v0.12.1 + một MTA riêng với tên miền trông giống thật, để thư lừa đảo đi qua
  kiểm tra SPF/DMARC như thật thay vì gửi từ chính máy chủ (tránh "phish từ cùng máy chủ" làm sai kết quả).
- **Baseline:** kịch bản sinh hoạt động đăng nhập nền của người dùng hợp lệ, để "đăng nhập bất thường"
  có ý nghĩa khi so sánh.

## 5.6 Hai cấu hình đối chứng v0 và v1

| Hạng mục | v0 (mặc định, yếu) | v1 (đã áp chính sách) |
|---|---|---|
| MFA cho sinh viên | Không | Bật/khuyến nghị TOTP |
| Chính sách mật khẩu | Lỏng, không chặn danh sách lộ | ≥12 ký tự + chặn danh sách lộ + lịch sử 5 |
| Direct Grant (bỏ qua MFA) | Bật | Tắt cho client người dùng |
| IMAP/SMTP cho SV | Mật khẩu thường | Không (chỉ app password có kiểm soát) |
| Chuyển tiếp ra ngoài | Cho phép | Chặn với sinh viên |
| Khóa brute-force | Lỏng/không | Tạm thời, tăng dần sau 10 lần |
| Ghi log đăng nhập thành công | Ẩn (DEBUG) | Hiện (info) + thu thập tập trung |

Cấu hình v1 là bắt buộc (chứng minh chính sách được cưỡng chế); việc chạy thêm v0 để so sánh là phần
nâng cao.

> *Hình cần bổ sung:* sơ đồ kiến trúc lab; ảnh realm Keycloak (nhóm, tài khoản); ảnh cấu hình chính sách.
