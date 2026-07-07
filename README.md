# Auto Script All Protokol VPN — Tendo Store

Script installer otomatis (all-in-one) untuk membangun VPS multi-protokol: **X-ray (VMess/VLESS/Trojan)**, **SSH WebSocket + Dropbear**, dan **ZIVPN (UDP)** — lengkap dengan panel menu manajemen akun, notifikasi Telegram, auto-expired, limit IP, dan quota bandwidth.

```bash
bash <(curl -Ls https://raw.githubusercontent.com/tendostore/Auto-Script-All-Protokol-Vpn/main/install.sh)
```

---

## ✨ Fitur

- **Multi-protokol dalam satu port**: VMess, VLESS, Trojan — masing-masing tersedia dalam varian WS, gRPC, dan HTTP Upgrade, semuanya bisa jalan di port **443** (TLS) dan **80** (non-TLS) lewat mekanisme *fallback* Xray.
- **SSH WebSocket** (backend Dropbear 2019) untuk trik HTTP Custom / HTTP Injector, tersedia di port 80, 443, 8080, 2082, 2083, 8880, dan 8443 (TLS via stunnel).
- **ZIVPN (UDP)** untuk kebutuhan tunneling berbasis UDP.
- **Domain otomatis** (random subdomain gratis) atau domain milik sendiri, lengkap dengan SSL self-signed.
- **Panel menu CLI** (`menu`) untuk kelola akun: tambah/hapus/renew user, lihat status, monitoring trafik.
- **Auto-kill akun expired**, **limit IP per akun** (auto-lock 10 menit jika multi-login), dan **quota bandwidth** per user — semua jalan otomatis via cron.
- **Notifikasi Telegram**: akun baru dibuat, user login, multi-login terdeteksi, kuota habis, sampai auto-backup konfigurasi VPS terjadwal.
- **Bot client Telegram** terpisah untuk reseller (opsional).
- **Optimasi sistem**: BBR, swap otomatis, iptables persistent, fail2ban untuk proteksi brute-force SSH.

---

## 📋 Requirement

| Kebutuhan | Spesifikasi |
|---|---|
| OS | Ubuntu 20.04 / 22.04 atau Debian 10/11 (fresh install disarankan) |
| Akses | Root |
| RAM | Minimal 512 MB (disarankan 1 GB+) |
| Domain | Opsional — bisa pakai domain sendiri atau auto-generate |

---

## 🚀 Instalasi

```bash
apt update -y && apt install -y curl
bash <(curl -Ls https://raw.githubusercontent.com/tendostore/Auto-Script-All-Protokol-Vpn/main/install.sh)
```

Saat instalasi berjalan, kamu akan diminta memilih:

1. **Jenis domain** — domain random otomatis atau domain milik sendiri (pastikan A record sudah diarahkan ke IP VPS jika pilih manual).

Tunggu sampai proses selesai, lalu ketik `menu` untuk membuka panel.

---

## 🔌 Daftar Port

| Layanan | Port |
|---|---|
| Xray (VLESS TLS + fallback) | 443 |
| Xray (VLESS non-TLS + fallback) | 80 |
| SSH WS (TLS via stunnel) | 8443 |
| SSH WS (alternatif) | 8080, 2082, 2083, 8880 |
| OpenSSH langsung | 22, 444 |
| Dropbear langsung | 90 |
| UDPGW (BadVPN) | 7100, 7200, 7300 |
| ZIVPN (UDP) | 5667 |

---

## 🖥️ Panel Menu

Ketik `menu` di terminal VPS untuk membuka dashboard:

- Info sistem (OS, RAM, uptime, pemakaian bandwidth harian/bulanan)
- Status service (Xray / SSH-WS / ZIVPN)
- Manajemen akun per protokol (create, delete, renew, cek user)
- Setup bot Telegram (notifikasi login, notifikasi backup)
- Reboot terjadwal, rebuild config, cek layanan

---

## 🤖 Setup Notifikasi Telegram

1. Buat bot baru lewat [@BotFather](https://t.me/BotFather), simpan **Bot Token**-nya.
2. Dapatkan **Chat ID** kamu (bisa lewat bot seperti [@userinfobot](https://t.me/userinfobot)).
3. Masuk ke `menu` → pilih menu Bot Telegram → masukkan Token & Chat ID.

---

## ⚠️ Catatan Keamanan

- Ganti kredensial API (Cloudflare, dsb.) di dalam script dengan milikmu sendiri sebelum dipakai untuk produksi/reseller — **jangan gunakan token/API key bawaan contoh**.
- `PermitRootLogin` diaktifkan agar customer bisa login root; script sudah menyertakan **fail2ban** untuk mitigasi brute-force, tapi tetap disarankan memasang monitoring tambahan untuk VPS produksi.
- Selalu rotate token Telegram/API key jika script pernah dibagikan/bocor ke pihak lain.

---

## 📞 Kontak & Dukungan

- **Telegram**: [@tendo_32](https://t.me/tendo_32)
- **WhatsApp**: +62 822-2446-0678

---

## 📄 Lisensi

Script ini dibuat dan didistribusikan oleh **Tendo Store**. Penggunaan ulang/redistribusi untuk komersial harap menghubungi kontak di atas.
