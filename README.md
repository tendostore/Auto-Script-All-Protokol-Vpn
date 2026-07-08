# Auto Script All Protokol VPN — Tendo Store

Auto installer all-in-one untuk VPS Ubuntu: **Xray (VMess / VLess / Trojan)**, **ZIVPN UDP**, dan **SSH-WS**, lengkap dengan panel manajemen berbasis menu dan integrasi bot Telegram.

<p align="left">
  <img alt="shell" src="https://img.shields.io/badge/shell-bash-1f425f.svg">
  <img alt="platform" src="https://img.shields.io/badge/platform-Ubuntu%2020.04%20%7C%2022.04-orange">
  <img alt="license" src="https://img.shields.io/badge/license-MIT-blue">
  <img alt="maintained" src="https://img.shields.io/badge/maintained-yes-brightgreen">
</p>
<p align="left">
  <a href="https://github.com/tendostore/Auto-Script-All-Protokol-Vpn/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/tendostore/Auto-Script-All-Protokol-Vpn?style=social"></a>
  <a href="https://github.com/tendostore/Auto-Script-All-Protokol-Vpn/network/members"><img alt="GitHub forks" src="https://img.shields.io/github/forks/tendostore/Auto-Script-All-Protokol-Vpn?style=social"></a>
  <a href="https://github.com/tendostore/Auto-Script-All-Protokol-Vpn/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues/tendostore/Auto-Script-All-Protokol-Vpn"></a>
  <a href="https://github.com/tendostore/Auto-Script-All-Protokol-Vpn/commits/main"><img alt="Last commit" src="https://img.shields.io/github/last-commit/tendostore/Auto-Script-All-Protokol-Vpn"></a>
</p>

---

## ✨ Fitur

- **Multi-protokol Xray** — VMess, VLess, dan Trojan, masing-masing dengan mode WS, WS-TLS, gRPC, dan HTTP Upgrade.
- **SSH-WS + Dropbear** — akses SSH tunneling via WebSocket, lengkap dengan UDPGW (BadVPN) untuk gaming/voice.
- **ZIVPN UDP** — dukungan protokol UDP terpisah untuk kebutuhan tunneling khusus.
- **Panel manajemen (`menu`)** — buat, hapus, perpanjang, kunci/buka akun, serta akun trial, langsung dari terminal.
- **Manajemen domain otomatis** — pilih domain random gratis (via Cloudflare) atau gunakan domain sendiri.
- **SSL otomatis** — sertifikat self-signed di-generate otomatis saat instalasi.
- **Bot Telegram** — notifikasi pembuatan akun secara real-time, plus bot client terpisah untuk melayani pelanggan (order, info akun, dsb).
- **Limit IP & kuota bandwidth** per akun, dengan auto-lock saat kuota/masa aktif habis.
- **Backup & restore** konfigurasi (Xray, ZIVPN, domain, bot, banner) dalam satu file `.zip`.
- **Optimasi sistem otomatis** — swap, BBR, dan tuning dasar saat instalasi.

---

## 📋 Requirement

| Komponen | Spesifikasi Minimum |
|---|---|
| OS | Ubuntu 20.04 / 22.04 (x86_64) — VPS bersih (fresh install) |
| RAM | 512 MB (disarankan 1 GB+) |
| Akses | Root / `sudo` |
| Domain | Domain/subdomain sendiri **atau** gunakan opsi domain random gratis |
| Cloudflare | Akun Cloudflare + API Token *scoped* (hanya diperlukan jika memakai opsi domain random) |

---

## 📸 Screenshot

> Tambahkan screenshot tampilan `menu` di sini. Upload gambar ke folder `assets/` di repo, lalu ganti baris di bawah ini:
>
> ```markdown
> ![Menu Utama](assets/menu-utama.png)
> ```

---

## 🚀 Instalasi

```bash
apt update -y && apt install -y curl
curl -O https://raw.githubusercontent.com/tendostore/Auto-Script-All-Protokol-Vpn/main/install.sh
chmod +x install.sh
./install.sh
```

Saat instalasi berjalan, kamu akan diminta memilih:

1. **Domain Random Tendo** — domain otomatis di-generate & didaftarkan ke DNS.
2. **Domain Sendiri** — masukkan domain yang **A record**-nya sudah diarahkan ke IP VPS.

Proses instalasi berjalan otomatis (dependency, SSL, Xray, ZIVPN, SSH-WS, firewall) dan akan menampilkan status di setiap tahap.

Setelah selesai, jalankan:

```bash
menu
```

untuk membuka panel manajemen.

---

## ⚙️ Konfigurasi Awal (Wajib jika pakai domain random)

Script menggunakan Cloudflare API untuk mendaftarkan domain random secara otomatis. Sebelum menjalankan `install.sh`, buka file dan isi variabel berikut:

```bash
CF_TOKEN="ISI_CLOUDFLARE_API_TOKEN_SCOPED_DISINI"
CF_ZONE_ID="isi_zone_id_domain_kamu"
```

> **Penting — keamanan token:**
> - Gunakan **Cloudflare API Token** yang di-*scope* hanya untuk permission `Zone:DNS:Edit` pada satu zona domain kamu. **Jangan** pakai Global API Key.
> - Jangan pernah commit token asli ke repository publik. Simpan sebagai secret/environment variable jika script ini dipakai di CI atau dibagikan ke pihak lain.
> - Jika token pernah bocor/ter-*expose*, segera revoke dan buat token baru dari **Cloudflare Dashboard → My Profile → API Tokens**.

---

## 🖥️ Panel Manajemen (`menu`)

| Menu | Fungsi |
|---|---|
| `1` SSH Account | Kelola akun SSH-WS (create/delete/renew/lock/unlock/trial) |
| `2` X-Ray Manager | Kelola akun VMess / VLess / Trojan |
| `3` ZIVPN UDP | Kelola akun ZIVPN |
| `4` Bot Telegram Setup | Setup bot notifikasi admin & bot client untuk pelanggan |
| `5` Features | Backup/restore, reinstall OS, benchmark, dan tool tambahan |
| `x` Exit | Keluar dari panel |

Setiap protokol mendukung operasi standar berikut dari sub-menunya masing-masing:

- **Create** — buat akun baru (username, password/UUID, masa aktif, limit IP, kuota).
- **Delete** — hapus akun beserta konfigurasinya.
- **Renew** — perpanjang masa aktif akun.
- **Check Config** — tampilkan ulang link/konfigurasi akun.
- **Trial** — buat akun percobaan dengan durasi singkat (misal `10m`, `1h`).
- **Lock / Unlock** *(tersedia untuk beberapa protokol)* — nonaktifkan sementara tanpa menghapus data akun.

---

## 🤖 Bot Telegram

Script menyediakan dua jenis bot:

1. **Bot Admin (Notifikasi)** — mengirim notifikasi ke Telegram admin setiap kali ada akun baru dibuat, login, atau proses backup selesai.
2. **Bot Client** — bot terpisah yang bisa diarahkan ke pelanggan untuk melihat info order, hubungi admin, dan info promo, tanpa memberi akses ke panel admin.

Setup dilakukan lewat menu `[4] BOT TELEGRAM SETUP`, cukup masukkan **Bot Token** (dari [@BotFather](https://t.me/BotFather)) dan **Chat ID**.

---

## 🔒 Catatan Keamanan

- Token bot Telegram dan Cloudflare API disimpan di server dengan permission terbatas (`600`/`700`) — pastikan kamu tidak menjalankan script ini di server yang dipakai bersama (shared hosting/multi-user) tanpa isolasi yang jelas.
- Biner pihak ketiga (`badvpn-udpgw`, `zivpn`) diunduh dari repository publik di GitHub saat instalasi. Selalu jalankan script dari sumber resmi repo ini untuk menghindari modifikasi tidak sah.
- Gunakan `fail2ban` (sudah termasuk dalam instalasi) dan pertimbangkan menambahkan proteksi tambahan seperti port-knocking atau pembatasan akses SSH via firewall untuk lingkungan produksi.
- Selalu perbarui script ke versi terbaru dari repo ini untuk mendapatkan perbaikan keamanan.

---

## 🧩 Struktur Data Akun

Akun disimpan dalam format teks berpemisah `|` di:

```
/usr/local/etc/xray/ssh.txt
/usr/local/etc/xray/vmess.txt
/usr/local/etc/xray/vless.txt
/usr/local/etc/xray/trojan.txt
/etc/zivpn/zivpn.txt
```

Konfigurasi utama Xray berada di `/usr/local/etc/xray/config.json`.

---

## ❓ Troubleshooting

| Masalah | Kemungkinan Penyebab | Solusi |
|---|---|---|
| Domain tidak resolve | A record belum diarahkan / DNS propagasi belum selesai | Cek dengan `ping domainkamu.com`, tunggu propagasi DNS |
| Xray gagal start | `config.json` korup | Jalankan `xray -test -config /usr/local/etc/xray/config.json` untuk cek error |
| Bot Telegram tidak merespons | Token/Chat ID salah | Cek ulang lewat menu `[4] BOT TELEGRAM SETUP` |
| Domain random gagal dibuat | `CF_TOKEN`/`CF_ZONE_ID` salah atau belum diisi | Pastikan token scoped valid dan zone ID sesuai domain |

---

## 📄 Lisensi

Distribusikan dan gunakan skrip ini dengan bijak. Lihat file [`LICENSE`](LICENSE) untuk detail lisensi.

## 📞 Kontak & Dukungan

- **WhatsApp:** +62 822-2446-0678
- **Telegram:** [@tendo_32](https://t.me/tendo_32) · Grup: [t.me/tendo32](https://t.me/tendo32)

---

<p align="center"><i>Dibuat dan dikelola oleh Tendo Store.</i></p>
