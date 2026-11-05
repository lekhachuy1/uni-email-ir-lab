<?php
// Lab: Roundcube nối tới docker-mailserver qua alias nội bộ với cert do CA lab cấp.
// Bỏ kiểm tra peer trong mạng lab (chấp nhận cert CA nội bộ / tên alias).
$ssl = ['ssl' => ['verify_peer' => false, 'verify_peer_name' => false, 'allow_self_signed' => true]];
$config['imap_conn_options'] = $ssl;
$config['smtp_conn_options'] = $ssl;
// ManageSieve (quy tắc lọc/chuyển tiếp) — phục vụ demo persistence
$config['managesieve_host'] = 'mail.uni.lab';
$config['managesieve_port'] = 4190;
$config['managesieve_usetls'] = true;
$config['managesieve_conn_options'] = $ssl;
// Lab tiện dụng
$config['product_name'] = 'UNI Webmail (lab)';
$config['des_key'] = 'LabOnlyKeyChangeMe24ch';
