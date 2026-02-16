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

## 💻 Cara Install (One-Click)
Copy dan paste perintah di bawah ini ke terminal VPS (Wajib **Ubuntu 20.04 - 22.04**):

```bash
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -w net.ipv6.conf.default.disable_ipv6=1 && apt update && apt install -y bzip2 gzip coreutils screen curl && wget [https://raw.githubusercontent.com/tendostore/Tendo-Script-atau-Auto-Installer/main/install.sh](https://raw.githubusercontent.com/tendostore/Tendo-Script-atau-Auto-Installer/main/install.sh) && chmod +x install.sh && ./install.sh
