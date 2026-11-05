# Trạng thái dự án & phân tích thiếu sót

Cập nhật: 2026-10-27.

## 1. Kiến trúc: thiết kế mục tiêu vs thực tế đã dựng

`lab/README.md` mô tả kiến trúc **nhiều VM phân vùng mạng** (10.10.10/20, 203.0.113…) — đó là thiết kế
*mục tiêu/lý tưởng*. Thực tế hiện triển khai **gọn hơn**:

| Thành phần | Thiết kế mục tiêu | Thực tế đã dựng |
|---|---|---|
| Keycloak (IdP) | sso.uni.lab 10.10.20.11 | VM Ubuntu 26.04 **192.168.238.128** (Docker) |
| Máy tấn công (GoPhish) | 203.0.113.66 | **Máy Windows thật** (IP phía VM: 192.168.238.1) |
| mailcow, Wazuh | 10.10.20.10 / .12 | **chưa cài** |
| Phân vùng mạng | router + VLAN | 1 subnet 192.168.238.0/24 (NAT VMware) |

**Hệ quả cần nêu trong báo cáo (giới hạn):** vì chạy gần như single-host, IP nguồn trong log có thể là
gateway Docker (172.18.0.1) thay vì IP "công cộng" → luật phát hiện "đăng nhập IP lạ" (UC3) kém thực tế hơn.
Điểm cộng: GoPhish nằm trên máy Windows (192.168.238.1) **khác** VM → vẫn có một IP tấn công tách biệt.

## 2. Trạng thái theo hạng mục

| Hạng mục | Trạng thái | Ghi chú |
|---|---|---|
| Keycloak + realm v0 (11 TK, 5 nhóm) | ✅ Đã dựng, chạy được | admin `admin`/`<REDACTED-PW>` |
| CA nội bộ + cert | ✅ | làm trên VM |
| GoPhish | ⚠️ Đã cài, cấu hình, nhưng hay bị tắt (RAM) | nên tạo Scheduled Task |
| Cấu hình **v1** (siết MFA/mật khẩu/brute-force) | ❌ Chưa áp dụng | thiếu → chưa có so sánh v0/v1 |
| mailcow (webmail — đối tượng bị tấn công) | ❌ Chưa cài | **thiếu lớn nhất** |
| Wazuh (phát hiện) + decoder/rule | ❌ Chưa cài (file cấu hình đã có) | thiếu → chưa đo được MTTD |
| Baseline (đăng nhập nền) | ❌ Chưa chạy | cần mailcow trước |
| Diễn tập D1/D2/D3 | ❌ Chưa chạy lần nào | → chưa có log/bằng chứng/số liệu |
| Biểu mẫu BC-01/YC-02/BB-03/CL-01..03 | ✅ Mẫu đã có (`lab/forms/`) | chưa điền cho INC thật |
| MSEL/EEG/AAR/metrics | ✅ Template (trong skill) | chưa điền |
| Báo cáo đồ án (chương) | ❌ Chưa viết | |
| Slide thuyết trình | ❌ Chưa làm | |

## 3. Thiếu sót then chốt (ưu tiên xử lý)

1. **Chưa chạy diễn tập end-to-end** → không có log thật, không bằng chứng, không số liệu. Đây là thứ hội
   đồng muốn thấy nhất. Chặn bởi: thiếu mailcow + Wazuh.
2. **Thiếu mailcow** — không có webmail/hộp thư để tấn công; GoPhish chưa gửi được mail thật.
3. **Thiếu Wazuh** — không chứng minh được khả năng phát hiện (UC1–UC9), không có MTTD.
4. **Chưa có v1** — thiếu phần so sánh v0 vs v1, vốn là xương sống của mục "đánh giá & cải tiến".
5. **Chưa có gói bằng chứng** (log + SHA-256 + ảnh + video) và **chưa điền biểu mẫu** cho một INC mẫu.
6. **RAM VM 7.2 GB** không đủ chạy đồng thời Keycloak + mailcow + Wazuh → cần nâng RAM (≥12–16 GB) hoặc
   chạy tuần tự.

## 4. Lộ trình đề xuất để đồ án "đủ bảo vệ"

1. Nâng RAM VM → cài **mailcow**, tích hợp IdP Keycloak (kiểm 5 mục go/no-go PA1).
2. Cài **Wazuh**, nạp decoder/rule, kiểm `wazuh-logtest` với log thật.
3. Chạy baseline + **Diễn tập vòng 1 (v0)**: D1a (phishing→ATO), D2a (rải mật khẩu), D3c/D3d (mất MFA/mạo danh).
   Thu log, ảnh, video; điền BC-01/CL-02/BB-03; đo T0–T6.
4. Áp **v1**, chạy **vòng 2**; lập bảng so sánh v0 vs v1.
5. Viết báo cáo theo khung 8 chương + slide; đóng gói bằng chứng có mã băm.

## 5. Nếu không kịp cài đủ: phương án demo tối thiểu
Chỉ với Keycloak: demo chính sách v0/v1 + đăng nhập từ IP tấn công + log sự kiện + kiểm soát bằng `contain.sh`
+ khôi phục. (Xem hướng dẫn demo đã trao đổi.) Vẫn thể hiện đủ 4 trụ: chính sách, quy trình, lab, đo lường.
