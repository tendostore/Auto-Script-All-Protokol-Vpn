# 🚀 Auto Script X-ray & ZIVPN (Platinum LTS Edition)

**Script Final v.100 (Platinum LTS)** - Solusi manajemen VPS All-in-One yang stabil, cepat, dan estetis.
**By:** Tendo Store

![Banner](https://img.shields.io/badge/Version-v.100%20LTS-blue?style=for-the-badge)
![Support](https://img.shields.io/badge/Support-Lifetime-green?style=for-the-badge)

## 🔥 Fitur Unggulan
* **Zero Margin UI:** Tampilan dashboard rapi mentok kiri tanpa spasi.
* **Triple Status Monitor:** Pantau XRAY, ZIVPN, dan IPTABLES real-time.
* **High Performance:** Auto TCP BBR Congestion Control & Swap RAM 2GB.
* **Smart Account:** Random UUID on Enter & Clean Detail View.
* **Geosite Manager:** Menu routing dengan daftar referensi lengkap.

AUTO SCRIPT TENDO STORE - PLATINUM LTS EDITION
Versi: v.16.02.26 LTS | Creator: Tendo Store

Skrip ini adalah solusi all-in-one manajemen VPS yang dirancang untuk performa tinggi, stabilitas jangka panjang (LTS), dan kemudahan penggunaan. Menggabungkan protokol modern X-ray (VLESS) dan ZIVPN (UDP) dalam satu dashboard yang estetis dan informatif.
1. KEUNGGULAN VISUAL & ANTARMUKA (UI/UX PREMIUM)
Zero Margin Layout: Tampilan dashboard yang presisi dan rapi, diatur mentok ke sisi kiri terminal (zero margin) untuk memaksimalkan ruang baca tanpa spasi yang tidak perlu.
Structured Border Design: Kotak informasi sistem dan menu pilihan dibungkus dengan bingkai garis tegak (│) yang elegan di sisi kiri, memberikan kesan profesional dan terorganisir.
Clean Details View: Tampilan detail akun (saat pembuatan & pengecekan) didesain "bersih" tanpa garis pembatas yang mengganggu, memudahkan penyalinan data (Copy-Paste).
Triple Status Monitor: Memantau status tiga layanan inti sekaligus secara real-time di dashboard utama: XRAY, ZIVPN, dan IPTABLES.
Silent Login & Auto Greeting: Login SSH yang bersih tanpa teks "spam" bawaan Ubuntu (MOTD), langsung disambut dengan Logo Neofetch dan dashboard Tendo Store.
2. FITUR TEKNIS & PERFORMA (HIGH PERFORMANCE)
TCP BBR Congestion Control: Terintegrasi dengan algoritma Google BBR untuk meminimalisir latency dan memaksimalkan kecepatan transfer data, sangat optimal untuk streaming dan gaming.
Auto Swap RAM 2GB: Secara otomatis membuat dan memaksa penggunaan Swap File sebesar 2GB. Ini menjamin VPS dengan RAM kecil tetap stabil dan tidak mudah crash saat beban tinggi.
Core Protocols:
X-ray VLESS: Mendukung mode TLS (443) dan Non-TLS (80) dengan jalur WebSocket.
ZIVPN Tunnel: Mendukung protokol UDP yang handal untuk kebutuhan tunneling khusus.
IPTables : Pengaturan firewall otomatis yang mengamankan dan mengarahkan lalu lintas data dengan efisien.
3. FITUR MANAJEMEN CANGGIH
Smart Account Creation:
Auto UUID: Cukup tekan Enter saat diminta UUID, dan sistem akan membuatkan UUID acak yang unik secara otomatis.
Full Details Info: Menampilkan data lengkap saat akun dibuat: Remarks, City, ISP, IP Address, Domain, Ports, dan Expiry Date.
Routing Geosite Manager: Menu khusus untuk mengatur aturan routing (pemisahan trafik) dengan daftar referensi Geosite lengkap (seperti: tiktok, netflix, gaming, sosmed) yang ditampilkan langsung di menu.
Domain Management: Fitur untuk mengganti domain/subdomain VPS dan memperbarui sertifikat SSL secara otomatis.
Tools Tambahan: Dilengkapi dengan Speedtest (Ookla), Service Restarter, dan Check Services untuk diagnosa masalah.
4. IDENTITAS & DUKUNGAN
Long Term Support (LTS): Versi ini dibangun untuk penggunaan jangka panjang dengan stabilitas yang teruji.
Branding Profesional: Dilengkapi dengan identitas "Script BY: Tendo Store" dan kontak dukungan resmi via WhatsApp yang tertera jelas di dashboard.
Status Lifetime: Menampilkan status "Expiry In: Lifetime" sebagai jaminan penggunaan tanpa batas waktu.
Kesimpulan:
Script ini bukan sekadar alat instalasi VPN biasa, melainkan sistem manajemen server yang estetis, cepat, dan cerdas. Cocok untuk penggunaan pribadi maupun untuk dijual kembali (reseller) karena tampilannya yang sangat profesional.

## 💻 Cara Install (One-Click)
Copy dan paste perintah di bawah ini ke terminal VPS (Wajib **Ubuntu 20.04 - 22.04**):

```bash
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -w net.ipv6.conf.default.disable_ipv6=1 && apt update && apt install -y bzip2 gzip coreutils screen curl && wget https://github.com/tendostore/Tendo-Script-atau-Auto-Installer/raw/main/setup && chmod +x setup && ./setup
