#!/usr/bin/env python3
"""Sinh đăng nhập hợp lệ nền cho lab (để log không chỉ toàn hoạt động tấn công).
Đọc users.csv (email,app_password,role) và lặp đăng nhập IMAP vào mailcow theo lịch có nhiễu.
- Giờ hành chính (07-18 UTC+7) -> đăng nhập dày hơn, mô phỏng SV/GV/NV ở CAMPUS.
- Buổi tối -> chỉ vài tài khoản role=home (ví dụ gv01 ở nhà), tạo cảnh báo-nhầm hợp lệ cho UC3 (D3a).
Dùng app password vì ở chế độ IdP (PA1) IMAP chỉ nhận app password. Chỉ chạy trong lab.
"""
import csv, imaplib, os, random, time
from datetime import datetime, timezone, timedelta

IMAP_HOST = os.environ.get("IMAP_HOST", "mail.uni.lab")
IMAP_PORT = int(os.environ.get("IMAP_PORT", "993"))
USERS_FILE = os.environ.get("USERS_FILE", "/data/users.csv")
TZ = timezone(timedelta(hours=7))  # giờ VN để quyết định "giờ hành chính"

def load_users():
    with open(USERS_FILE, newline="") as f:
        return [r for r in csv.DictReader(f) if r.get("email")]

def login_once(u):
    try:
        m = imaplib.IMAP4_SSL(IMAP_HOST, IMAP_PORT)  # dovecot ghi 1 dòng login success
        m.login(u["email"], u["app_password"])
        m.select("INBOX"); m.search(None, "ALL"); m.logout()
        print(f"{datetime.now(timezone.utc).isoformat()} OK {u['email']}", flush=True)
    except Exception as e:
        print(f"{datetime.now(timezone.utc).isoformat()} ERR {u['email']} {e}", flush=True)

def main():
    users = load_users()
    print(f"baseline: {len(users)} tài khoản, IMAP {IMAP_HOST}:{IMAP_PORT}", flush=True)
    while True:
        hour = datetime.now(TZ).hour
        office = 7 <= hour < 18
        pool = users if office else [u for u in users if u.get("role") == "home"]
        for u in random.sample(pool, k=min(len(pool), random.randint(1, 3))):
            login_once(u)
            time.sleep(random.uniform(2, 8))
        # giờ hành chính: chu kỳ ngắn; ngoài giờ: thưa
        time.sleep(random.uniform(60, 180) if office else random.uniform(600, 1200))

if __name__ == "__main__":
    main()
