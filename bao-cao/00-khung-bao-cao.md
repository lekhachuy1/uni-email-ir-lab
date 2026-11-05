# Khung báo cáo đồ án — 8 chương

**Đề tài:** Phản ứng sự cố tấn công mạng — thu hẹp vào *chiếm quyền và lạm dụng
tài khoản email đại học* (account takeover / account misuse).

**Chuẩn tham chiếu:** NIST SP 800-61r3 (ánh xạ CSF 2.0: Govern/Identify/Protect/
Detect/Respond/Recover), NIST SP 800-63B-4 (xác thực), NIST SP 800-84 & HSEEP 2020
(thiết kế diễn tập), và pháp luật Việt Nam (Luật ANM 2018, NĐ 13/2023 về bảo vệ
dữ liệu cá nhân, NĐ 53/2022).

**Nguyên tắc xuyên suốt (chuỗi giá trị):**
`chính sách → quy trình → lab chứng minh cả hai → đo lường → cải tiến quay lại chính sách/quy trình`.

**Quy ước trình bày:** log ghi UTC, báo cáo quy đổi UTC+7. Mã sự cố `INC-YYYYMMDD-NN`,
mức P1–P4. Biểu mẫu BC-01/YC-02/BB-03/CL-01..03. Mốc thời gian T0–T6, chỉ số
MTTD/MTTA/MTTC/MTTR. Hai cấu hình đối chứng **v0** (mặc định, yếu) và **v1** (đã áp chính sách).

---

## Bảng phân công theo chương

| Chương | Tiêu đề | Phụ trách chính | Trụ / Hàm CSF | Trạng thái |
|---|---|---|---|---|
| 1 | Mở đầu | Cả nhóm | — | khung |
| 2 | Cơ sở lý thuyết & chuẩn | Cả nhóm | — | khung |
| 3 | Chính sách & quản trị danh tính (IAM) | Đỗ Quốc Huynh | Govern/Identify/Protect | **đã viết** |
| 4 | Quy trình phản ứng sự cố | Nguyễn Bá Khánh | Detect/Respond/Recover | **đã viết** |
| 5 | Xây dựng phòng lab mô phỏng | Lê Khắc Huy | (chứng minh) | khung |
| 6 | Kịch bản tấn công & diễn tập | Lê Khắc Huy | (chứng minh) | khung |
| 7 | Đo lường, kết quả & đánh giá | Trần Quốc Kiệt | (đo lường) | khung |
| 8 | Kết luận & hướng phát triển | Cả nhóm | — | khung |
| PL | Phụ lục (biểu mẫu, cấu hình, TC, bằng chứng) | Kiệt + Huy | — | một phần |

---

## Chương 1 — Mở đầu
1.1 Bối cảnh & tính cấp thiết — email là danh tính gốc của trường (reset mật khẩu
    nhiều dịch vụ đổ về đây); một tài khoản bị chiếm → phishing nội bộ, lộ dữ liệu
    cá nhân, lan ngang. Nêu số liệu phishing giáo dục (trích nguồn).
1.2 Phát biểu bài toán — vì sao thu hẹp vào *account takeover* thay vì "tấn công mạng" chung.
1.3 Mục tiêu & câu hỏi nghiên cứu — 6 câu hỏi Q1–Q6 (xem §khung): chính sách có cưỡng
    chế được không; tấn công thành công trên v0 & bị chặn trên v1; phát hiện bằng log
    nào, nhanh ra sao; sau mỗi bước kiểm soát kẻ tấn công còn truy cập không; ảnh hưởng
    người dùng hợp lệ; bằng chứng có đủ dựng lại dòng thời gian & phạm vi.
1.4 Phạm vi & giới hạn — lab cô lập, dữ liệu/tài khoản giả, không egress Internet;
    **nêu rõ giới hạn thực tế**: triển khai gần single-host (xem STATUS.md), không
    phân vùng nhiều VLAN như thiết kế mục tiêu.
1.5 Phương pháp — nghiên cứu chuẩn → thiết kế chính sách/quy trình → dựng lab →
    diễn tập hai vòng (v0/v1) theo HSEEP → đo lường → rút kinh nghiệm.
1.6 Đóng góp & phân công 4 thành viên (bảng trên).
1.7 Cấu trúc báo cáo.

## Chương 2 — Cơ sở lý thuyết & chuẩn
2.1 Vòng đời ứng phó sự cố — NIST SP 800-61r3 và ánh xạ CSF 2.0 (6 hàm).
2.2 Xác thực & danh tính — NIST SP 800-63B-4: AAL, MFA, chính sách mật khẩu hiện đại
    (độ dài > độ phức tạp, blocklist, bỏ xoay vòng định kỳ), chống phishing (WebAuthn).
2.3 Chuỗi tấn công chiếm quyền email — phishing / rải mật khẩu (password spraying) /
    đánh cắp cookie phiên / lạm dụng quyền; các điểm bám trụ (persistence): quy tắc
    chuyển tiếp Sieve, TOTP kẻ tấn công tự đăng ký, app password, đổi email khôi phục,
    ủy quyền hộp thư.
2.4 Công nghệ dùng trong lab — Keycloak (IdP/OIDC), mailcow (Postfix/Dovecot/SOGo),
    Wazuh (SIEM), GoPhish (mô phỏng tấn công). Nêu đúng phiên bản đã dùng.
2.5 Thiết kế diễn tập — NIST SP 800-84, HSEEP 2020: loại hình, vai trò, tài liệu, đo lường.
2.6 Khung pháp lý Việt Nam — nghĩa vụ thông báo/báo cáo sự cố ANM và vi phạm DLCN,
    thời hạn (≤24h/≤72h), cơ quan tiếp nhận. (Chi tiết ở `references/standards.md`.)

## Chương 3 — Chính sách & quản trị danh tính  →  xem `ch3-chinh-sach-iam.md`

## Chương 4 — Quy trình phản ứng sự cố  →  xem `ch4-quy-trinh-ir.md`

## Chương 5 — Xây dựng phòng lab mô phỏng (Huy) — CẦN LAB
5.1 Kiến trúc mục tiêu (phân vùng mạng) vs kiến trúc đã dựng (đối chiếu STATUS.md).
5.2 Lựa chọn kiến trúc PA1 (mailcow + Keycloak IdP) — tiêu chí go/no-go của spike.
5.3 Triển khai Keycloak + PostgreSQL + TLS nội bộ; realm `uni`, 5 nhóm, 11 tài khoản.
5.4 Triển khai mailcow + tích hợp IdP; app password & phạm vi TFA.  ← *chưa cài*
5.5 Triển khai Wazuh + decoder/rule tùy biến (UC1–UC9).  ← *chưa cài*
5.6 Máy tấn công: GoPhish + MTA riêng (evil.lab) + trang đăng nhập Keycloak giả.
5.7 CA nội bộ, DNS, baseline đăng nhập nền.
5.8 Hai cấu hình đối chứng v0/v1 — bảng khác biệt.
> Số liệu/ảnh cần: topo mạng, ảnh realm, đầu ra `kcadm`, kết quả `wazuh-logtest`.

## Chương 6 — Kịch bản tấn công & diễn tập (Huy) — CẦN LAB
6.1 Phương pháp diễn tập hai vòng (v0 rồi v1); tách chỉ số control-driven vs human-speed.
6.2 D1 Phishing → chiếm quyền: D1a (v0 thành công), D1b (v1 MFA chặn), D1c (đánh cắp cookie
    phiên + ma trận hiệu lực kiểm soát).
6.3 D2 Rải mật khẩu & lạm dụng: D2a (spraying → spam), D2b (mạo danh admin), D2c (lockout-DoS).
6.4 D3 Quy trình & con người: D3a (báo động giả thiết bị mới), D3b (quên mật khẩu),
    D3c (mất MFA + IT vắng), D3d (vishing helpdesk — phải bị từ chối).
6.5 15 ca kiểm thử cấu hình TC-01..TC-17 chứng minh chính sách Huynh được cưỡng chế.
6.6 Kiểm thử âm tính sau T3 (5 đường thử lại) và sau T5 (người dùng dùng lại được).
> Số liệu/ảnh cần: log mỗi hồi, ảnh T0–T6, video, biểu mẫu đã điền, `Evidence/` + SHA-256.

## Chương 7 — Đo lường, kết quả & đánh giá (Kiệt) — CẦN DIỄN TẬP
7.1 Mô hình đo lường — T0–T6, MTTD/MTTA/MTTC/MTTR; nguồn số liệu từng chỉ số.
7.2 Kết quả vòng 1 (v0) — bảng số liệu, tỷ lệ tấn công thành công, cảnh báo có kích hoạt.
7.3 Kết quả vòng 2 (v1) — tương tự.
7.4 So sánh v0 vs v1 — biểu đồ; trả lời Q2/Q3/Q4.
7.5 Ảnh hưởng người dùng hợp lệ (Q5) — tỷ lệ báo động giả, thời gian khôi phục hợp lệ.
7.6 Đánh giá bằng chứng (Q6) — có dựng lại được T0 chỉ từ log không.
7.7 Hotwash & bài học → ánh xạ ngược về chương 3/4 (cải tiến).
> Số liệu/ảnh cần: metrics-sheet.csv đã điền, biểu đồ, AAR.

## Chương 8 — Kết luận & hướng phát triển
8.1 Trả lời 6 câu hỏi nghiên cứu.
8.2 Hạn chế của đề tài (single-host, RAM, phạm vi diễn tập).
8.3 Hướng phát triển (PA3 Dovecot OAuth2, WebAuthn chống phishing, tự động hóa active-response,
    mở rộng sang Microsoft 365/Google Workspace thật).

## Phụ lục
- A. Bộ biểu mẫu BC-01/YC-02/BB-03/CL-01..03 (xem `../lab/forms/`).
- B. Trích cấu hình v0/v1 (Keycloak policy, mailcow, kịch bản kcadm).
- C. Bảng 17 ca kiểm thử cấu hình TC-01..TC-17 (kết quả).
- D. Decoder/rule Wazuh (UC1–UC9).
- E. Gói bằng chứng & SHA256SUMS.
- F. Tài liệu diễn tập: ExPlan, MSEL/injects, EEG, AAR.
