#!/bin/bash
# ==================================================
#   Auto Script Install X-ray & Zivpn + SSH WS
#   EDITION: PLATINUM CLEAN V.6.0 (ULTIMATE FINAL + BOT CLIENT)
#   Script BY: Tendo Store | WhatsApp: +6282224460678
#   Updated: Anti-Ghost Vless, Split Chat Telegram, SSH Multi-Thread, No Force Close, Auto-Restart Fix
# ==================================================

# --- WARNA & UI ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; NC='\033[0m'; WHITE='\033[1;37m'

# --- ANTI INTERACTIVE GLOBALS ---
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
export NEEDRESTART_MODE=a
export NEEDRESTART_SUSPEND=1

# --- ANIMASI INSTALL (BOUNCING SCANNER) ---
function install_spin() {
    local pid=$!
    local delay=0.08
    local frames=(
        "[\e[1;32m=\e[1;36m       ]"
        "[\e[1;32m==\e[1;36m      ]"
        "[\e[1;32m===\e[1;36m     ]"
        "[ \e[1;32m===\e[1;36m    ]"
        "[  \e[1;32m===\e[1;36m   ]"
        "[   \e[1;32m===\e[1;36m  ]"
        "[    \e[1;32m===\e[1;36m ]"
        "[     \e[1;32m===\e[1;36m]"
        "[      \e[1;32m==\e[1;36m]"
        "[       \e[1;32m=\e[1;36m]"
        "[      \e[1;32m==\e[1;36m]"
        "[     \e[1;32m===\e[1;36m]"
        "[    \e[1;32m===\e[1;36m ]"
        "[   \e[1;32m===\e[1;36m  ]"
        "[  \e[1;32m===\e[1;36m   ]"
        "[ \e[1;32m===\e[1;36m    ]"
        "[\e[1;32m===\e[1;36m     ]"
        "[\e[1;32m==\e[1;36m      ]"
    )
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        for frame in "${frames[@]}"; do
            printf "\r\e[1;36m %b\e[0m \e[1;33mSedang memproses, mohon tunggu...\e[0m" "$frame"
            sleep $delay
        done
    done
    printf "\r\e[K"
}

function print_msg() { 
    echo -e "${CYAN}─────────────────────────────────────────────────${NC}"
    echo -e "${YELLOW}➤ $1...${NC}"
}
function print_ok() { 
    echo -e "${GREEN}✔ $1 Berhasil!${NC}"
    sleep 0.5
}

# --- 1. PROMPT DOMAIN DI AWAL ---
clear
echo -e "${CYAN}=================================================${NC}"
echo -e "${PURPLE}      AUTO INSTALLER X-RAY, ZIVPN & SSH WS       ${NC}"
echo -e "${CYAN}=================================================${NC}"
echo -e "${YELLOW}           Script by Tendo Store                 ${NC}"
echo -e "${CYAN}=================================================${NC}"
echo -e "${YELLOW}           PILIHAN JENIS DOMAIN                  ${NC}"
echo -e "${CYAN}=================================================${NC}"
echo -e "${CYAN}│${NC} [1] Gunakan Domain Random Tendo (Gratis/Auto)"
echo -e "${CYAN}│${NC} [2] Gunakan Domain Sendiri (Manual)"
echo -e "${CYAN}─────────────────────────────────────────────────${NC}"
read -p " Pilih Opsi (1/2): " dom_opt

if [[ "$dom_opt" == "1" ]]; then
    echo -e "${YELLOW}Mode Domain Auto terpilih. Domain akan di-generate otomatis.${NC}"
else
    echo -e "${YELLOW}Mode Domain Sendiri${NC}"
    echo -e "${RED}PENTING: Pastikan anda sudah mengarahkan A Record domain ke IP VPS anda!${NC}"
    read -p " Masukan Domain/Subdomain Anda: " user_dom
    if [[ -z "$user_dom" ]]; then
        echo -e "${RED}Domain tidak boleh kosong! Script berhenti.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Domain diatur ke: $user_dom${NC}"
fi
echo -e "${CYAN}=================================================${NC}"
echo -e "${GREEN}Konfigurasi diterima. Memulai proses instalasi...${NC}"
sleep 2
clear

# --- 2. VARIABLES ---
# PENTING: Gunakan Cloudflare API TOKEN (scoped, permission "Zone:DNS:Edit" HANYA
# untuk zone vip3-tendo.my.id), BUKAN Global API Key. Global API Key yang lama
# sudah pernah terekspos -> WAJIB di-revoke/rotate di dashboard Cloudflare
# (My Profile > API Tokens), lalu isi token scoped baru di bawah ini. Token
# scoped tidak bisa mengontrol zone/domain lain di akun Cloudflare kamu, jadi
# kalaupun script ini disebar ke customer, dampak kebocorannya jauh lebih kecil.
CF_TOKEN="ISI_CLOUDFLARE_API_TOKEN_SCOPED_DISINI"
CF_ZONE_ID="14f2e85e62d1d73bf0ce1579f1c3300c"
XRAY_DIR="/usr/local/etc/xray"
CONFIG_FILE="/usr/local/etc/xray/config.json"
DATA_SSH="/usr/local/etc/xray/ssh.txt"
DATA_VMESS="/usr/local/etc/xray/vmess.txt"; DATA_VLESS="/usr/local/etc/xray/vless.txt"; DATA_TROJAN="/usr/local/etc/xray/trojan.txt"
DATA_ZIVPN="/etc/zivpn/zivpn.txt"

# --- 3. OPTIMIZATION ---
print_msg "Optimasi Sistem & Swap"
(
    export DEBIAN_FRONTEND=noninteractive
    rm -f /var/lib/apt/lists/lock
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
    swapoff -a; rm -f /swapfile
    dd if=/dev/zero of=/swapfile bs=1024 count=2097152
    chmod 600 /swapfile; mkswap /swapfile; swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
) >/dev/null 2>&1 & install_spin
print_ok "Optimasi Sistem"

# --- 4. DEPENDENCIES ---
print_msg "Install Dependencies"
(
    export DEBIAN_FRONTEND=noninteractive
    export NEEDRESTART_MODE=a
    mkdir -p /etc/needrestart/conf.d
    echo "\$nrconf{restart} = 'a';" > /etc/needrestart/conf.d/restart.conf
    echo "\$nrconf{kernelhints} = 0;" >> /etc/needrestart/conf.d/restart.conf
    sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf 2>/dev/null

    apt-get update -y -q
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
    apt-get install -y -q -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" curl socat jq openssl uuid-runtime net-tools vnstat wget gnupg1 bc iproute2 iptables iptables-persistent python3 python3-pip neofetch cron zip unzip stunnel4 bzip2 zlib1g-dev build-essential gcc make cmake fail2ban
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
    apt-get install -y -q speedtest
    
    touch /root/.hushlogin; chmod -x /etc/update-motd.d/* 2>/dev/null
    sed -i '/neofetch/d' /root/.bashrc
    sed -i '/Welcome To Tendo/d' /root/.bashrc
    sed -i '/clear/d' /root/.bashrc
    echo "clear" >> /root/.bashrc
    echo "neofetch" >> /root/.bashrc
    echo 'echo -e "Welcome To Tendo Store Auto Script! Type \e[1;32mmenu\e[0m to start."' >> /root/.bashrc
) >/dev/null 2>&1 & install_spin
print_ok "Dependencies"

IP_VPS=$(curl -s ifconfig.me)
IFACE_NET=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)

# --- 5. DOMAIN SELECTION EXECUTION & SSL ---
print_msg "Setup Domain & SSL Cert"
(
    systemctl enable vnstat && systemctl restart vnstat; vnstat -u -i $IFACE_NET
    mkdir -p $XRAY_DIR /etc/zivpn /root/tendo /etc/tendo_bot /usr/local/etc/xray/quota; touch $DATA_SSH $DATA_VMESS $DATA_VLESS $DATA_TROJAN $DATA_ZIVPN
    mkdir -p /var/log/xray; touch /var/log/xray/access.log /var/log/xray/error.log
    # Xray berjalan sebagai user 'nobody' (default installer resmi XTLS).
    # Pastikan dia bisa MENULIS ke log file ini, kalau tidak Xray gagal start
    # dengan error "failed to initialize access logger: permission denied".
    chown nobody:nogroup /var/log/xray/access.log /var/log/xray/error.log 2>/dev/null
    chmod 644 /var/log/xray/access.log /var/log/xray/error.log

    curl -s ipinfo.io/json | jq -r '.city' > /root/tendo/city
    curl -s ipinfo.io/json | jq -r '.org' > /root/tendo/isp
    curl -s ipinfo.io/json | jq -r '.ip' > /root/tendo/ip

    if [[ "$dom_opt" == "1" ]]; then
        DOMAIN_VAL="vpn-$(tr -dc a-z0-9 </dev/urandom | head -c 5).vip3-tendo.my.id"
        curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records" \
             -H "Authorization: Bearer ${CF_TOKEN}" \
             -H "Content-Type: application/json" \
             --data '{"type":"A","name":"'${DOMAIN_VAL}'","content":"'${IP_VPS}'","ttl":120,"proxied":false}' > /dev/null
    else
        DOMAIN_VAL="$user_dom"
    fi
    echo "$DOMAIN_VAL" > $XRAY_DIR/domain

    openssl req -x509 -newkey rsa:2048 -nodes -sha256 -keyout $XRAY_DIR/xray.key \
        -out $XRAY_DIR/xray.crt -days 3650 -subj "/CN=$DOMAIN_VAL"
    chmod 644 $XRAY_DIR/xray.key; chmod 644 $XRAY_DIR/xray.crt
) >/dev/null 2>&1 & install_spin
print_ok "Domain & SSL"

# --- 6. SSH, DROPBEAR, UDPGW & WS PROXY ---
print_msg "Install SSH, Dropbear 2019, WS Proxy & UDPGW"
(
    export DEBIAN_FRONTEND=noninteractive
    
    # BANNER SSH PENDEK DAN PRESISI
    cat > /etc/issue.net << 'EOF'
<font color="#00FFFF">──────────────────────────────</font><br>
<font color="#00FF00"><b> AUTO SCRIPT TENDO STORE</b></font><br>
<font color="#00FFFF">──────────────────────────────</font><br>
<font color="#FFD700">Version :</font> <font color="#FFFFFF">v01.03.26</font><br>
<font color="#FFD700">Owner   :</font> <font color="#FFFFFF">Tendo Store</font><br>
<font color="#FFD700">Telegram:</font> <font color="#FFFFFF">@tendo_32</font><br>
<font color="#00FFFF">──────────────────────────────</font><br>
<font color="#FF0000"><b> No Spam, DDOS, Hacking!</b></font><br>
EOF

    # OpenSSH Config
    sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
    sed -i '/Port 22/a Port 444' /etc/ssh/sshd_config
    # Root TIDAK boleh login pakai password dari internet.
    # Akun jualan (customer) tetap pakai password seperti biasa lewat user biasa (bukan root).
    sed -i '/^PermitRootLogin/d' /etc/ssh/sshd_config
    echo "PermitRootLogin prohibit-password" >> /etc/ssh/sshd_config
    echo "MaxAuthTries 4" >> /etc/ssh/sshd_config
    echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
    systemctl restart ssh >/dev/null 2>&1 || systemctl restart sshd >/dev/null 2>&1

    # Fail2ban: cover sshd DAN dropbear (port 90), karena dropbear juga menerima
    # login password dari akun customer dan sebelumnya tidak dipantau sama sekali.
    cat > /etc/fail2ban/jail.local <<'F2BEOF'
[sshd]
enabled = true
port = 22,444
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
findtime = 600
bantime = 3600

[dropbear]
enabled = true
port = 90
filter = dropbear
logpath = /var/log/auth.log
maxretry = 5
findtime = 600
bantime = 3600
F2BEOF
    systemctl enable fail2ban >/dev/null 2>&1 && systemctl restart fail2ban >/dev/null 2>&1

    # Dropbear 2019 Build
    wget -q https://matt.ucc.asn.au/dropbear/releases/dropbear-2019.78.tar.bz2
    if [[ ! -s dropbear-2019.78.tar.bz2 ]] || ! tar -tf dropbear-2019.78.tar.bz2 >/dev/null 2>&1; then
        echo "GAGAL: download dropbear-2019.78.tar.bz2 rusak/kosong, skip build dropbear." >&2
    else
        tar -xf dropbear-2019.78.tar.bz2 >/dev/null 2>&1
        if cd dropbear-2019.78; then
            ./configure >/dev/null 2>&1
            make >/dev/null 2>&1
            make install >/dev/null 2>&1
            cd ..
        else
            echo "GAGAL: cd ke dropbear-2019.78 gagal, skip build." >&2
        fi
    fi
    rm -rf dropbear-2019.78*

    # Generate Dropbear Host Keys
    mkdir -p /etc/dropbear
    dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key >/dev/null 2>&1
    dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key >/dev/null 2>&1

    # Dropbear Service with Banner
    cat > /etc/systemd/system/dropbear.service <<EOF
[Unit]
Description=Dropbear SSH Daemon
After=network.target

[Service]
ExecStart=/usr/local/sbin/dropbear -F -p 90 -W 65536 -b /etc/issue.net -w
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload && systemctl enable dropbear >/dev/null 2>&1 && systemctl start dropbear >/dev/null 2>&1

    # WS Python Proxy -> Dropbear 2019 (port 90), buffer 8192, TCP_NODELAY
    cat > /usr/local/bin/ws-proxy.py << 'EOF'
import socket, select, threading, time, collections

DROPBEAR_HOST = '127.0.0.1'
DROPBEAR_PORT = 90
BUF_SIZE = 8192
HANDSHAKE_TIMEOUT = 10
LOG_FILE = '/var/log/ws-proxy.log'

# Rate-limit sederhana per IP asli. Dropbear cuma lihat 127.0.0.1 (semua
# koneksi lewat proxy ini), jadi brute-force protection HARUS dilakukan di
# sini, bukan lewat fail2ban yang baca log dropbear.
RATE_WINDOW = 60       # detik
RATE_MAX_CONN = 8      # maksimal koneksi baru per IP per window sebelum dianggap brute-force

_lock = threading.Lock()
_conn_history = collections.defaultdict(list)

def log(msg):
    try:
        with open(LOG_FILE, 'a') as f:
            f.write(msg + "\n")
    except Exception:
        pass

def check_rate(ip):
    """True kalau IP masih wajar, False kalau kelewat sering connect (indikasi brute-force)."""
    now = time.time()
    with _lock:
        hist = _conn_history[ip]
        hist[:] = [t for t in hist if now - t < RATE_WINDOW]
        hist.append(now)
        return len(hist) <= RATE_MAX_CONN

def recv_headers(sock):
    """Baca sampai header HTTP lengkap (\\r\\n\\r\\n) atau timeout, tanpa nunggu 1 recv besar saja."""
    data = b""
    sock.settimeout(HANDSHAKE_TIMEOUT)
    while b"\r\n\r\n" not in data:
        chunk = sock.recv(BUF_SIZE)
        if not chunk:
            break
        data += chunk
        if len(data) > 65536:  # guard biar ga infinite-buffer kalau ada yg iseng
            break
    return data

def extract_real_ip(client_socket, peek_data):
    """Kalau Xray mengirim PROXY protocol v1 (xver=1, jalur fallback :443/:80),
    ambil IP asli dari situ. Kalau tidak ada (jalur langsung iptables REDIRECT
    atau stunnel), IP socket TCP memang sudah IP asli."""
    fallback_ip = "unknown"
    try:
        fallback_ip = client_socket.getpeername()[0]
    except Exception:
        pass
    if peek_data.startswith(b"PROXY "):
        try:
            line, rest = peek_data.split(b"\r\n", 1)
            parts = line.decode(errors="ignore").split()
            real_ip = parts[2] if len(parts) >= 3 else fallback_ip
            return real_ip, rest
        except Exception:
            return fallback_ip, peek_data
    return fallback_ip, peek_data

def handle_client(client_socket):
    remote_socket = None
    try:
        client_socket.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)

        request = recv_headers(client_socket)
        real_ip, request = extract_real_ip(client_socket, request)

        if not check_rate(real_ip):
            log("ws-proxy: repeated connections from %s - possible brute force" % real_ip)
            return

        remote_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        remote_socket.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        remote_socket.settimeout(HANDSHAKE_TIMEOUT)
        remote_socket.connect((DROPBEAR_HOST, DROPBEAR_PORT))

        if b"HTTP/" in request:
            client_socket.sendall(b"HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n")
            parts = request.split(b"\r\n\r\n", 1)
            if len(parts) == 2 and len(parts[1]) > 0:
                remote_socket.sendall(parts[1])
        elif request:
            remote_socket.sendall(request)
        else:
            return

        # Lepas timeout setelah handshake selesai, biar sesi SSH panjang ga ke-cut
        client_socket.settimeout(None)
        remote_socket.settimeout(None)

        sockets = [client_socket, remote_socket]
        while True:
            r, _, _ = select.select(sockets, [], [])
            if not r:
                break
            if client_socket in r:
                data = client_socket.recv(BUF_SIZE)
                if not data: break
                remote_socket.sendall(data)
            if remote_socket in r:
                data = remote_socket.recv(BUF_SIZE)
                if not data: break
                client_socket.sendall(data)
    except Exception:
        pass
    finally:
        if remote_socket:
            try: remote_socket.close()
            except: pass
        try: client_socket.close()
        except: pass

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind(('0.0.0.0', 10015))
server.listen(100)
while True:
    try:
        client, addr = server.accept()
        t = threading.Thread(target=handle_client, args=(client,))
        t.daemon = True
        t.start()
    except Exception:
        pass
EOF
    # Log file untuk ws-proxy + logrotate biar ga membengkak
    touch /var/log/ws-proxy.log
    cat > /etc/logrotate.d/ws-proxy <<'EOF'
/var/log/ws-proxy.log {
    weekly
    rotate 4
    compress
    missingok
    notifempty
}
EOF
    # Filter fail2ban khusus untuk log rate-limit ws-proxy (IP asli, bukan 127.0.0.1)
    cat > /etc/fail2ban/filter.d/wsproxy.conf <<'EOF'
[Definition]
failregex = ^ws-proxy: repeated connections from <HOST> - possible brute force$
ignoreregex =
EOF
    cat >> /etc/fail2ban/jail.local <<'F2BEOF'

[wsproxy]
enabled = true
port = 8080,2082,2083,8880,8443,10015
filter = wsproxy
logpath = /var/log/ws-proxy.log
maxretry = 2
findtime = 120
bantime = 3600
F2BEOF
    systemctl restart fail2ban >/dev/null 2>&1
    cat > /etc/systemd/system/ws-proxy.service <<EOF
[Unit]
Description=SSH WebSocket Proxy
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/ws-proxy.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    systemctl enable ws-proxy >/dev/null 2>&1 && systemctl start ws-proxy >/dev/null 2>&1

    # Stunnel for 8443
    sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
    cat > /etc/stunnel/stunnel.conf <<EOF
pid = /var/run/stunnel4.pid
cert = /usr/local/etc/xray/xray.crt
key = /usr/local/etc/xray/xray.key
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear_tls]
accept = 8443
connect = 127.0.0.1:10015
EOF
    systemctl restart stunnel4 >/dev/null 2>&1

    # UDPGW (Badvpn)
    wget -qO /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/prem/main/badvpn-udpgw64"
    if [[ ! -s /usr/bin/badvpn-udpgw ]]; then
        echo "GAGAL: download badvpn-udpgw kosong/rusak, service badvpn tidak akan start dengan benar." >&2
    fi
    chmod +x /usr/bin/badvpn-udpgw
    for port in 7100 7200 7300; do
    cat > /etc/systemd/system/badvpn-${port}.service <<EOF
[Unit]
Description=BadVPN UDPGW Port ${port}
After=network.target

[Service]
ExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:${port} --max-clients 500
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    systemctl enable badvpn-${port} >/dev/null 2>&1 && systemctl start badvpn-${port} >/dev/null 2>&1
    done

    # IPTables redirect for WS
    iptables -t nat -A PREROUTING -p tcp --dport 8080 -j REDIRECT --to-ports 10015
    iptables -t nat -A PREROUTING -p tcp -m multiport --dports 2082,2083,8880 -j REDIRECT --to-ports 10015
    netfilter-persistent save >/dev/null 2>&1
) >/dev/null 2>&1 & install_spin
print_ok "SSH, Dropbear & UDPGW"

# --- 7. XRAY CONFIG ---
print_msg "Install Xray Core & Config"
(
    export DEBIAN_FRONTEND=noninteractive
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
    UUID_SYS=$(uuidgen)

cat > $CONFIG_FILE <<EOF
{
  "log": { "access": "/var/log/xray/access.log", "error": "/var/log/xray/error.log", "loglevel": "info" },
  "api": { "tag": "api_out", "services": [ "StatsService" ] },
  "stats": {},
  "policy": { "levels": { "0": { "statsUserUplink": true, "statsUserDownlink": true } }, "system": { "statsInboundUplink": true, "statsInboundDownlink": true } },
  "inbounds": [
    { "listen": "127.0.0.1", "port": 10085, "protocol": "dokodemo-door", "settings": { "address": "127.0.0.1" }, "tag": "api_in" },
    { "tag": "inbound-443", "port": 443, "protocol": "vless", "settings": { "clients": [ { "id": "$UUID_SYS", "flow": "xtls-rprx-vision", "level": 0, "email": "system" } ], "decryption": "none", "fallbacks": [ 
        { "path": "/vmess", "dest": 10001, "xver": 1 }, { "path": "/vless", "dest": 10002, "xver": 1 }, { "path": "/trojan", "dest": 10003, "xver": 1 },
        { "path": "/vmess-upg", "dest": 10004, "xver": 1 }, { "path": "/vless-upg", "dest": 10005, "xver": 1 }, { "path": "/trojan-upg", "dest": 10006, "xver": 1 },
        { "alpn": "h2", "path": "/vmess-grpc", "dest": 10007, "xver": 1 }, { "alpn": "h2", "path": "/vless-grpc", "dest": 10008, "xver": 1 }, { "alpn": "h2", "path": "/trojan-grpc", "dest": 10009, "xver": 1 },
        { "dest": 10015, "xver": 1 }
    ] }, "streamSettings": { "network": "tcp", "security": "tls", "tlsSettings": { "alpn": ["h2", "http/1.1"], "certificates": [ { "certificateFile": "/usr/local/etc/xray/xray.crt", "keyFile": "/usr/local/etc/xray/xray.key" } ] } } },
    { "tag": "inbound-80", "port": 80, "protocol": "vless", "settings": { "clients": [], "decryption": "none", "fallbacks": [ 
        { "path": "/vmess", "dest": 10001, "xver": 1 }, { "path": "/vless", "dest": 10002, "xver": 1 }, { "path": "/trojan", "dest": 10003, "xver": 1 },
        { "path": "/vmess-upg", "dest": 10004, "xver": 1 }, { "path": "/vless-upg", "dest": 10005, "xver": 1 }, { "path": "/trojan-upg", "dest": 10006, "xver": 1 },
        { "dest": 10015, "xver": 1 }
    ] }, "streamSettings": { "network": "tcp", "security": "none" } },
    { "tag": "vmess_ws", "port": 10001, "listen": "127.0.0.1", "protocol": "vmess", "settings": { "clients": [] }, "streamSettings": { "network": "ws", "security": "none", "wsSettings": { "acceptProxyProtocol": true, "path": "/vmess" } } },
    { "tag": "vless_ws", "port": 10002, "listen": "127.0.0.1", "protocol": "vless", "settings": { "clients": [], "decryption": "none" }, "streamSettings": { "network": "ws", "security": "none", "wsSettings": { "acceptProxyProtocol": true, "path": "/vless" } } },
    { "tag": "trojan_ws", "port": 10003, "listen": "127.0.0.1", "protocol": "trojan", "settings": { "clients": [] }, "streamSettings": { "network": "ws", "security": "none", "wsSettings": { "acceptProxyProtocol": true, "path": "/trojan" } } },
    { "tag": "vmess_upg", "port": 10004, "listen": "127.0.0.1", "protocol": "vmess", "settings": { "clients": [] }, "streamSettings": { "network": "httpupgrade", "security": "none", "httpupgradeSettings": { "acceptProxyProtocol": true, "path": "/vmess-upg" } } },
    { "tag": "vless_upg", "port": 10005, "listen": "127.0.0.1", "protocol": "vless", "settings": { "clients": [], "decryption": "none" }, "streamSettings": { "network": "httpupgrade", "security": "none", "httpupgradeSettings": { "acceptProxyProtocol": true, "path": "/vless-upg" } } },
    { "tag": "trojan_upg", "port": 10006, "listen": "127.0.0.1", "protocol": "trojan", "settings": { "clients": [] }, "streamSettings": { "network": "httpupgrade", "security": "none", "httpupgradeSettings": { "acceptProxyProtocol": true, "path": "/trojan-upg" } } },
    { "tag": "vmess_grpc", "port": 10007, "listen": "127.0.0.1", "protocol": "vmess", "settings": { "clients": [] }, "streamSettings": { "network": "grpc", "security": "none", "grpcSettings": { "acceptProxyProtocol": true, "serviceName": "vmess-grpc" } } },
    { "tag": "vless_grpc", "port": 10008, "listen": "127.0.0.1", "protocol": "vless", "settings": { "clients": [], "decryption": "none" }, "streamSettings": { "network": "grpc", "security": "none", "grpcSettings": { "acceptProxyProtocol": true, "serviceName": "vless-grpc" } } },
    { "tag": "trojan_grpc", "port": 10009, "listen": "127.0.0.1", "protocol": "trojan", "settings": { "clients": [] }, "streamSettings": { "network": "grpc", "security": "none", "grpcSettings": { "acceptProxyProtocol": true, "serviceName": "trojan-grpc" } } }
  ],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct" },
    { "protocol": "blackhole", "tag": "blocked" }
  ],
  "routing": { "domainStrategy": "IPIfNonMatch", "rules": [ { "inboundTag": ["api_in"], "outboundTag": "api_out", "type": "field" }, { "type": "field", "outboundTag": "blocked", "protocol": [ "bittorrent" ] } ] }
}
EOF
) >/dev/null 2>&1 & install_spin
print_ok "Xray Configured"

# --- 8. ZIVPN ---
print_msg "Install ZIVPN"
(
    wget -qO /usr/local/bin/zivpn "https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64"
    if [[ ! -s /usr/local/bin/zivpn ]]; then
        echo "GAGAL: download zivpn binary kosong/rusak, service zivpn tidak akan start." >&2
    fi
    chmod +x /usr/local/bin/zivpn
    echo '{"listen":":5667","cert":"/usr/local/etc/xray/xray.crt","key":"/usr/local/etc/xray/xray.key","obfs":"zivpn","auth":{"mode":"passwords","config":[]}}' > /etc/zivpn/config.json
cat > /etc/systemd/system/zivpn.service <<EOF
[Unit]
Description=ZIVPN
After=network.target
[Service]
ExecStart=/usr/local/bin/zivpn server -c /etc/zivpn/config.json
Restart=always
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload && systemctl enable zivpn && systemctl restart zivpn xray
    iptables -t nat -A PREROUTING -i $IFACE_NET -p udp --dport 6000:19999 -j DNAT --to-destination :5667
    iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5667
    netfilter-persistent save
) >/dev/null 2>&1 & install_spin
print_ok "ZIVPN Installed"

# --- 9. AUTO-KILL, QUOTA & TELEGRAM SCRIPTS ---
print_msg "Setting up Cron & Telegram Bots"
(
mkdir -p /usr/local/etc/xray/quota

# Script Expiry Auto-Kill
cat > /usr/local/bin/xray-exp <<'EOF'
#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
# Cegah race condition: xray-exp, xray-limit, xray-quota semua jalan tiap
# menit lewat cron dan sama-sama menulis config.json. Tanpa lock ini,
# perubahan salah satu bisa tertimpa/hilang oleh yang lain.
[ "$XRAY_CFG_LOCKED" != "1" ] && exec env XRAY_CFG_LOCKED=1 flock /var/lock/xray-config.lock "$0" "$@"
CONFIG="/usr/local/etc/xray/config.json"
NOW=$(date +%s)
for proto in vmess vless trojan; do
    FILE="/usr/local/etc/xray/${proto}.txt"
    if [[ -f "$FILE" ]]; then
        while IFS="|" read -r user id exp limit status quota; do
            user=$(echo "$user" | tr -d '[:space:]')
            [[ -z "$user" ]] && continue
            EXP_S=$(date -d "$exp" +%s 2>/dev/null)
            if [[ -n "$EXP_S" && "$NOW" -ge "$EXP_S" ]]; then
_tf1=$(mktemp) &&                 jq --arg u "$user" '(.inbounds[] | select(.protocol == "'$proto'")).settings.clients |= map(select(.email != $u))' $CONFIG > "$_tf1" && mv "$_tf1" $CONFIG; chmod 644 $CONFIG
                sed -i "/^$user|/d" $FILE
                rm -f "/usr/local/etc/xray/quota/$user"
                systemctl restart xray
            fi
        done < "$FILE"
    fi
done

# SSH Expiry
S_FILE="/usr/local/etc/xray/ssh.txt"
if [[ -f "$S_FILE" ]]; then
    while IFS="|" read -r user pass exp limit status; do
        user=$(echo "$user" | tr -d '[:space:]')
        [[ -z "$user" ]] && continue
        EXP_S=$(date -d "$exp" +%s 2>/dev/null)
        if [[ -n "$EXP_S" && "$NOW" -ge "$EXP_S" ]]; then
            userdel -f "$user" 2>/dev/null
            sed -i "/^$user|/d" "$S_FILE"
        fi
    done < "$S_FILE"
fi

# ZIVPN Expiry
Z_FILE="/etc/zivpn/zivpn.txt"
Z_CONF="/etc/zivpn/config.json"
if [[ -f "$Z_FILE" ]]; then
    while IFS="|" read -r f1 f2 f3; do
        if [[ -z "$f3" ]]; then u="unknown"; p="$f1"; exp="$f2"; else u="$f1"; p="$f2"; exp="$f3"; fi
        EXP_S=$(date -d "$exp" +%s 2>/dev/null)
        if [[ -n "$EXP_S" && "$NOW" -ge "$EXP_S" ]]; then
            _tfz=$(mktemp) && jq --arg pwd "$p" 'del(.auth.config[] | select(. == $pwd))' $Z_CONF > "$_tfz" && mv "$_tfz" $Z_CONF
            if [[ "$u" == "unknown" ]]; then sed -i "/^$p|/d" $Z_FILE; else sed -i "/^$u|/d" $Z_FILE; fi
            systemctl restart zivpn
        fi
    done < "$Z_FILE"
fi
EOF
chmod +x /usr/local/bin/xray-exp

# Script Limit IP (Toleransi 30 Detik + Anti-Ghost IP Xray + Multi-Thread SSH)
cat > /usr/local/bin/xray-limit <<'EOF'
#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
[ "$XRAY_CFG_LOCKED" != "1" ] && exec env XRAY_CFG_LOCKED=1 flock /var/lock/xray-config.lock "$0" "$@"
CONFIG="/usr/local/etc/xray/config.json"
LOG_FILE="/var/log/xray/access.log"
TOKEN=$(cat /etc/tendo_bot/bot_token 2>/dev/null | tr -d '\r\n ')
CHATID=$(cat /etc/tendo_bot/chat_id 2>/dev/null | tr -d '\r\n ')
NOW=$(date +%s)

IP_VPS=$(cat /root/tendo/ip 2>/dev/null)
DOM_VPS=$(cat /usr/local/etc/xray/domain 2>/dev/null)
ISP_VPS=$(cat /root/tendo/isp 2>/dev/null)

[[ ! -f "$LOG_FILE" ]] && exit 0

STRS=$(for i in {0..30}; do date -d "$i seconds ago" +"%Y/%m/%d %H:%M:%S"; done | paste -sd '|' -)
# FIX Ghost IP: Menghapus 127.0.0.1 dan user kosong "email: system"
tail -n 5000 "$LOG_FILE" | grep -E "^($STRS)" | grep "accepted" | grep "email: " | grep -v "email: system" | grep -v "127.0.0.1" | grep -v "::1" | awk '{
    for(i=1;i<=NF;i++) {
        if($i=="accepted") { ip=$(i-1); sub(/:.*/,"",ip); }
        if($i=="email:") { email=$(i+1); gsub(/[^a-zA-Z0-9_-]/, "", email); }
    }
    if(ip!="" && email!="" && email!="system") {
        split(ip, v, ".");
        if(length(v)==4) { subnet=v[1]"."v[2]; } else { subnet=ip; }
        print subnet, email;
    }
}' | sort -u > /tmp/xray_active.log

for proto in vmess vless trojan; do
    FILE="/usr/local/etc/xray/${proto}.txt"
    [[ ! -f "$FILE" ]] && continue
    while IFS="|" read -r user id exp limit status quota; do
        user=$(echo "$user" | tr -d '[:space:]')
        [[ -z "$user" ]] && continue
        
        if [[ "$status" == LOCKED_IP_* ]]; then
            lock_time=${status#LOCKED_IP_}
            if [[ $((NOW - lock_time)) -ge 600 ]]; then
                if [[ "$proto" == "trojan" ]]; then
_tf2=$(mktemp) &&                     jq --arg p "$id" --arg u "$user" '(.inbounds[] | select(.protocol == "trojan")).settings.clients += [{"password":$p,"email":$u,"level":0}]' $CONFIG > "$_tf2" && mv "$_tf2" $CONFIG; chmod 644 $CONFIG
                else
_tf3=$(mktemp) &&                     jq --arg id "$id" --arg u "$user" '(.inbounds[] | select(.protocol == "'$proto'")).settings.clients += [{"id":$id,"email":$u,"level":0}]' $CONFIG > "$_tf3" && mv "$_tf3" $CONFIG; chmod 644 $CONFIG
                fi
                sed -i "s/^$user|.*/$user|$id|$exp|$limit|ACTIVE|$quota/g" "$FILE"
                systemctl restart xray
                if [[ -n "$TOKEN" && -n "$CHATID" ]]; then
                    MSG="<b>✅ AKUN DI-UNLOCK OTOMATIS (${proto^^})</b>"$'\n'"IP     : ${IP_VPS}"$'\n'"DOMAIN : ${DOM_VPS}"$'\n'"ISP    : ${ISP_VPS}"$'\n\n'"👤 User: <code>$user</code>"$'\n'"🔓 Status: Active (Hukuman 10 menit selesai)"
                    /usr/bin/curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" -d "chat_id=${CHATID}" --data-urlencode "text=${MSG}" -d "parse_mode=HTML" > /dev/null
                fi
            fi
            continue
        elif [[ "$status" == "LOCKED" ]]; then
            continue
        fi
        
        [[ -z "$limit" || "$limit" == "0" ]] && continue
        
        active_ips=$(grep -w "$user" /tmp/xray_active.log | awk '{print $1}' | sort -u | wc -l)
        if [[ "$active_ips" -gt "$limit" ]]; then
_tf4=$(mktemp) &&             jq --arg u "$user" '(.inbounds[] | select(.protocol == "'$proto'")).settings.clients |= map(select(.email != $u))' $CONFIG > "$_tf4" && mv "$_tf4" $CONFIG; chmod 644 $CONFIG
            sed -i "s/^$user|.*/$user|$id|$exp|$limit|LOCKED_IP_${NOW}|$quota/g" "$FILE"
            systemctl restart xray
            if [[ -n "$TOKEN" && -n "$CHATID" ]]; then
                MSG="<b>⚠️ MULTI-LOGIN TERDETEKSI (${proto^^})</b>"$'\n'"IP     : ${IP_VPS}"$'\n'"DOMAIN : ${DOM_VPS}"$'\n'"ISP    : ${ISP_VPS}"$'\n\n'"👤 User: <code>$user</code>"$'\n'"🌐 Limit IP: $limit"$'\n'"🚨 Login Count: $active_ips"$'\n'"⛔ Status: Terkunci 10 Menit"
                /usr/bin/curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" -d "chat_id=${CHATID}" --data-urlencode "text=${MSG}" -d "parse_mode=HTML" > /dev/null
            fi
        fi
    done < "$FILE"
done

# SSH Limit IP Lock (Toleransi Multi-Thread SSH HTTP Custom)
S_FILE="/usr/local/etc/xray/ssh.txt"
if [[ -f "$S_FILE" ]]; then
    while IFS="|" read -r user pass exp limit status; do
        user=$(echo "$user" | tr -d '[:space:]')
        [[ -z "$user" ]] && continue
        if [[ "$status" == LOCKED_IP_* ]]; then
            lock_time=${status#LOCKED_IP_}
            if [[ $((NOW - lock_time)) -ge 600 ]]; then
                usermod -U "$user" 2>/dev/null
                sed -i "s/^$user|.*/$user|$pass|$exp|$limit|ACTIVE/g" "$S_FILE"
                if [[ -n "$TOKEN" && -n "$CHATID" ]]; then
                    MSG="<b>✅ AKUN DI-UNLOCK OTOMATIS (SSH)</b>"$'\n'"IP     : ${IP_VPS}"$'\n'"DOMAIN : ${DOM_VPS}"$'\n'"ISP    : ${ISP_VPS}"$'\n\n'"👤 User: <code>$user</code>"$'\n'"🔓 Status: Active (Hukuman 10 menit selesai)"
                    /usr/bin/curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" -d "chat_id=${CHATID}" --data-urlencode "text=${MSG}" -d "parse_mode=HTML" > /dev/null
                fi
            fi
            continue
        elif [[ "$status" == "LOCKED" ]]; then
            continue
        fi
        
        [[ -z "$limit" || "$limit" == "0" ]] && continue
        
        # FIX: Multi-Thread Apps (Injector) membuka banyak koneksi. Kita kali 3 toleransinya.
        max_sessions=$(( limit * 3 ))
        active_logins=$(ps -u "$user" -o comm= 2>/dev/null | grep -E "^(sshd|dropbear)$" | wc -l)
        if [[ "$active_logins" -gt "$max_sessions" ]]; then
            usermod -L "$user" 2>/dev/null
            killall -u "$user" 2>/dev/null
            sed -i "s/^$user|.*/$user|$pass|$exp|$limit|LOCKED_IP_${NOW}/g" "$S_FILE"
            if [[ -n "$TOKEN" && -n "$CHATID" ]]; then
                MSG="<b>⚠️ MULTI-LOGIN TERDETEKSI (SSH)</b>"$'\n'"IP     : ${IP_VPS}"$'\n'"DOMAIN : ${DOM_VPS}"$'\n'"ISP    : ${ISP_VPS}"$'\n\n'"👤 User: <code>$user</code>"$'\n'"🌐 Limit Session: $max_sessions"$'\n'"🚨 Login Session: $active_logins"$'\n'"⛔ Status: Terkunci 10 Menit"
                /usr/bin/curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" -d "chat_id=${CHATID}" --data-urlencode "text=${MSG}" -d "parse_mode=HTML" > /dev/null
            fi
        fi
    done < "$S_FILE"
fi
EOF
chmod +x /usr/local/bin/xray-limit

# Script Quota 
cat > /usr/local/bin/xray-quota <<'EOF'
#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
[ "$XRAY_CFG_LOCKED" != "1" ] && exec env XRAY_CFG_LOCKED=1 flock /var/lock/xray-config.lock "$0" "$@"
CONFIG="/usr/local/etc/xray/config.json"
TOKEN=$(cat /etc/tendo_bot/bot_token 2>/dev/null | tr -d '\r\n ')
CHATID=$(cat /etc/tendo_bot/chat_id 2>/dev/null | tr -d '\r\n ')

IP_VPS=$(cat /root/tendo/ip 2>/dev/null)
DOM_VPS=$(cat /usr/local/etc/xray/domain 2>/dev/null)
ISP_VPS=$(cat /root/tendo/isp 2>/dev/null)

STATS=$(/usr/local/bin/xray api statsquery -server=127.0.0.1:10085 2>/dev/null)
for proto in vmess vless trojan; do
    FILE="/usr/local/etc/xray/${proto}.txt"
    [[ ! -f "$FILE" ]] && continue
    while IFS="|" read -r user id exp limit status quota; do
        user=$(echo "$user" | tr -d '[:space:]')
        [[ -z "$user" || -z "$quota" || "$quota" == "0" || "$status" == "LOCKED" || "$status" == LOCKED_IP_* ]] && continue
        
        down=$(echo "$STATS" | jq -r ".stat[]? | select(.name == \"user>>>${user}>>>traffic>>>downlink\") | .value" 2>/dev/null)
        up=$(echo "$STATS" | jq -r ".stat[]? | select(.name == \"user>>>${user}>>>traffic>>>uplink\") | .value" 2>/dev/null)
        [[ -z "$down" || "$down" == "null" ]] && down=0
        [[ -z "$up" || "$up" == "null" ]] && up=0
        current_api=$((down + up))
        
        QUOTA_FILE="/usr/local/etc/xray/quota/${user}"
        if [[ -f "$QUOTA_FILE" ]]; then
            read total_acc last_api < "$QUOTA_FILE"
        else
            total_acc=0
            last_api=0
        fi
        
        if (( current_api < last_api )); then
            total_acc=$((total_acc + current_api))
        else
            diff=$((current_api - last_api))
            total_acc=$((total_acc + diff))
        fi
        last_api=$current_api
        echo "$total_acc $last_api" > "$QUOTA_FILE"
        
        quota_bytes=$(awk "BEGIN {printf \"%.0f\", $quota * 1073741824}")
        if (( total_acc >= quota_bytes )); then
_tf5=$(mktemp) &&             jq --arg u "$user" '(.inbounds[] | select(.protocol == "'$proto'")).settings.clients |= map(select(.email != $u))' $CONFIG > "$_tf5" && mv "$_tf5" $CONFIG; chmod 644 $CONFIG
            sed -i "/^$user|/d" "$FILE"
            rm -f "$QUOTA_FILE"
            systemctl restart xray
            if [[ -n "$TOKEN" && -n "$CHATID" ]]; then
                MSG="<b>🚫 KUOTA HABIS (AKUN DIHAPUS - ${proto^^})</b>"$'\n'"IP     : ${IP_VPS}"$'\n'"DOMAIN : ${DOM_VPS}"$'\n'"ISP    : ${ISP_VPS}"$'\n\n'"👤 User: <code>$user</code>"$'\n'"📊 Batas Kuota: ${quota} GB"$'\n'"⛔ Status: Akun Otomatis Dihapus"
                /usr/bin/curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" -d "chat_id=${CHATID}" --data-urlencode "text=${MSG}" -d "parse_mode=HTML" > /dev/null
            fi
        fi
    done < "$FILE"
done
EOF
chmod +x /usr/local/bin/xray-quota

# Script Telegram Login Notif (Split per-protocol, Anti-Ghosting)
cat > /usr/local/bin/bot-login-notif <<'EOF'
#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
TOKEN=$(cat /etc/tendo_bot/bot_token 2>/dev/null | tr -d '\r\n ')
CHATID=$(cat /etc/tendo_bot/chat_id 2>/dev/null | tr -d '\r\n ')
[[ -z "$TOKEN" || -z "$CHATID" ]] && exit 0
LOG_FILE="/var/log/xray/access.log"

IP_VPS=$(cat /root/tendo/ip 2>/dev/null)
DOM_VPS=$(cat /usr/local/etc/xray/domain 2>/dev/null)
ISP_VPS=$(cat /root/tendo/isp 2>/dev/null)

STRS=$(for i in {0..30}; do date -d "$i seconds ago" +"%Y/%m/%d %H:%M:%S"; done | paste -sd '|' -)
tail -n 5000 "$LOG_FILE" | grep -E "^($STRS)" | grep "accepted" | grep "email: " | grep -v "email: system" | grep -v "127.0.0.1" | grep -v "::1" | awk '{
    for(i=1;i<=NF;i++) {
        if($i=="accepted") { ip=$(i-1); sub(/:.*/,"",ip); }
        if($i=="email:") { email=$(i+1); gsub(/[^a-zA-Z0-9_-]/, "", email); }
    }
    if(ip!="" && email!="" && email!="system") {
        split(ip, v, ".");
        if(length(v)==4) { subnet=v[1]"."v[2]; } else { subnet=ip; }
        print subnet, email;
    }
}' | sort -u > /tmp/bot_active.log

STATS=$(/usr/local/bin/xray api statsquery -server=127.0.0.1:10085 2>/dev/null)

for proto in vmess vless trojan; do
    FILE="/usr/local/etc/xray/${proto}.txt"
    [[ ! -f "$FILE" ]] && continue
    
    PROTO_MSG=""
    FOUND=0
    while IFS="|" read -r user id exp limit status quota; do
        user=$(echo "$user" | tr -d '[:space:]')
        [[ -z "$user" ]] && continue
        
        active_ips=$(grep -w "$user" /tmp/bot_active.log | wc -l)
        if [[ "$active_ips" -gt 0 ]]; then
            down=$(echo "$STATS" | jq -r ".stat[]? | select(.name == \"user>>>${user}>>>traffic>>>downlink\") | .value" 2>/dev/null)
            up=$(echo "$STATS" | jq -r ".stat[]? | select(.name == \"user>>>${user}>>>traffic>>>uplink\") | .value" 2>/dev/null)
            [[ -z "$down" || "$down" == "null" ]] && down=0
            [[ -z "$up" || "$up" == "null" ]] && up=0
            current_api=$((down + up))

            QUOTA_FILE="/usr/local/etc/xray/quota/${user}"
            if [[ -f "$QUOTA_FILE" ]]; then
                read total_acc last_api < "$QUOTA_FILE"
                [[ -z "$total_acc" ]] && total_acc=0
                [[ -z "$last_api" ]] && last_api=0
                if (( current_api >= last_api )); then
                    real_usage=$(( total_acc + (current_api - last_api) ))
                else
                    real_usage=$(( total_acc + current_api ))
                fi
            else
                real_usage=$current_api
            fi

            if (( real_usage < 1048576 )); then
                usage_fmt=$(LC_ALL=C awk "BEGIN {printf \"%.2f\", $real_usage/1024}")" KB"
            elif (( real_usage < 1073741824 )); then
                usage_fmt=$(LC_ALL=C awk "BEGIN {printf \"%.2f\", $real_usage/1048576}")" MB"
            else
                usage_fmt=$(LC_ALL=C awk "BEGIN {printf \"%.2f\", $real_usage/1073741824}")" GB"
            fi

            PROTO_MSG+="👤 User: <code>$user</code> | Login: $active_ips IP | Usage: ${usage_fmt}"$'\n'
            FOUND=1
        fi
    done < "$FILE"
    
    if [[ "$FOUND" -eq 1 ]]; then
        MSG="<b>📊 LAPORKAN PENGGUNA AKTIF (${proto^^})</b>"$'\n'"IP     : ${IP_VPS}"$'\n'"DOMAIN : ${DOM_VPS}"$'\n'"ISP    : ${ISP_VPS}"$'\n\n'"${PROTO_MSG}"
        /usr/bin/curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" -d "chat_id=${CHATID}" --data-urlencode "text=${MSG}" -d "parse_mode=HTML" > /dev/null
    fi
done

# Check SSH Active Absolute Tracker
S_FILE="/usr/local/etc/xray/ssh.txt"
if [[ -f "$S_FILE" ]]; then
    PROTO_MSG=""
    FOUND=0
    while IFS="|" read -r user pass exp limit status; do
        user=$(echo "$user" | tr -d '[:space:]')
        [[ -z "$user" ]] && continue
        
        active_logins=$(ps -u "$user" -o comm= 2>/dev/null | grep -E "^(sshd|dropbear)$" | wc -l)
        if [[ "$active_logins" -gt 0 ]]; then
            PROTO_MSG+="👤 User: <code>$user</code> | Login: $active_logins Sesi (Multi-thread)"$'\n'
            FOUND=1
        fi
    done < "$S_FILE"
    
    if [[ "$FOUND" -eq 1 ]]; then
        MSG="<b>📊 LAPORKAN PENGGUNA AKTIF (SSH)</b>"$'\n'"IP     : ${IP_VPS}"$'\n'"DOMAIN : ${DOM_VPS}"$'\n'"ISP    : ${ISP_VPS}"$'\n\n'"${PROTO_MSG}"
        /usr/bin/curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" -d "chat_id=${CHATID}" --data-urlencode "text=${MSG}" -d "parse_mode=HTML" > /dev/null
    fi
fi
EOF
chmod +x /usr/local/bin/bot-login-notif

# Script Telegram Backup Notif
cat > /usr/local/bin/bot-backup <<'EOF'
#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
if ! command -v zip &> /dev/null; then apt-get install -y zip >/dev/null 2>&1; fi
TOKEN=$(cat /etc/tendo_bot/bot_token 2>/dev/null | tr -d '\r\n ')
CHATID=$(cat /etc/tendo_bot/chat_id 2>/dev/null | tr -d '\r\n ')
[[ -z "$TOKEN" || -z "$CHATID" ]] && exit 0
DATE=$(date +"%Y-%m-%d_%H-%M")

IP_VPS=$(cat /root/tendo/ip 2>/dev/null)
DOM_VPS=$(cat /usr/local/etc/xray/domain 2>/dev/null)
ISP_VPS=$(cat /root/tendo/isp 2>/dev/null)

ZIP_FILE="/tmp/Backup_${DATE}.zip"
cd /
zip -r $ZIP_FILE usr/local/etc/xray/ etc/zivpn/ etc/tendo_bot/ etc/issue.net usr/local/bin/tendo-client-bot.py usr/local/bin/client-bot-helper.sh etc/systemd/system/tendo-client-bot.service >/dev/null 2>&1
cd - >/dev/null 2>&1
[[ ! -f "$ZIP_FILE" ]] && exit 0

/usr/bin/curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendDocument" \
    -F "chat_id=${CHATID}" \
    -F "document=@${ZIP_FILE}" \
    -F "caption=📦 AUTOBACKUP VPS"$'\n\n'"IP     : ${IP_VPS}"$'\n'"DOMAIN : ${DOM_VPS}"$'\n'"ISP    : ${ISP_VPS}"$'\n\n'"📅 Date: ${DATE}"$'\n'"✅ Backup Successfully generated." > /dev/null
rm -f $ZIP_FILE
EOF
chmod +x /usr/local/bin/bot-backup

(crontab -l 2>/dev/null | grep -v "xray-exp"; echo "* * * * * /usr/local/bin/xray-exp") | crontab -
(crontab -l 2>/dev/null | grep -v "xray-limit"; echo "* * * * * /usr/local/bin/xray-limit") | crontab -
(crontab -l 2>/dev/null | grep -v "xray-quota"; echo "* * * * * /usr/local/bin/xray-quota") | crontab -
) >/dev/null 2>&1 & install_spin
print_ok "Sistem Auto & Cron Jobs"

# --- 10. MENU SCRIPT ---
print_msg "Finalisasi Menu"
(
cat > /usr/bin/menu <<'END_MENU'
#!/bin/bash
CYAN='\033[0;36m'; YELLOW='\033[0;33m'; GREEN='\033[0;32m'; RED='\033[0;31m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'; WHITE='\033[1;37m'; NC='\033[0m'
CONFIG="/usr/local/etc/xray/config.json"
D_SSH="/usr/local/etc/xray/ssh.txt"
D_VMESS="/usr/local/etc/xray/vmess.txt"
D_VLESS="/usr/local/etc/xray/vless.txt"
D_TROJAN="/usr/local/etc/xray/trojan.txt"
D_ZIVPN="/etc/zivpn/zivpn.txt"

# ---------------------------------------------
# FUNGSI HELPER UI
# ---------------------------------------------
print_line() {
    local text="$1"
    local clean_text=$(echo -e "$text" | sed -r 's/\x1b\[[0-9;]*m//g' | sed -r 's/\x1b\[[0-9;]*K//g')
    local len=${#clean_text}
    local spaces=$(( 54 - len ))
    local pad=""
    if (( spaces > 0 )); then pad=$(printf '%*s' "$spaces" ""); fi
    echo -e "${CYAN}│${NC}${text}${pad}${CYAN}│${NC}"
}

print_line_open() {
    local text="$1"
    echo -e "${CYAN}│${NC}${text}"
}

print_center() {
    local text="$1"
    local clean_text=$(echo -e "$text" | sed -r 's/\x1b\[[0-9;]*m//g' | sed -r 's/\x1b\[[0-9;]*K//g')
    local len=${#clean_text}
    local spaces=$(( 54 - len ))
    local pad_l=$(( spaces / 2 ))
    local pad_r=$(( spaces - pad_l ))
    local str_l=$(printf '%*s' "$pad_l" "")
    local str_r=$(printf '%*s' "$pad_r" "")
    echo -e "${CYAN}│${NC}${str_l}${text}${str_r}${CYAN}│${NC}"
}

function check_exists() {
    local user=$1
    if grep -q "^$user|" $D_SSH $D_VMESS $D_VLESS $D_TROJAN $D_ZIVPN 2>/dev/null; then
        echo -e "${RED}Username '$user' sudah terdaftar! Silakan gunakan username lain.${NC}"
        sleep 2
        return 1
    fi
    if id "$user" &>/dev/null; then
        echo -e "${RED}Username '$user' sudah ada di sistem Linux! Silakan gunakan username lain.${NC}"
        sleep 2
        return 1
    fi
    return 0
}

function check_uuid() {
    local uuid=$1
    if grep -q "|$uuid|" $D_VMESS $D_VLESS $D_TROJAN 2>/dev/null; then
        echo -e "${RED}Password/UUID '$uuid' sudah digunakan! Silakan gunakan yang lain.${NC}"
        sleep 2
        return 1
    fi
    return 0
}

function send_tele() {
    local bot_tok=$(cat /etc/tendo_bot/bot_token 2>/dev/null | tr -d '\r\n ')
    local chat_id=$(cat /etc/tendo_bot/chat_id 2>/dev/null | tr -d '\r\n ')
    [[ -z "$bot_tok" || -z "$chat_id" ]] && return
    
    local msg=$(echo -e "$1")
    local full_msg="<b>✅ NEW ACCOUNT CREATED</b>"$'\n\n'"$msg"
    
    curl -s -X POST "https://api.telegram.org/bot${bot_tok}/sendMessage" \
        -d "chat_id=${chat_id}" \
        --data-urlencode "text=${full_msg}" \
        -d "parse_mode=HTML" > /dev/null &
}

function show_account_ssh() {
    systemctl restart dropbear >/dev/null 2>&1 &
    clear
    local user=$1; local pass=$2; local domain=$3; local exp=$4; local limit=$5
    local isp=$(cat /root/tendo/isp); local city=$(cat /root/tendo/city)
    
    local MSG=""
    MSG+="————————————————————————————————————\n          ACCOUNT SSH / WS\n————————————————————————————————————\n"
    MSG+="Username       : ${user}\nPassword       : ${pass}\nCITY           : ${city}\nISP            : ${isp}\nDomain         : ${domain}\n"
    MSG+="Port TLS       : 443, 8443\nPort none TLS  : 80, 8080\nPort any       : 2082, 2083, 8880\n"
    MSG+="Port OpenSSH   : 22, 444\nPort Dropbear  : 90\nPort UDPGW     : 7100-7600\n"
    MSG+="Limit IP       : ${limit} IP\n"
    MSG+="Payload WS     : GET / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]\n"
    MSG+="Expired On     : ${exp}\n————————————————————————————————————\n"

    local MSG_BOT=""
    MSG_BOT+="<b>————————————————————————————————————</b>\n          <b>ACCOUNT SSH / WS</b>\n<b>————————————————————————————————————</b>\n"
    MSG_BOT+="Username       : <code>${user}</code>\nPassword       : <code>${pass}</code>\nCITY           : ${city}\nISP            : ${isp}\nDomain         : <code>${domain}</code>\n"
    MSG_BOT+="Port TLS       : 443, 8443\nPort none TLS  : 80, 8080\nPort any       : 2082, 2083, 8880\n"
    MSG_BOT+="Port OpenSSH   : 22, 444\nPort Dropbear  : 90\nPort UDPGW     : 7100-7600\n"
    MSG_BOT+="Limit IP       : ${limit} IP\n"
    MSG_BOT+="Payload WS     : <code>GET / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]</code>\n"
    MSG_BOT+="Expired On     : ${exp}\n<b>————————————————————————————————————</b>\n"

    echo -e "$MSG"
    send_tele "$MSG_BOT"
    echo ""
    read -n 1 -s -r -p "Tekan enter untuk kembali..."
}

function show_account_xray() {
    systemctl restart xray >/dev/null 2>&1 &
    clear
    local proto=$1; local user=$2; local domain=$3; local uuid=$4; local exp=$5; local limit=$6; local quota=$7; local usage=$8
    local link_ws_tls=$9; local link_ws_ntls=${10}; local link_grpc_tls=${11}; local link_upg_tls=${12}; local link_upg_ntls=${13}
    local isp=$(cat /root/tendo/isp); local city=$(cat /root/tendo/city)
    [[ "$quota" == "0" ]] && str_quota="Unlimited" || str_quota="${quota} GB"

    local MSG=""
    local MSG_BOT=""
    
    if [[ "$proto" == "VMESS" ]]; then
        MSG+="————————————————————————————————————\n               VMESS\n————————————————————————————————————\n"
        MSG+="Username       : ${user}\nPassword / ID  : ${uuid}\nCITY           : ${city}\nISP            : ${isp}\nDomain         : ${domain}\n"
        MSG+="Port TLS       : 443\nPort none TLS  : 80\nalterId        : 0\n"
        MSG+="Security       : auto\nnetwork        : ws, grpc, upgrade\npath ws        : /vmess\n"
        MSG+="serviceName    : vmess-grpc\npath upgrade   : /vmess-upg\nLimit IP       : ${limit} IP\n"
        MSG+="Quota Bandwidth: ${str_quota}\nUsage Bandwidth: ${usage} GB\nExpired On     : ${exp}\n"
        MSG+="————————————————————————————————————\n           VMESS WS TLS\n————————————————————————————————————\n${link_ws_tls}\n"
        MSG+="————————————————————————————————————\n          VMESS WS NO TLS\n————————————————————————————————————\n${link_ws_ntls}\n"
        MSG+="————————————————————————————————————\n             VMESS GRPC\n————————————————————————————————————\n${link_grpc_tls}\n"
        MSG+="————————————————————————————————————\n         VMESS Upgrade TLS\n————————————————————————————————————\n${link_upg_tls}\n"
        MSG+="————————————————————————————————————\n        VMESS Upgrade NO TLS\n————————————————————————————————————\n${link_upg_ntls}\n————————————————————————————————————\n"
    elif [[ "$proto" == "VLESS" ]]; then
        MSG+="————————————————————————————————————\n               VLESS\n————————————————————————————————————\n"
        MSG+="Username       : ${user}\nPassword / ID  : ${uuid}\nCITY           : ${city}\nISP            : ${isp}\nDomain         : ${domain}\n"
        MSG+="Port TLS       : 443\nPort none TLS  : 80\nEncryption     : none\n"
        MSG+="Network        : ws, grpc, upgrade\nPath ws        : /vless\nserviceName    : vless-grpc\n"
        MSG+="Path upgrade   : /vless-upg\nLimit IP       : ${limit} IP\nQuota Bandwidth: ${str_quota}\n"
        MSG+="Usage Bandwidth: ${usage} GB\nExpired On     : ${exp}\n"
        MSG+="————————————————————————————————————\n            VLESS WS TLS\n————————————————————————————————————\n${link_ws_tls}\n"
        MSG+="————————————————————————————————————\n          VLESS WS NO TLS\n————————————————————————————————————\n${link_ws_ntls}\n"
        MSG+="————————————————————————————————————\n             VLESS GRPC\n————————————————————————————————————\n${link_grpc_tls}\n"
        MSG+="————————————————————————————————————\n          VLESS Upgrade TLS\n————————————————————————————————————\n${link_upg_tls}\n"
        MSG+="————————————————————————————————————\n        VLESS Upgrade NO TLS\n————————————————————————————————————\n${link_upg_ntls}\n————————————————————————————————————\n"
    elif [[ "$proto" == "TROJAN" ]]; then
        MSG+="————————————————————————————————————\n               TROJAN\n————————————————————————————————————\n"
        MSG+="Username     : ${user}\nPassword     : ${uuid}\nCITY         : ${city}\nISP          : ${isp}\nDomain       : ${domain}\n"
        MSG+="Port         : 443\nNetwork      : ws, grpc, upgrade\n"
        MSG+="Path ws      : /trojan\nserviceName  : trojan-grpc\nPath upgrade : /trojan-upg\n"
        MSG+="Limit IP     : ${limit} IP\nQuota Limit  : ${str_quota}\nUsage Traffic: ${usage} GB\nExpired On   : ${exp}\n"
        MSG+="————————————————————————————————————\n           TROJAN WS TLS\n————————————————————————————————————\n${link_ws_tls}\n"
        MSG+="————————————————————————————————————\n            TROJAN GRPC\n————————————————————————————————————\n${link_grpc_tls}\n"
        MSG+="————————————————————————————————————\n         TROJAN Upgrade TLS\n————————————————————————————————————\n${link_upg_tls}\n"
        MSG+="——————————\n——————————————————————————\n"
    fi

    MSG_BOT+="<b>————————————————————————————————————</b>\n               <b>${proto}</b>\n<b>————————————————————————————————————</b>\n"
    MSG_BOT+="Username       : <code>${user}</code>\nCITY           : ${city}\nISP            : ${isp}\nDomain         : <code>${domain}</code>\n"
    MSG_BOT+="Port TLS       : 443\nPort none TLS  : 80\n"
    if [[ "$proto" == "TROJAN" ]]; then MSG_BOT+="Password       : <code>${uuid}</code>\n"; else MSG_BOT+="Password / ID  : <code>${uuid}</code>\n"; fi
    if [[ "$proto" == "VMESS" ]]; then MSG_BOT+="alterId        : 0\nSecurity       : auto\n"; elif [[ "$proto" == "VLESS" ]]; then MSG_BOT+="Encryption     : none\n"; fi
    MSG_BOT+="network        : ws, grpc, upgrade\npath ws        : /${proto,,}\nserviceName    : ${proto,,}-grpc\npath upgrade   : /${proto,,}-upg\n"
    MSG_BOT+="Limit IP       : ${limit} IP\nQuota Bandwidth: ${str_quota}\nUsage Bandwidth: ${usage} GB\nExpired On     : ${exp}\n"
    MSG_BOT+="<b>————————————————————————————————————</b>\n           <b>${proto} WS TLS</b>\n<b>————————————————————————————————————</b>\n"
    MSG_BOT+="<code>${link_ws_tls}</code>\n<b>————————————————————————————————————</b>\n"
    if [[ -n "$link_ws_ntls" ]]; then
        MSG_BOT+="          <b>${proto} WS NO TLS</b>\n<b>————————————————————————————————————</b>\n<code>${link_ws_ntls}</code>\n<b>————————————————————————————————————</b>\n"
    fi
    MSG_BOT+="             <b>${proto} GRPC</b>\n<b>————————————————————————————————————</b>\n<code>${link_grpc_tls}</code>\n<b>————————————————————————————————————</b>\n"
    MSG_BOT+="         <b>${proto} Upgrade TLS</b>\n<b>————————————————————————————————————</b>\n<code>${link_upg_tls}</code>\n<b>————————————————————————————————————</b>\n"
    if [[ -n "$link_upg_ntls" ]]; then
        MSG_BOT+="        <b>${proto} Upgrade NO TLS</b>\n<b>————————————————————————————————————</b>\n<code>${link_upg_ntls}</code>\n<b>————————————————————————————————————</b>\n"
    fi

    echo -e "$MSG"
    send_tele "$MSG_BOT"
    echo ""
    read -n 1 -s -r -p "Tekan enter untuk kembali..."
}

function show_account_zivpn() {
    systemctl restart zivpn >/dev/null 2>&1 &
    clear
    local user=$1; local pass=$2; local domain=$3; local exp=$4
    local isp=$(cat /root/tendo/isp); local city=$(cat /root/tendo/city); local ip=$(cat /root/tendo/ip)

    local MSG=""
    MSG+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n  ACCOUNT ZIVPN UDP\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    MSG+="Password   : ${pass}\nCITY       : ${city}\nISP        : ${isp}\nIP ISP     : ${ip}\nDomain     : ${domain}\nExpired On : ${exp}\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    
    local MSG_BOT=""
    MSG_BOT+="<b>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</b>\n  <b>ACCOUNT ZIVPN UDP</b>\n<b>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</b>\n"
    MSG_BOT+="Password   : <code>${pass}</code>\nCITY       : ${city}\nISP        : ${isp}\nIP ISP     : <code>${ip}</code>\nDomain     : <code>${domain}</code>\nExpired On : ${exp}\n<b>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</b>\n"

    echo -e "$MSG"
    send_tele "$MSG_BOT"
    echo ""
    read -n 1 -s -r -p "Tekan enter untuk kembali..."
}

function header_main() {
    clear; DOMAIN=$(cat /usr/local/etc/xray/domain); OS=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/PRETTY_NAME="//g' | sed 's/"//g')
    RAM=$(free -m | awk '/Mem:/ {print $2}'); SWAP=$(free -m | awk '/Swap:/ {print $2}'); IP=$(cat /root/tendo/ip)
    IFACE=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
    CITY=$(cat /root/tendo/city)
    ISP=$(cat /root/tendo/isp)
    UPTIME=$(uptime -p | sed 's/up //')
    
    MONTH_NAME=$(date +%B)
    DAY_NAME=$(date +%A)
    RX_DAY=$(vnstat -d -i $IFACE --oneline | awk -F';' '{print $4}' 2>/dev/null || echo "0 B")
    TX_DAY=$(vnstat -d -i $IFACE --oneline | awk -F';' '{print $5}' 2>/dev/null || echo "0 B")
    TOT_DAY=$(vnstat -d -i $IFACE --oneline | awk -F';' '{print $6}' 2>/dev/null || echo "0 B")
    RX_MON=$(vnstat -m -i $IFACE --oneline | awk -F';' '{print $9}' 2>/dev/null || echo "0 B")
    TX_MON=$(vnstat -m -i $IFACE --oneline | awk -F';' '{print $10}' 2>/dev/null || echo "0 B")
    TOT_MON=$(vnstat -m -i $IFACE --oneline | awk -F';' '{print $11}' 2>/dev/null || echo "0 B")
    
    R1=$(cat /sys/class/net/$IFACE/statistics/rx_bytes); T1=$(cat /sys/class/net/$IFACE/statistics/tx_bytes); sleep 0.4
    R2=$(cat /sys/class/net/$IFACE/statistics/rx_bytes); T2=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
    TRAFFIC=$(echo "scale=2; (($R2 - $R1) + ($T2 - $T1)) * 8 / 409.6 / 1024" | bc)
    
    ACC_SSH=$(wc -l < "$D_SSH" 2>/dev/null || echo 0)
    ACC_VMESS=$(wc -l < "$D_VMESS" 2>/dev/null || echo 0)
    ACC_VLESS=$(wc -l < "$D_VLESS" 2>/dev/null || echo 0)
    ACC_TROJAN=$(wc -l < "$D_TROJAN" 2>/dev/null || echo 0)
    ACC_ZIVPN=$(wc -l < "$D_ZIVPN" 2>/dev/null || echo 0)

    echo -e "${CYAN}┌──────────────────────────────────────────────────────┐${NC}"
    print_center "${YELLOW}AUTO SCRIPT TENDO STORE ( AIO )${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
    
    echo -e "${CYAN}┌──────────────────────────────────────────────────────┐${NC}"
    print_line_open "  OS      : ${WHITE}${OS}${NC}"
    print_line_open "  RAM     : ${WHITE}${RAM}MB${NC}"
    print_line_open "  SWAP    : ${WHITE}${SWAP}MB${NC}"
    print_line_open "  CITY    : ${WHITE}${CITY}${NC}"
    print_line_open "  ISP     : ${WHITE}${ISP}${NC}"
    print_line_open "  IP      : ${WHITE}${IP}${NC}"
    print_line_open "  DOMAIN  : ${YELLOW}${DOMAIN}${NC}"
    print_line_open "  UPTIME  : ${WHITE}${UPTIME}${NC}"
    print_line_open "  ————————————————————————————"
    print_line_open "  MONTH   : ${TOT_MON}    [${MONTH_NAME}]"
    print_line_open "  RX      : ${RX_MON}"
    print_line_open "  TX      : ${TX_MON}"
    print_line_open "  ————————————————————————————"
    print_line_open "  DAY     : ${TOT_DAY}    [${DAY_NAME}]"
    print_line_open "  RX      : ${RX_DAY}"
    print_line_open "  TX      : ${TX_DAY}"
    print_line_open "  TRAFFIC : ${TRAFFIC} Mbit/s"
    echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
    
    if systemctl is-active --quiet xray; then X_ST="${GREEN}ON${NC}"; else X_ST="${RED}OFF${NC}"; fi
    if systemctl is-active --quiet zivpn; then Z_ST="${GREEN}ON${NC}"; else Z_ST="${RED}OFF${NC}"; fi
    if systemctl is-active --quiet dropbear; then D_ST="${GREEN}ON${NC}"; else D_ST="${RED}OFF${NC}"; fi
    
    echo -e "${CYAN}┌──────────────────────────────────────────────────────┐${NC}"
    print_line "  STATUS  : XRAY: ${X_ST} | SSH/WS: ${D_ST} | ZIVPN: ${Z_ST}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
    
    echo -e "${CYAN}┌──────────────────────────────────────────────────────┐${NC}"
    print_center "${YELLOW}LIST USER${NC}"
    print_center "————————————————————————————"
    
    local acc_all=$((ACC_SSH + ACC_VMESS + ACC_VLESS + ACC_TROJAN + ACC_ZIVPN))
    
    local f_ssh=$(printf "%-2s" "$ACC_SSH")
    local f_vm=$(printf "%-2s" "$ACC_VMESS")
    local f_vl=$(printf "%-2s" "$ACC_VLESS")
    local f_tr=$(printf "%-2s" "$ACC_TROJAN")
    local f_zi=$(printf "%-2s" "$ACC_ZIVPN")
    local f_all=$(printf "%-2s" "$acc_all")
    
    local STR1="SSH/WS : ${WHITE}${f_ssh}${NC} USR   |   VMESS : ${WHITE}${f_vm}${NC} USR"
    local STR2="VLESS  : ${WHITE}${f_vl}${NC} USR   |   TROJAN: ${WHITE}${f_tr}${NC} USR"
    local STR3="ZIVPN  : ${WHITE}${f_zi}${NC} USR   |   ALL   : ${WHITE}${f_all}${NC} USR"
    
    print_center "$STR1"
    print_center "$STR2"
    print_center "$STR3"
    echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
    
    echo -e "        ${CYAN}┌──────────────────────────────────────┐${NC}"
    echo -e "                Version   :  ${WHITE}v01.03.26${NC}         "
    echo -e "                Owner     :  ${WHITE}Tendo Store${NC}       "
    echo -e "                Telegram  :  ${WHITE}@tendo_32${NC}         "
    echo -e "                Expiry In :  ${WHITE}Lifetime${NC}          "
    echo -e "        ${CYAN}└──────────────────────────────────────┘${NC}"
}

function header_sub() {
    clear; echo -e "${CYAN}┌──────────────────────────────────────────────────────┐${NC}"
    print_center "${YELLOW}TENDO STORE - SUB MENU${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
}

# ---------------------------------------------
# MENU TELEGRAM BOT SETUP
# ---------------------------------------------
function menu_login_notif() {
    while true; do header_sub
        local st=$(cat /etc/tendo_bot/log_stat 2>/dev/null || echo "OFF")
        print_line " ————————————————————————————————————————"
        print_line "        Status [${st}]"
        print_line "  [1]  OFF"
        print_line "  [2]  Set Time Notif (h) jam (m) menit"
        print_line "  [x]  Exit"
        print_line " ————————————————————————————————————————"
        echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
        read -p " Pilihan: " opt2
        case $opt2 in
            1) echo "OFF" > /etc/tendo_bot/log_stat; crontab -l | grep -v "bot-login-notif" > /tmp/c.tmp; crontab /tmp/c.tmp; echo -e "${GREEN}Turned OFF${NC}"; sleep 1;;
            2) read -p " Durasi (e.g., 10m, 1h): " dur; 
               if [[ "$dur" =~ ^[0-9]+m$ ]]; then n=${dur%m}; [[ "$n" -lt 1 || "$n" -gt 59 ]] && { echo "Menit harus 1-59"; sleep 1; continue; }; c="*/${n} * * * *";
               elif [[ "$dur" =~ ^[0-9]+h$ ]]; then n=${dur%h}; [[ "$n" -lt 1 || "$n" -gt 23 ]] && { echo "Jam harus 1-23"; sleep 1; continue; }; c="0 */${n} * * *";
               else echo "Invalid"; sleep 1; continue; fi
               echo "ON (${dur})" > /etc/tendo_bot/log_stat
               crontab -l | grep -v "bot-login-notif" > /tmp/c.tmp; echo "$c /usr/local/bin/bot-login-notif" >> /tmp/c.tmp; crontab /tmp/c.tmp
               echo -e "${GREEN}Cron set to $dur${NC}"; sleep 1;;
            x) return;;
        esac
    done
}

function menu_backup_notif() {
    while true; do header_sub
        local st=$(cat /etc/tendo_bot/bak_stat 2>/dev/null || echo "OFF")
        print_line " ————————————————————————————————————————"
        print_line "        Status [${st}]"
        print_line "  [1]  OFF"
        print_line "  [2]  Set Time Backup (h) jam (m) menit"
        print_line "  [x]  Exit"
        print_line " ————————————————————————————————————————"
        echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
        read -p " Pilihan: " opt3
        case $opt3 in
            1) echo "OFF" > /etc/tendo_bot/bak_stat; crontab -l | grep -v "bot-backup" > /tmp/c.tmp; crontab /tmp/c.tmp; echo -e "${GREEN}Turned OFF${NC}"; sleep 1;;
            2) read -p " Durasi (e.g., 10m, 12h): " dur; 
               if [[ "$dur" =~ ^[0-9]+m$ ]]; then n=${dur%m}; [[ "$n" -lt 1 || "$n" -gt 59 ]] && { echo "Menit harus 1-59"; sleep 1; continue; }; c="*/${n} * * * *";
               elif [[ "$dur" =~ ^[0-9]+h$ ]]; then n=${dur%h}; [[ "$n" -lt 1 || "$n" -gt 23 ]] && { echo "Jam harus 1-23"; sleep 1; continue; }; c="0 */${n} * * *";
               else echo "Invalid"; sleep 1; continue; fi
               echo "ON (${dur})" > /etc/tendo_bot/bak_stat
               crontab -l | grep -v "bot-backup" > /tmp/c.tmp; echo "$c /usr/local/bin/bot-backup" >> /tmp/c.tmp; crontab /tmp/c.tmp
               echo -e "${GREEN}Cron set to $dur${NC}"; sleep 1;;
            x) return;;
        esac
    done
}

function bot_menu() {
    while true; do header_sub
        local st_log=$(cat /etc/tendo_bot/log_stat 2>/dev/null || echo "OFF")
        local st_bak=$(cat /etc/tendo_bot/bak_stat 2>/dev/null || echo "OFF")
        
        local cur_tok=$(cat /etc/tendo_bot/bot_token 2>/dev/null | tr -d '\r\n ')
        [[ -z "$cur_tok" ]] && cur_tok="Not setup" || cur_tok=$(echo "$cur_tok" | sed 's/.\{10\}$/**********/')
        local cur_id=$(cat /etc/tendo_bot/chat_id 2>/dev/null | tr -d '\r\n ')
        [[ -z "$cur_id" ]] && cur_id="Not setup"

        print_line " Bot Token :"
        print_line " ${GREEN}${cur_tok}${NC}"
        print_line " Chat ID   :"
        print_line " ${GREEN}${cur_id}${NC}"
        print_line " Notif Log : ${YELLOW}${st_log}${NC}"
        print_line " Notif Bak : ${YELLOW}${st_bak}${NC}"
        print_line " ————————————————————————————————————————"
        print_line " [1] Change BOT API & CHATID"
        print_line " [2] Set notifikasi User login"
        print_line " [3] Set notifikasi backup"
        print_line " [x] Back"
        echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
        read -p " Select Menu : " opt
        case $opt in
            1) read -p " Bot Token: " bt; read -p " Chat ID: " ci; echo "$bt" > /etc/tendo_bot/bot_token; echo "$ci" > /etc/tendo_bot/chat_id; echo -e "${GREEN}Saved Successfully!${NC}"; sleep 1;;
            2) menu_login_notif ;;
            3) menu_backup_notif ;;
            x) return;;
        esac
    done
}

function setup_client_bot_menu() {
    header_sub
    local c_tok=$(cat /etc/tendo_bot/client_token 2>/dev/null)
    local c_adm=$(cat /etc/tendo_bot/client_admin 2>/dev/null)
    echo -e "${YELLOW}--- SETUP CLIENT BOT TELEGRAM ---${NC}"
    echo -e " Token saat ini : ${GREEN}${c_tok:-Belum disetting}${NC}"
    echo -e " ID Admin       : ${GREEN}${c_adm:-Belum disetting}${NC}"
    echo -e "${CYAN}————————————————————————————————————————${NC}"
    
    read -p " Ingin mengubah/memasukkan data baru? (y/n): " chg
    if [[ "$chg" == "y" || "$chg" == "Y" || -z "$c_tok" ]]; then
        echo -e "${YELLOW}Pastikan anda sudah menyiapkan API Token dari @BotFather.${NC}"
        read -p " Masukkan Bot Token API: " bot_client_token
        [[ -z "$bot_client_token" ]] && return
        
        read -p " Masukkan User ID Anda (Admin): " bot_client_admin
        [[ -z "$bot_client_admin" ]] && bot_client_admin="0"
        
        echo "$bot_client_token" > /etc/tendo_bot/client_token
        echo "$bot_client_admin" > /etc/tendo_bot/client_admin
    else
        echo -e "${GREEN}Menggunakan konfigurasi bot sebelumnya...${NC}"
    fi

    echo -e "${YELLOW}Memastikan Module Python (pyTelegramBotAPI)...${NC}"
    pip3 install pyTelegramBotAPI --break-system-packages 2>/dev/null || pip3 install pyTelegramBotAPI 2>/dev/null
    
    cat > /usr/local/bin/client-bot-helper.sh << 'EOF'
#!/bin/bash
ACTION=$1; PROTO=$2; USER=$3; PASS=$4; DAYS=$5
CONFIG="/usr/local/etc/xray/config.json"
D_SSH="/usr/local/etc/xray/ssh.txt"; D_VMESS="/usr/local/etc/xray/vmess.txt"; D_VLESS="/usr/local/etc/xray/vless.txt"
D_TROJAN="/usr/local/etc/xray/trojan.txt"; D_ZIVPN="/etc/zivpn/zivpn.txt"
DMN=$(cat /usr/local/etc/xray/domain 2>/dev/null); CITY=$(cat /root/tendo/city 2>/dev/null)
ISP=$(cat /root/tendo/isp 2>/dev/null); IP=$(cat /root/tendo/ip 2>/dev/null)

if [[ "$ACTION" == "check" ]]; then
    if grep -q "^$USER|" $D_SSH $D_VMESS $D_VLESS $D_TROJAN $D_ZIVPN 2>/dev/null || id "$USER" &>/dev/null; then echo "EXISTS"; else echo "OK"; fi
    exit 0
fi

if [[ "$ACTION" == "info" ]]; then
    echo "<b>📊 INFORMASI JUMLAH USER AKTIF</b>"
    echo "<b>--------------------------------</b>"
    if [[ -f "$D_SSH" ]]; then c=$(wc -l < "$D_SSH" 2>/dev/null || echo 0); echo "<b>[ 🔹 SSH / WS ] : $c User</b>"; fi
    if [[ -f "$D_VMESS" ]]; then c=$(wc -l < "$D_VMESS" 2>/dev/null || echo 0); echo "<b>[ 🔹 VMESS ] : $c User</b>"; fi
    if [[ -f "$D_VLESS" ]]; then c=$(wc -l < "$D_VLESS" 2>/dev/null || echo 0); echo "<b>[ 🔹 VLESS ] : $c User</b>"; fi
    if [[ -f "$D_TROJAN" ]]; then c=$(wc -l < "$D_TROJAN" 2>/dev/null || echo 0); echo "<b>[ 🔹 TROJAN ] : $c User</b>"; fi
    if [[ -f "$D_ZIVPN" ]]; then c=$(wc -l < "$D_ZIVPN" 2>/dev/null || echo 0); echo "<b>[ 🔹 ZIVPN ] : $c User</b>"; fi
    exit 0
fi

if [[ "$ACTION" == "create" ]]; then
    if (( DAYS > 5 )); then DAYS=5; fi
    exp_date=$(date -d "+$DAYS days" +"%Y-%m-%d")
    limit=2; usage="0.00"
    
    if [[ "$PROTO" == "vmess" || "$PROTO" == "vless" || "$PROTO" == "trojan" ]]; then
        quota=100
        str_quota="100 GB"
    else
        quota=0
        str_quota="Unlimited"
    fi

    MSG_BOT=""
    
    if [[ "$PROTO" == "ssh" ]]; then
        grep -q "/bin/false" /etc/shells || echo "/bin/false" >> /etc/shells
        useradd -e $(date -d "$DAYS days" +"%Y-%m-%d") -s /bin/false -M $USER; echo "$USER:$PASS" | chpasswd
        echo "$USER|$PASS|$exp_date|$limit|ACTIVE" >> $D_SSH
        MSG_BOT+="<b>————————————————————————————————————</b>\n          <b>ACCOUNT SSH / WS</b>\n<b>————————————————————————————————————</b>\n"
        MSG_BOT+="Username       : <code>${USER}</code>\nPassword       : <code>${PASS}</code>\nCITY           : ${CITY}\nISP            : ${ISP}\nDomain         : <code>${DMN}</code>\n"
        MSG_BOT+="Port TLS       : 443, 8443\nPort none TLS  : 80, 8080\nPort any       : 2082, 2083, 8880\n"
        MSG_BOT+="Port OpenSSH   : 22, 444\nPort Dropbear  : 90\nPort UDPGW     : 7100-7600\nLimit IP       : ${limit} IP\n"
        MSG_BOT+="Payload WS     : <code>GET / HTTP/1.1[crlf]Host: ${DMN}[crlf]Upgrade: websocket[crlf][crlf]</code>\n"
        MSG_BOT+="Expired On     : ${exp_date}\n<b>————————————————————————————————————</b>\n"
    elif [[ "$PROTO" == "vmess" ]]; then
        uuid=$(uuidgen)
_tf6=$(mktemp) &&         jq --arg u "$USER" --arg id "$uuid" '(.inbounds[] | select(.protocol == "vmess")).settings.clients += [{"id":$id,"email":$u,"level":0}]' $CONFIG > "$_tf6" && mv "$_tf6" $CONFIG; chmod 644 $CONFIG
        echo "$USER|$uuid|$exp_date|$limit|ACTIVE|$quota" >> $D_VMESS; echo "0 0" > "/usr/local/etc/xray/quota/$USER"
        link_ws_tls=$(echo "{\"v\":\"2\",\"ps\":\"${USER}\",\"add\":\"${DMN}\",\"port\":\"443\",\"id\":\"${uuid}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess\",\"tls\":\"tls\",\"sni\":\"${DMN}\"}" | base64 -w 0)
        link_ws_ntls=$(echo "{\"v\":\"2\",\"ps\":\"${USER}\",\"add\":\"${DMN}\",\"port\":\"80\",\"id\":\"${uuid}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess\",\"tls\":\"\",\"sni\":\"\"}" | base64 -w 0)
        link_grpc_tls=$(echo "{\"v\":\"2\",\"ps\":\"${USER}\",\"add\":\"${DMN}\",\"port\":\"443\",\"id\":\"${uuid}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"grpc\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess-grpc\",\"tls\":\"tls\",\"sni\":\"${DMN}\"}" | base64 -w 0)
        link_upg_tls=$(echo "{\"v\":\"2\",\"ps\":\"${USER}\",\"add\":\"${DMN}\",\"port\":\"443\",\"id\":\"${uuid}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"httpupgrade\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess-upg\",\"tls\":\"tls\",\"sni\":\"${DMN}\"}" | base64 -w 0)
        MSG_BOT+="<b>————————————————————————————————————</b>\n               <b>VMESS</b>\n<b>————————————————————————————————————</b>\n"
        MSG_BOT+="Username       : <code>${USER}</code>\nCITY           : ${CITY}\nISP            : ${ISP}\nDomain         : <code>${DMN}</code>\nPort TLS       : 443\nPort none TLS  : 80\n"
        MSG_BOT+="Password / ID  : <code>${uuid}</code>\nalterId        : 0\nSecurity       : auto\n"
        MSG_BOT+="network        : ws, grpc, upgrade\npath ws        : /vmess\nserviceName    : vmess-grpc\npath upgrade   : /vmess-upg\n"
        MSG_BOT+="Limit IP       : ${limit} IP\nQuota Bandwidth: ${str_quota}\nUsage Bandwidth: ${usage} GB\nExpired On     : ${exp_date}\n"
        MSG_BOT+="<b>————————————————————————————————————</b>\n           <b>VMESS WS TLS</b>\n<b>————————————————————————————————————</b>\n<code>vmess://${link_ws_tls}</code>\n<b>————————————————————————————————————</b>\n"
        MSG_BOT+="          <b>VMESS WS NO TLS</b>\n<b>————————————————————————————————————</b>\n<code>vmess://${link_ws_ntls}</code>\n<b>————————————————————————————————————</b>\n"
        MSG_BOT+="             <b>VMESS GRPC</b>\n<b>————————————————————————————————————</b>\n<code>vmess://${link_grpc_tls}</code>\n<b>————————————————————————————————————</b>\n"
        MSG_BOT+="         <b>VMESS Upgrade TLS</b>\n<b>————————————————————————————————————</b>\n<code>vmess://${link_upg_tls}</code>\n<b>————————————————————————————————————</b>\n"
    elif [[ "$PROTO" == "vless" ]]; then
        uuid=$(uuidgen)
_tf7=$(mktemp) &&         jq --arg u "$USER" --arg id "$uuid" '(.inbounds[] | select(.protocol == "vless" and (.tag != "inbound-443" and .tag != "inbound-80"))).settings.clients += [{"id":$id,"email":$u,"level":0}]' $CONFIG > "$_tf7" && mv "$_tf7" $CONFIG; chmod 644 $CONFIG
        echo "$USER|$uuid|$exp_date|$limit|ACTIVE|$quota" >> $D_VLESS; echo "0 0" > "/usr/local/etc/xray/quota/$USER"
        link_ws_tls="vless://${uuid}@${DMN}:443?path=%2Fvless&security=tls&encryption=none&host=${DMN}&type=ws&sni=${DMN}#${USER}"
        link_ws_ntls="vless://${uuid}@${DMN}:80?path=%2Fvless&security=none&encryption=none&host=${DMN}&type=ws#${USER}"
        link_grpc_tls="vless://${uuid}@${DMN}:443?security=tls&encryption=none&host=${DMN}&type=grpc&serviceName=vless-grpc&sni=${DMN}#${USER}"
        link_upg_tls="vless://${uuid}@${DMN}:443?path=%2Fvless-upg&security=tls&encryption=none&host=${DMN}&type=httpupgrade&sni=${DMN}#${USER}"
        MSG_BOT+="<b>————————————————————————————————————</b>\n               <b>VLESS</b>\n<b>————————————————————————————————————</b>\n"
        MSG_BOT+="Username       : <code>${USER}</code>\nCITY           : ${CITY}\nISP            : ${ISP}\nDomain         : <code>${DMN}</code>\nPort TLS       : 443\nPort none TLS  : 80\n"
        MSG_BOT+="Password / ID  : <code>${uuid}</code>\nEncryption     : none\n"
        MSG_BOT+="network        : ws, grpc, upgrade\npath ws        : /vless\nserviceName    : vless-grpc\npath upgrade   : /vless-upg\n"
        MSG_BOT+="Limit IP       : ${limit} IP\nQuota Bandwidth: ${str_quota}\nUsage Bandwidth: ${usage} GB\nExpired On     : ${exp_date}\n"
        MSG_BOT+="<b>————————————————————————————————————</b>\n           <b>VLESS WS TLS</b>\n<b>————————————————————————————————————</b>\n<code>${link_ws_tls}</code>\n<b>————————————————————————————————————</b>\n"
        MSG_BOT+="          <b>VLESS WS NO TLS</b>\n<b>————————————————————————————————————</b>\n<code>${link_ws_ntls}</code>\n<b>————————————————————————————————————</b>\n"
        MSG_BOT+="             <b>VLESS GRPC</b>\n<b>————————————————————————————————————</b>\n<code>${link_grpc_tls}</code>\n<b>————————————————————————————————————</b>\n"
        MSG_BOT+="         <b>VLESS Upgrade TLS</b>\n<b>————————————————————————————————————</b>\n<code>${link_upg_tls}</code>\n<b>————————————————————————————————————</b>\n"
    elif [[ "$PROTO" == "trojan" ]]; then
        uuid="$USER"
_tf8=$(mktemp) &&         jq --arg p "$uuid" --arg u "$USER" '(.inbounds[] | select(.protocol == "trojan")).settings.clients += [{"password":$p,"email":$u,"level":0}]' $CONFIG > "$_tf8" && mv "$_tf8" $CONFIG; chmod 644 $CONFIG
        echo "$USER|$uuid|$exp_date|$limit|ACTIVE|$quota" >> $D_TROJAN; echo "0 0" > "/usr/local/etc/xray/quota/$USER"
        link_ws_tls="trojan://${uuid}@${DMN}:443?path=%2Ftrojan&security=tls&host=${DMN}&type=ws&sni=${DMN}#${USER}"
        link_grpc_tls="trojan://${uuid}@${DMN}:443?security=tls&host=${DMN}&type=grpc&serviceName=trojan-grpc&sni=${DMN}#${USER}"
        link_upg_tls="trojan://${uuid}@${DMN}:443?path=%2Ftrojan-upg&security=tls&host=${DMN}&type=httpupgrade&sni=${DMN}#${USER}"
        MSG_BOT+="<b>————————————————————————————————————</b>\n               <b>TROJAN</b>\n<b>————————————————————————————————————</b>\n"
        MSG_BOT+="Username       : <code>${USER}</code>\nCITY           : ${CITY}\nISP            : ${ISP}\nDomain         : <code>${DMN}</code>\nPort TLS       : 443\nPort none TLS  : 80\n"
        MSG_BOT+="Password       : <code>${uuid}</code>\n"
        MSG_BOT+="network        : ws, grpc, upgrade\npath ws        : /trojan\nserviceName    : trojan-grpc\npath upgrade   : /trojan-upg\n"
        MSG_BOT+="Limit IP       : ${limit} IP\nQuota Bandwidth: ${str_quota}\nUsage Traffic: ${usage} GB\nExpired On     : ${exp_date}\n"
        MSG_BOT+="<b>————————————————————————————————————</b>\n           <b>TROJAN WS TLS</b>\n<b>————————————————————————————————————</b>\n<code>${link_ws_tls}</code>\n<b>————————————————————————————————————</b>\n"
        MSG_BOT+="             <b>TROJAN GRPC</b>\n<b>————————————————————————————————————</b>\n<code>${link_grpc_tls}</code>\n<b>————————————————————————————————————</b>\n"
        MSG_BOT+="         <b>TROJAN Upgrade TLS</b>\n<b>————————————————————————————————————</b>\n<code>${link_upg_tls}</code>\n<b>————————————————————————————————————</b>\n"
    elif [[ "$PROTO" == "zivpn" ]]; then
_tf24=$(mktemp) &&         jq --arg pwd "$USER" '.auth.config += [$pwd]' /etc/zivpn/config.json > "$_tf24" && mv "$_tf24" /etc/zivpn/config.json
        echo "$USER|$USER|$exp_date" >> $D_ZIVPN
        MSG_BOT+="<b>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</b>\n  <b>ACCOUNT ZIVPN UDP</b>\n<b>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</b>\n"
        MSG_BOT+="Password   : <code>${USER}</code>\nCITY       : ${CITY}\nISP        : ${ISP}\nIP ISP     : <code>${IP}</code>\nDomain     : <code>${DMN}</code>\nExpired On : ${exp_date}\n<b>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</b>\n"
    fi
    
    echo -e "$MSG_BOT"
    
    if [[ "$PROTO" == "vmess" || "$PROTO" == "vless" || "$PROTO" == "trojan" ]]; then
        nohup bash -c "sleep 1 && systemctl restart xray" >/dev/null 2>&1 &
    elif [[ "$PROTO" == "zivpn" ]]; then
        nohup bash -c "sleep 1 && systemctl restart zivpn" >/dev/null 2>&1 &
    fi
    
    exit 0
fi
EOF
    chmod +x /usr/local/bin/client-bot-helper.sh

    cat > /usr/local/bin/tendo-client-bot.py << 'EOF'
import telebot
from telebot import types
import subprocess
import os

try:
    TOKEN = open("/etc/tendo_bot/client_token").read().strip()
    ADMIN_ID = open("/etc/tendo_bot/client_admin").read().strip()
except:
    exit(1)

bot = telebot.TeleBot(TOKEN)
creation_data = {}

@bot.message_handler(commands=['menu'])
def send_welcome(message):
    markup = types.InlineKeyboardMarkup(row_width=2)
    btn_ssh = types.InlineKeyboardButton("➕ Create SSH", callback_data="proto_ssh")
    btn_xray = types.InlineKeyboardButton("➕ Create XRAY", callback_data="menu_xray")
    btn_zi = types.InlineKeyboardButton("➕ Create ZIVPN", callback_data="proto_zivpn")
    btn_info = types.InlineKeyboardButton("ℹ️ Informasi", callback_data="info_akun")
    btn_grup = types.InlineKeyboardButton("👥 Grup", url="https://t.me/tendo32")
    btn_donasi = types.InlineKeyboardButton("💳 Donasi", callback_data="donasi")
    btn_premium = types.InlineKeyboardButton("🛒 Order Premium", url="https://wa.me/message/MAROWFSVEZWDL1")
    btn_admin = types.InlineKeyboardButton("📞 Hubungi Admin", url="https://t.me/tendo_32")
    
    markup.add(btn_ssh, btn_xray)
    markup.add(btn_zi, btn_info)
    markup.add(btn_grup, btn_donasi)
    markup.add(btn_premium, btn_admin)
    bot.send_message(message.chat.id, "Selamat datang! Silakan pilih menu interaktif di bawah ini untuk membuat akun VPN free.", reply_markup=markup)

@bot.message_handler(func=lambda message: True)
def handle_other_text(message):
    bot.reply_to(message, "Silakan ketik /menu untuk memulai bot.")

@bot.callback_query_handler(func=lambda call: True)
def callback_query(call):
    chat_id = call.message.chat.id
    msg_id = call.message.message_id

    if call.data == "menu_xray":
        markup = types.InlineKeyboardMarkup(row_width=2)
        markup.add(
            types.InlineKeyboardButton("🔹 VMESS", callback_data="proto_vmess"),
            types.InlineKeyboardButton("🔹 VLESS", callback_data="proto_vless"),
            types.InlineKeyboardButton("🔹 TROJAN", callback_data="proto_trojan"),
            types.InlineKeyboardButton("🔙 Kembali", callback_data="menu_main")
        )
        bot.edit_message_text(chat_id=chat_id, message_id=msg_id, text="Silakan pilih protokol X-ray:", reply_markup=markup)
    
    elif call.data == "menu_main":
        markup = types.InlineKeyboardMarkup(row_width=2)
        markup.add(
            types.InlineKeyboardButton("➕ Create SSH", callback_data="proto_ssh"),
            types.InlineKeyboardButton("➕ Create XRAY", callback_data="menu_xray"),
            types.InlineKeyboardButton("➕ Create ZIVPN", callback_data="proto_zivpn"),
            types.InlineKeyboardButton("ℹ️ Informasi", callback_data="info_akun"),
            types.InlineKeyboardButton("👥 Grup", url="https://t.me/tendo32"),
            types.InlineKeyboardButton("💳 Donasi", callback_data="donasi"),
            types.InlineKeyboardButton("🛒 Order Premium", url="https://wa.me/message/MAROWFSVEZWDL1"),
            types.InlineKeyboardButton("📞 Hubungi Admin", url="https://t.me/tendo_32")
        )
        bot.edit_message_text(chat_id=chat_id, message_id=msg_id, text="Selamat datang! Silakan pilih menu interaktif di bawah ini untuk membuat akun VPN free.", reply_markup=markup)
    
    elif call.data == "info_akun":
        res = subprocess.run(["/usr/local/bin/client-bot-helper.sh", "info"], capture_output=True, text=True)
        bot.send_message(chat_id, res.stdout, parse_mode="HTML")

    elif call.data == "donasi":
        donasi_text = """•────────────────────• 
❑ 082224460678 𝗢𝗩𝗢 
❑ 082224460678 𝗗𝗔𝗡𝗔
❑ 082224460678 𝗟𝗜𝗡𝗞 𝗔𝗝𝗔
❑ 082224460678 𝗚𝗢𝗣𝗔𝗬
❑ 082224460678 𝗦𝗛𝗢𝗣𝗘𝗘𝗣𝗔𝗬
•────────────────────•"""
        bot.send_photo(chat_id, "https://i.postimg.cc/9QXppGXs/Kode-QRIS-Tendo-Store-Jepara.png", caption=donasi_text)

    elif call.data.startswith("proto_"):
        proto = call.data.split("_")[1]
        creation_data[chat_id] = {'proto': proto}
        msg = bot.send_message(chat_id, f"💬 <b>MEMBUAT AKUN {proto.upper()}</b>\n\nSilakan ketik Username yang Anda inginkan (tanpa spasi):", parse_mode="HTML")
        bot.register_next_step_handler(msg, process_username)

    elif call.data.startswith("dur_"):
        if chat_id not in creation_data: return
        days = call.data.split("_")[1]
        creation_data[chat_id]['days'] = days
        finalize_creation(chat_id, msg_id)

def process_username(message):
    chat_id = message.chat.id
    if chat_id not in creation_data: return
    
    username = message.text.strip().replace(" ", "")
    proto = creation_data[chat_id]['proto']
    
    if not username:
        bot.send_message(chat_id, "❌ Username tidak valid. Silakan ulangi /menu")
        return
        
    res = subprocess.run(["/usr/local/bin/client-bot-helper.sh", "check", proto, username], capture_output=True, text=True)
    if "EXISTS" in res.stdout:
        bot.send_message(chat_id, f"❌ Username <b>{username}</b> sudah digunakan! Silakan ulangi /menu dan gunakan nama lain.", parse_mode="HTML")
        return
        
    creation_data[chat_id]['user'] = username

    if proto == "ssh":
        msg = bot.send_message(chat_id, f"🔑 Username <b>{username}</b> tersedia!\n\nSilakan ketik <b>Password</b> untuk akun SSH ini:", parse_mode="HTML")
        bot.register_next_step_handler(msg, process_password_ssh)
    else:
        creation_data[chat_id]['pass'] = username
        ask_duration(chat_id)

def process_password_ssh(message):
    chat_id = message.chat.id
    if chat_id not in creation_data: return
    password = message.text.strip()
    if not password:
        bot.send_message(chat_id, "❌ Password tidak valid. Silakan ulangi /menu")
        return
    creation_data[chat_id]['pass'] = password
    ask_duration(chat_id)

def ask_duration(chat_id):
    markup = types.InlineKeyboardMarkup(row_width=5)
    markup.add(
        types.InlineKeyboardButton("1 Hari", callback_data="dur_1"),
        types.InlineKeyboardButton("2 Hari", callback_data="dur_2"),
        types.InlineKeyboardButton("3 Hari", callback_data="dur_3"),
        types.InlineKeyboardButton("4 Hari", callback_data="dur_4"),
        types.InlineKeyboardButton("5 Hari", callback_data="dur_5")
    )
    bot.send_message(chat_id, "✅ Data diterima!\n\nPilih durasi masa aktif (Maks 5 Hari):", reply_markup=markup)

def finalize_creation(chat_id, msg_id):
    data = creation_data.pop(chat_id, None)
    if not data: return

    proto = data['proto']
    user = data['user']
    passwd = data['pass']
    days = data.get('days', '1')

    msg_text = f"⏳ Sedang memproses pembuatan akun {proto.upper()} untuk {user} ({days} Hari)..."

    bot.edit_message_text(chat_id=chat_id, message_id=msg_id, text=msg_text)
    res = subprocess.run(["/usr/local/bin/client-bot-helper.sh", "create", proto, user, passwd, days], capture_output=True, text=True)
    bot.send_message(chat_id, res.stdout.replace('\\n', '\n'), parse_mode="HTML")

bot.infinity_polling()
EOF
    
    cat > /etc/systemd/system/tendo-client-bot.service << 'EOF'
[Unit]
Description=Tendo Telegram Client Bot
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/tendo-client-bot.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable tendo-client-bot >/dev/null 2>&1
    systemctl restart tendo-client-bot >/dev/null 2>&1
    
    echo -e "${GREEN}Bot Client berhasil diinstall dan dijalankan dengan versi tombol inline!${NC}"
    echo -e "${YELLOW}Silakan chat bot kamu di Telegram dan ketik /menu${NC}"
    sleep 3
}

# ---------------------------------------------
# MENU SSH & X-RAY MANAGER
# ---------------------------------------------
function ssh_menu() {
    while true; do header_sub
        print_line " [1] Create Account SSH"
        print_line " [2] Delete Account SSH"
        print_line " [3] Renew Account SSH"
        print_line " [4] Check Config User"
        print_line " [5] Trial Account SSH"
        print_line " [6] Lock Account SSH"
        print_line " [7] Unlock Account SSH"
        print_line " [x] Back"
        echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
        read -p " Select Menu : " opt
        case $opt in
            1) read -p " Username : " u; [[ -z "$u" ]] && continue
               if ! check_exists "$u"; then continue; fi
               read -p " Password : " p; read -p " Expired (days): " ex; [[ -z "$ex" ]] && ex=30; read -p " Limit IP (0 for unlimited): " limit; [[ -z "$limit" ]] && limit=0
               exp_date=$(date -d "+$ex days" +"%Y-%m-%d")
               grep -q "/bin/false" /etc/shells || echo "/bin/false" >> /etc/shells; useradd -e $(date -d "$ex days" +"%Y-%m-%d") -s /bin/false -M $u; echo "$u:$p" | chpasswd; echo "$u|$p|$exp_date|$limit|ACTIVE" >> $D_SSH; DMN=$(cat /usr/local/etc/xray/domain); show_account_ssh "$u" "$p" "$DMN" "$exp_date" "$limit";;
            2) nl $D_SSH; read -p "No: " n; [[ -z "$n" ]] && continue; u=$(sed -n "${n}p" $D_SSH | cut -d'|' -f1); sed -i "${n}d" $D_SSH; userdel -f $u 2>/dev/null; echo -e "${GREEN}Account SSH Deleted!${NC}"; sleep 2;;
            3) nl $D_SSH; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_SSH); u=$(echo "$line" | cut -d'|' -f1); p=$(echo "$line" | cut -d'|' -f2); exp_old=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); stat=$(echo "$line" | cut -d'|' -f5); read -p " Add Days: " add_days; exp_new=$(date -d "$exp_old + $add_days days" +"%Y-%m-%d"); sed -i "${n}s/.*/$u|$p|$exp_new|$limit|$stat/" $D_SSH; chage -E $(date -d "$exp_new" +"%Y-%m-%d") $u 2>/dev/null; echo -e "${GREEN}Account $u Renewed until $exp_new!${NC}"; sleep 2;;
            4) nl $D_SSH; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_SSH); u=$(echo "$line" | cut -d'|' -f1); p=$(echo "$line" | cut -d'|' -f2); exp_date=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); DMN=$(cat /usr/local/etc/xray/domain); show_account_ssh "$u" "$p" "$DMN" "$exp_date" "$limit";;
            5) u="trial-$(tr -dc a-z0-9 </dev/urandom | head -c 5)"; echo -e " Username (Trial): ${GREEN}$u${NC}"; p="$u"; read -p " Duration (e.g., 10m, 1h): " dur;
               if [[ "$dur" == *m ]]; then add_str="+${dur%m} minutes"; elif [[ "$dur" == *h ]]; then add_str="+${dur%h} hours"; else add_str="+1 hours"; fi
               exp_date=$(date -d "$add_str" +"%Y-%m-%d %H:%M:%S"); limit=1; grep -q "/bin/false" /etc/shells || echo "/bin/false" >> /etc/shells; useradd -e $(date -d "$add_str" +"%Y-%m-%d") -s /bin/false -M $u; echo "$u:$p" | chpasswd; echo "$u|$p|$exp_date|$limit|ACTIVE" >> $D_SSH; DMN=$(cat /usr/local/etc/xray/domain); show_account_ssh "$u" "$p" "$DMN" "$exp_date" "$limit";;
            6) nl $D_SSH; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_SSH); u=$(echo "$line" | cut -d'|' -f1); p=$(echo "$line" | cut -d'|' -f2); exp=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); stat=$(echo "$line" | cut -d'|' -f5)
               if [[ "$stat" == "ACTIVE" ]]; then
                   usermod -L "$u" 2>/dev/null; killall -u "$u" 2>/dev/null
                   sed -i "${n}s/.*/$u|$p|$exp|$limit|LOCKED/" $D_SSH
                   echo -e "${GREEN}Account $u Locked Successfully!${NC}"; sleep 2
               else
                   echo -e "${RED}Account is already locked!${NC}"; sleep 2
               fi;;
            7) nl $D_SSH; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_SSH); u=$(echo "$line" | cut -d'|' -f1); p=$(echo "$line" | cut -d'|' -f2); exp=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); stat=$(echo "$line" | cut -d'|' -f5)
               if [[ "$stat" != "ACTIVE" ]]; then
                   usermod -U "$u" 2>/dev/null
                   sed -i "${n}s/.*/$u|$p|$exp|$limit|ACTIVE/" $D_SSH
                   echo -e "${GREEN}Account $u Unlocked Successfully!${NC}"; sleep 2
               else
                   echo -e "${YELLOW}Account is already Active!${NC}"; sleep 2
               fi;;
            x) return;;
        esac
    done
}

function xray_manager_menu() {
    while true; do header_sub
        print_line " [1] VMESS ACCOUNT"
        print_line " [2] VLESS ACCOUNT"
        print_line " [3] TROJAN ACCOUNT"
        print_line " [x] Back"
        echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
        read -p " Select Menu : " opt
        case $opt in
            1) vmess_menu ;;
            2) vless_menu ;;
            3) trojan_menu ;;
            x) return ;;
        esac
    done
}

function auto_reboot_menu() {
    while true; do header_sub
        if [[ -f "/etc/cron.d/autoreboot" ]]; then
            local st=$(cat /etc/cron.d/autoreboot | awk '{print $2":"$1}')
            print_line "        Status [ON - $st]"
        else
            print_line "        Status [OFF]"
        fi
        print_line " ————————————————————————————————————————"
        print_line "   1.)  Turn ON (Set Time)"
        print_line "   2.)  Turn OFF"
        print_line "   x.)  Exit"
        print_line " ————————————————————————————————————————"
        echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
        read -p " Pilihan: " opt
        case $opt in
            1) read -p " Set Jam (0-23): " hr
               read -p " Set Menit (0-59): " min
               echo "$min $hr * * * root reboot" > /etc/cron.d/autoreboot
               service cron restart
               echo -e "${GREEN}Auto Reboot set to $hr:$min!${NC}"
               sleep 2;;
            2) rm -f /etc/cron.d/autoreboot
               service cron restart
               echo -e "${GREEN}Auto Reboot dimatikan!${NC}"
               sleep 2;;
            x) return;;
        esac
    done
}

function rebuild_menu() {
    header_sub
    print_center "${RED}WARNING: REBUILD HAPUS DATA VPS!${NC}"
    print_center "Pastikan anda sudah melakukan Backup Data."
    print_line " ————————————————————————————————————————"
    print_line " [1] Ubuntu 22.04"
    print_line " [2] Ubuntu 20.04"
    print_line " [3] Debian 12"
    print_line " [4] Debian 11"
    print_line " [x] Cancel"
    echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
    read -p " Pilih OS untuk Rebuild: " opt
    case $opt in
        1) os="ubuntu 22.04" ;;
        2) os="ubuntu 20.04" ;;
        3) os="debian 12" ;;
        4) os="debian 11" ;;
        x) return ;;
        *) echo "Invalid"; sleep 1; return ;;
    esac
    
    read -p "Apakah anda yakin ingin Rebuild ke $os? (y/n): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "${YELLOW}Memulai proses Rebuild ke $os... Koneksi akan terputus.${NC}"
        cd /root
        curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh
        bash reinstall.sh $os
        reboot
    else
        echo -e "${GREEN}Rebuild dibatalkan.${NC}"
        sleep 2
    fi
}

function check_services() {
    header_sub
    if systemctl is-active --quiet xray; then X_ST="${GREEN}ON${NC}"; else X_ST="${RED}OFF${NC}"; fi
    if systemctl is-active --quiet zivpn; then Z_ST="${GREEN}ON${NC}"; else Z_ST="${RED}OFF${NC}"; fi
    if systemctl is-active --quiet dropbear; then D_ST="${GREEN}ON${NC}"; else D_ST="${RED}OFF${NC}"; fi
    if systemctl is-active --quiet ws-proxy; then W_ST="${GREEN}ON${NC}"; else W_ST="${RED}OFF${NC}"; fi
    if systemctl is-active --quiet vnstat; then V_ST="${GREEN}ON${NC}"; else V_ST="${RED}OFF${NC}"; fi
    if iptables -L >/dev/null 2>&1; then I_ST="${GREEN}ON${NC}"; else I_ST="${RED}OFF${NC}"; fi
    
    print_line " Xray Core       : ${X_ST}"
    print_line " Dropbear SSH    : ${D_ST}"
    print_line " WS SSH Proxy    : ${W_ST}"
    print_line " ZIVPN UDP       : ${Z_ST}"
    print_line " Vnstat Mon      : ${V_ST}"
    print_line " IPtables        : ${I_ST}"
    
    echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
    read -p "Enter..."
}

function features_menu() {
    while true; do header_sub
        print_line " [1] Check Bandwidth"
        print_line " [2] Speedtest by Ookla"
        print_line " [3] Check Benchmark VPS"
        print_line " [4] Change Domain VPS"
        print_line " [5] Restart All Services"
        print_line " [6] Clear Cache RAM"
        print_line " [7] Set Auto Reboot"
        print_line " [8] Information System"
        print_line " [9] Backup Data VPS"
        print_line " [10] Restore Data VPS"
        print_line " [11] Rebuild VPS"
        print_line " [12] Check Services"
        print_line " [13] Change Banner SSH"
        print_line " [14] Setup Client Telegram Bot"
        print_line " [x] Back"
        echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
        read -p " Select Menu : " opt
        case $opt in
            1) vnstat -l -i $(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1); read -p "Enter...";;
            2) speedtest; read -p "Enter...";;
            3) echo -e "${YELLOW}Running Benchmark...${NC}"; wget -qO- bench.sh | bash; read -p "Enter...";;
            4) header_sub
               print_center "${YELLOW}WARNING: Mengganti domain = Update Sertifikat SSL!${NC}"
               echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
               read -p "Masukan Domain Baru: " nd
               if [[ -z "$nd" ]]; then continue; fi
               echo -e "${YELLOW}Processing...${NC}"
               echo "$nd" > /usr/local/etc/xray/domain
               openssl req -x509 -newkey rsa:2048 -nodes -sha256 -keyout /usr/local/etc/xray/xray.key -out /usr/local/etc/xray/xray.crt -days 3650 -subj "/CN=$nd" >/dev/null 2>&1
               chmod 644 /usr/local/etc/xray/xray.key; chmod 644 /usr/local/etc/xray/xray.crt
               systemctl restart xray stunnel4
               echo -e "${GREEN}Domain Berhasil Diperbarui menjadi: $nd${NC}"
               sleep 2;;
            5) systemctl restart xray zivpn vnstat dropbear stunnel4 ws-proxy tendo-client-bot; echo -e "${GREEN}Services Restarted!${NC}"; sleep 2;;
            6) sync; echo 3 > /proc/sys/vm/drop_caches; echo -e "${GREEN}Cache Cleared!${NC}"; sleep 1;;
            7) auto_reboot_menu ;;
            8) neofetch; read -p "Enter...";;
            9) 
               clear; echo -e "${YELLOW}Memproses Backup Data VPS...${NC}"
               if ! command -v zip &> /dev/null; then apt-get install -y zip >/dev/null 2>&1; fi
               # Pastikan permission benar SEBELUM di-zip, supaya backup
               # tidak ikut menyimpan permission rusak (600) ke masa depan.
               chmod 644 /usr/local/etc/xray/config.json 2>/dev/null
               chmod 644 /usr/local/etc/xray/xray.key 2>/dev/null
               chmod 644 /usr/local/etc/xray/xray.crt 2>/dev/null
               DATE=$(date +"%Y-%m-%d_%H-%M")
               ZIP_FILE="/root/Backup_${DATE}.zip"
               cd /
               zip -r $ZIP_FILE usr/local/etc/xray/ etc/zivpn/ etc/tendo_bot/ etc/issue.net usr/local/bin/tendo-client-bot.py usr/local/bin/client-bot-helper.sh etc/systemd/system/tendo-client-bot.service >/dev/null 2>&1
               cd - >/dev/null 2>&1
               
               if [[ ! -f "$ZIP_FILE" ]]; then
                   echo -e "${RED}Gagal membuat file backup!${NC}"
                   read -p "Tekan Enter untuk kembali..."
                   continue
               fi

               echo -e "${GREEN}File Backup tersimpan di VPS: ${ZIP_FILE}${NC}"
               echo -e "${YELLOW}Mengunggah ke server cloud (Mencari Direct Link)...${NC}"
               LINK=$(curl -s --upload-file $ZIP_FILE https://transfer.sh/Backup_${DATE}.zip)
               echo -e "\n${CYAN}=================================================${NC}"
               echo -e "${GREEN}Sukses! Simpan link di bawah ini untuk Restore:${NC}"
               echo -e "${WHITE}${LINK}${NC}"
               echo -e "${CYAN}=================================================${NC}\n"
               
               local bot_tok=$(cat /etc/tendo_bot/bot_token 2>/dev/null | tr -d '\r\n ')
               local chat_id=$(cat /etc/tendo_bot/chat_id 2>/dev/null | tr -d '\r\n ')
               local IP_VPS=$(cat /root/tendo/ip 2>/dev/null)
               local DOM_VPS=$(cat /usr/local/etc/xray/domain 2>/dev/null)
               local ISP_VPS=$(cat /root/tendo/isp 2>/dev/null)
               
               if [[ -n "$bot_tok" && -n "$chat_id" ]]; then
                   echo -e "${YELLOW}Mengirim backup ke Telegram Bot...${NC}"
                   curl -s -X POST "https://api.telegram.org/bot${bot_tok}/sendDocument" \
                       -F "chat_id=${chat_id}" \
                       -F "document=@${ZIP_FILE}" \
                       -F "caption=📦 MANUAL BACKUP VPS"$'\n\n'"IP     : ${IP_VPS}"$'\n'"DOMAIN : ${DOM_VPS}"$'\n'"ISP    : ${ISP_VPS}"$'\n\n'"📅 Date: ${DATE}"$'\n'"✅ Backup Successfully generated."$'\n'"🔗 Direct Link: ${LINK}" > /dev/null
                   echo -e "${GREEN}File backup berhasil dikirim ke Telegram!${NC}"
               fi
               read -p "Tekan Enter untuk kembali..."
               ;;
            10) 
               clear; echo -e "${YELLOW}--- RESTORE DATA VPS ---${NC}"
               echo -e "${RED}Warning: Data saat ini akan ditimpa dengan data dari Backup!${NC}"
               read -p " Masukkan Link Direct Backup (.zip) : " link_res
               if [[ -n "$link_res" ]]; then
                   echo -e "${YELLOW}Mengunduh file backup...${NC}"
                   wget -qO /root/restore.zip "$link_res"
                   if [[ -f "/root/restore.zip" ]]; then
                       echo -e "${YELLOW}Mengekstrak dan memulihkan data (X-ray, ZIVPN, Domain, Bot, Banner)...${NC}"
                       cd /
                       unzip -o /root/restore.zip >/dev/null 2>&1
                       cd - >/dev/null 2>&1
                       rm -f /root/restore.zip

                       # Perbaikan permission: file backup lama mungkin membawa
                       # permission rusak (600) hasil bug versi sebelumnya.
                       # Paksa balik ke permission yang benar agar xray (User=nobody)
                       # tetap bisa baca config & key setelah restore.
                       chmod 644 /usr/local/etc/xray/config.json 2>/dev/null
                       chmod 644 /usr/local/etc/xray/xray.key 2>/dev/null
                       chmod 644 /usr/local/etc/xray/xray.crt 2>/dev/null

                       # 777 tidak perlu: semua script bot (tendo-client-bot, bot-backup,
                       # bot-login-notif) jalan sebagai root. 700 cukup dan lebih aman
                       # (bot_token & chat_id di dalamnya jangan sampai bisa ditulis user lain).
                       chmod -R 700 /etc/tendo_bot/ 2>/dev/null
                       systemctl daemon-reload
                       chmod +x /usr/local/bin/client-bot-helper.sh 2>/dev/null
                       
                       if [[ -f "/etc/tendo_bot/client_token" ]]; then
                           pip3 install pyTelegramBotAPI --break-system-packages 2>/dev/null || pip3 install pyTelegramBotAPI 2>/dev/null
                           systemctl enable tendo-client-bot >/dev/null 2>&1
                           systemctl restart tendo-client-bot >/dev/null 2>&1
                       fi
                       
                       (crontab -l 2>/dev/null | grep -v "xray-exp"; echo "* * * * * /usr/local/bin/xray-exp") | crontab -
                       (crontab -l 2>/dev/null | grep -v "xray-limit"; echo "* * * * * /usr/local/bin/xray-limit") | crontab -
                       (crontab -l 2>/dev/null | grep -v "xray-quota"; echo "* * * * * /usr/local/bin/xray-quota") | crontab -
                       
                       if [[ "$(cat /etc/tendo_bot/log_stat 2>/dev/null)" == ON* ]]; then
                           dur=$(cat /etc/tendo_bot/log_stat | grep -oP '\(\K[^\)]+')
                           if [[ "$dur" == *m ]]; then c="*/${dur%m} * * * *"; elif [[ "$dur" == *h ]]; then c="0 */${dur%h} * * *"; fi
                           crontab -l | grep -v "bot-login-notif" > /tmp/c.tmp; echo "$c /usr/local/bin/bot-login-notif" >> /tmp/c.tmp; crontab /tmp/c.tmp
                       fi
                       if [[ "$(cat /etc/tendo_bot/bak_stat 2>/dev/null)" == ON* ]]; then
                           dur=$(cat /etc/tendo_bot/bak_stat | grep -oP '\(\K[^\)]+')
                           if [[ "$dur" == *m ]]; then c="*/${dur%m} * * * *"; elif [[ "$dur" == *h ]]; then c="0 */${dur%h} * * *"; fi
                           crontab -l | grep -v "bot-backup" > /tmp/c.tmp; echo "$c /usr/local/bin/bot-backup" >> /tmp/c.tmp; crontab /tmp/c.tmp
                       fi

                       if [[ -f "/usr/local/etc/xray/ssh.txt" ]]; then
                           while IFS="|" read -r u p exp limit stat quota; do
                               [[ -z "$u" ]] && continue
                               grep -q "/bin/false" /etc/shells || echo "/bin/false" >> /etc/shells
                               if id "$u" &>/dev/null; then
                                   usermod -e $(date -d "$exp" +"%Y-%m-%d" 2>/dev/null) -s /bin/false "$u" 2>/dev/null
                               else
                                   useradd -e $(date -d "$exp" +"%Y-%m-%d" 2>/dev/null) -s /bin/false -M "$u" 2>/dev/null
                               fi
                               echo "$u:$p" | chpasswd 2>/dev/null
                               if [[ "$stat" == "LOCKED"* || "$stat" == "LOCKED" ]]; then
                                   usermod -L "$u" 2>/dev/null
                               else
                                   usermod -U "$u" 2>/dev/null
                               fi
                           done < "/usr/local/etc/xray/ssh.txt"
                       fi

                       systemctl restart xray zivpn dropbear ws-proxy stunnel4 ssh sshd
                       echo -e "${GREEN}Restore Berhasil! Semua konfigurasi dan akun telah dipulihkan.${NC}"
                       sleep 3
                   else
                       echo -e "${RED}Gagal mengunduh file! Pastikan link direct yang dimasukkan valid.${NC}"
                       read -p "Tekan Enter untuk kembali..."
                   fi
               fi
               ;;
            11) rebuild_menu ;;
            12) check_services ;;
            13) clear
                echo -e "${YELLOW}Silakan edit banner SSH di Nano Text Editor.${NC}"
                echo -e "${YELLOW}Cara save: Tekan [CTRL+X], lalu ketik [Y], lalu tekan [Enter].${NC}"
                sleep 4
                nano /etc/issue.net
                systemctl restart ssh sshd dropbear 2>/dev/null
                echo -e "${GREEN}Banner SSH Berhasil Diperbarui!${NC}"
                sleep 2;;
            14) setup_client_bot_menu ;;
            x) return;;
        esac
    done
}

# ---------------------------------------------
# FUNGSI MENU PROTOKOL (XRAY & ZIVPN)
# ---------------------------------------------
function vmess_menu() {
    while true; do header_sub
        print_line " [1] Create Account Vmess"
        print_line " [2] Delete Account Vmess"
        print_line " [3] Renew Account Vmess"
        print_line " [4] Check Config User"
        print_line " [5] Trial Account Vmess"
        print_line " [6] Lock Account Vmess"
        print_line " [7] Unlock Account Vmess"
        print_line " [x] Back"
        echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
        read -p " Select Menu : " opt
        case $opt in
            1) read -p " Username : " u; [[ -z "$u" ]] && continue
               if ! check_exists "$u"; then continue; fi
               read -p " Password (ID/UUID) : " p; [[ -z "$p" ]] && p=$(uuidgen); id="$p"
               if ! check_uuid "$id"; then continue; fi
               read -p " Expired (days): " ex; [[ -z "$ex" ]] && ex=30; read -p " Limit IP (0 for unlimited): " limit; [[ -z "$limit" ]] && limit=0; read -p " Quota Bandwidth GB (0 for unlimited): " quota; [[ -z "$quota" ]] && quota=0
               exp_date=$(date -d "+$ex days" +"%Y-%m-%d");_tf9=$(mktemp) &&  jq --arg u "$u" --arg id "$id" '(.inbounds[] | select(.protocol == "vmess")).settings.clients += [{"id":$id,"email":$u,"level":0}]' $CONFIG > "$_tf9" && mv "$_tf9" $CONFIG; chmod 644 $CONFIG; echo "$u|$id|$exp_date|$limit|ACTIVE|$quota" >> $D_VMESS; echo "0 0" > "/usr/local/etc/xray/quota/$u"
               DMN=$(cat /usr/local/etc/xray/domain)
               ws_tls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"443\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess\",\"tls\":\"tls\",\"sni\":\"${DMN}\"}" | base64 -w 0)
               ws_ntls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"80\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess\",\"tls\":\"\",\"sni\":\"\"}" | base64 -w 0)
               grpc_tls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"443\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"grpc\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess-grpc\",\"tls\":\"tls\",\"sni\":\"${DMN}\"}" | base64 -w 0)
               upg_tls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"443\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"httpupgrade\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess-upg\",\"tls\":\"tls\",\"sni\":\"${DMN}\"}" | base64 -w 0)
               upg_ntls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"80\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"httpupgrade\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess-upg\",\"tls\":\"\",\"sni\":\"\"}" | base64 -w 0)
               show_account_xray "VMESS" "$u" "$DMN" "$id" "$exp_date" "$limit" "$quota" "0.00" "vmess://$ws_tls" "vmess://$ws_ntls" "vmess://$grpc_tls" "vmess://$upg_tls" "vmess://$upg_ntls"
               ;;
            2) nl $D_VMESS; read -p "No: " n; [[ -z "$n" ]] && continue; u=$(sed -n "${n}p" $D_VMESS | cut -d'|' -f1); sed -i "${n}d" $D_VMESS;_tf10=$(mktemp) &&  jq --arg u "$u" '(.inbounds[] | select(.protocol == "vmess")).settings.clients |= map(select(.email != $u))' $CONFIG > "$_tf10" && mv "$_tf10" $CONFIG; chmod 644 $CONFIG; rm -f "/usr/local/etc/xray/quota/$u"
               echo -e "${GREEN}Account Deleted!${NC}"; systemctl restart xray >/dev/null 2>&1; sleep 2;;
            3) nl $D_VMESS; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_VMESS); u=$(echo "$line" | cut -d'|' -f1); id=$(echo "$line" | cut -d'|' -f2); exp_old=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); stat=$(echo "$line" | cut -d'|' -f5); quota=$(echo "$line" | cut -d'|' -f6); read -p " Add Days: " add_days; exp_new=$(date -d "$exp_old + $add_days days" +"%Y-%m-%d"); sed -i "${n}s/.*/$u|$id|$exp_new|$limit|$stat|$quota/" $D_VMESS
               echo -e "${GREEN}Account $u Renewed until $exp_new!${NC}"; systemctl restart xray >/dev/null 2>&1; sleep 2;;
            4) nl $D_VMESS; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_VMESS); u=$(echo "$line" | cut -d'|' -f1); id=$(echo "$line" | cut -d'|' -f2); exp_date=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); quota=$(echo "$line" | cut -d'|' -f6); [[ -z "$quota" ]] && quota=0; DMN=$(cat /usr/local/etc/xray/domain)
               QUOTA_FILE="/usr/local/etc/xray/quota/${u}"
               if [[ -f "$QUOTA_FILE" ]]; then read total_acc last_api < "$QUOTA_FILE"; usage_gb=$(awk "BEGIN {printf \"%.2f\", $total_acc/1073741824}"); else usage_gb="0.00"; fi
               ws_tls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"443\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess\",\"tls\":\"tls\",\"sni\":\"${DMN}\"}" | base64 -w 0)
               ws_ntls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"80\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess\",\"tls\":\"\",\"sni\":\"\"}" | base64 -w 0)
               grpc_tls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"443\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"grpc\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess-grpc\",\"tls\":\"tls\",\"sni\":\"${DMN}\"}" | base64 -w 0)
               upg_tls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"443\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"httpupgrade\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess-upg\",\"tls\":\"tls\",\"sni\":\"${DMN}\"}" | base64 -w 0)
               upg_ntls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"80\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"httpupgrade\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess-upg\",\"tls\":\"\",\"sni\":\"\"}" | base64 -w 0)
               show_account_xray "VMESS" "$u" "$DMN" "$id" "$exp_date" "$limit" "$quota" "$usage_gb" "vmess://$ws_tls" "vmess://$ws_ntls" "vmess://$grpc_tls" "vmess://$upg_tls" "vmess://$upg_ntls";;
            5) u="trial-$(tr -dc a-z0-9 </dev/urandom | head -c 5)"; echo -e " Username (Trial): ${GREEN}$u${NC}"; p="$u"; id="$p"; read -p " Duration (e.g., 10m, 1h): " dur;
               if [[ "$dur" == *m ]]; then add_str="+${dur%m} minutes"; elif [[ "$dur" == *h ]]; then add_str="+${dur%h} hours"; else add_str="+1 hours"; fi
               exp_date=$(date -d "$add_str" +"%Y-%m-%d %H:%M:%S"); limit=1; quota=0;_tf11=$(mktemp) &&  jq --arg u "$u" --arg id "$id" '(.inbounds[] | select(.protocol == "vmess")).settings.clients += [{"id":$id,"email":$u,"level":0}]' $CONFIG > "$_tf11" && mv "$_tf11" $CONFIG; chmod 644 $CONFIG; echo "$u|$id|$exp_date|$limit|ACTIVE|$quota" >> $D_VMESS; echo "0 0" > "/usr/local/etc/xray/quota/$u"
               DMN=$(cat /usr/local/etc/xray/domain)
               ws_tls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"443\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess\",\"tls\":\"tls\",\"sni\":\"${DMN}\"}" | base64 -w 0)
               ws_ntls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"80\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess\",\"tls\":\"\",\"sni\":\"\"}" | base64 -w 0)
               grpc_tls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"443\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"grpc\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess-grpc\",\"tls\":\"tls\",\"sni\":\"${DMN}\"}" | base64 -w 0)
               upg_tls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"443\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"httpupgrade\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess-upg\",\"tls\":\"tls\",\"sni\":\"${DMN}\"}" | base64 -w 0)
               upg_ntls=$(echo "{\"v\":\"2\",\"ps\":\"${u}\",\"add\":\"${DMN}\",\"port\":\"80\",\"id\":\"${id}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"httpupgrade\",\"type\":\"none\",\"host\":\"${DMN}\",\"path\":\"/vmess-upg\",\"tls\":\"\",\"sni\":\"\"}" | base64 -w 0)
               show_account_xray "VMESS" "$u" "$DMN" "$id" "$exp_date" "$limit" "$quota" "0.00" "vmess://$ws_tls" "vmess://$ws_ntls" "vmess://$grpc_tls" "vmess://$upg_tls" "vmess://$upg_ntls"
               ;;
            6) nl $D_VMESS; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_VMESS); u=$(echo "$line" | cut -d'|' -f1); id=$(echo "$line" | cut -d'|' -f2); exp=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); stat=$(echo "$line" | cut -d'|' -f5); quota=$(echo "$line" | cut -d'|' -f6)
               if [[ "$stat" == "ACTIVE" ]]; then
_tf12=$(mktemp) &&                    jq --arg u "$u" '(.inbounds[] | select(.protocol == "vmess")).settings.clients |= map(select(.email != $u))' $CONFIG > "$_tf12" && mv "$_tf12" $CONFIG; chmod 644 $CONFIG
                   sed -i "${n}s/.*/$u|$id|$exp|$limit|LOCKED|$quota/" $D_VMESS
                   echo -e "${GREEN}Account $u Locked Successfully!${NC}"; systemctl restart xray >/dev/null 2>&1; sleep 2
               else
                   echo -e "${RED}Account is already locked!${NC}"; sleep 2
               fi;;
            7) nl $D_VMESS; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_VMESS); u=$(echo "$line" | cut -d'|' -f1); id=$(echo "$line" | cut -d'|' -f2); exp=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); stat=$(echo "$line" | cut -d'|' -f5); quota=$(echo "$line" | cut -d'|' -f6)
               if [[ "$stat" != "ACTIVE" ]]; then
_tf13=$(mktemp) &&                    jq --arg u "$u" --arg id "$id" '(.inbounds[] | select(.protocol == "vmess")).settings.clients += [{"id":$id,"email":$u,"level":0}]' $CONFIG > "$_tf13" && mv "$_tf13" $CONFIG; chmod 644 $CONFIG
                   sed -i "${n}s/.*/$u|$id|$exp|$limit|ACTIVE|$quota/" $D_VMESS
                   echo -e "${GREEN}Account $u Unlocked Successfully!${NC}"; systemctl restart xray >/dev/null 2>&1; sleep 2
               else
                   echo -e "${YELLOW}Account is already Active!${NC}"; sleep 2
               fi;;
            x) return;;
        esac; done
}

function vless_menu() {
    while true; do header_sub
        print_line " [1] Create Account Vless"
        print_line " [2] Delete Account Vless"
        print_line " [3] Renew Account Vless"
        print_line " [4] Check Config User"
        print_line " [5] Trial Account Vless"
        print_line " [6] Lock Account Vless"
        print_line " [7] Unlock Account Vless"
        print_line " [x] Back"
        echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
        read -p " Select Menu : " opt
        case $opt in
            1) read -p " Username : " u; [[ -z "$u" ]] && continue
               if ! check_exists "$u"; then continue; fi
               read -p " Password (ID/UUID) : " p; [[ -z "$p" ]] && p=$(uuidgen); id="$p"
               if ! check_uuid "$id"; then continue; fi
               read -p " Expired (days): " ex; [[ -z "$ex" ]] && ex=30; read -p " Limit IP (0 for unlimited): " limit; [[ -z "$limit" ]] && limit=0; read -p " Quota Bandwidth GB (0 for unlimited): " quota; [[ -z "$quota" ]] && quota=0
               exp_date=$(date -d "+$ex days" +"%Y-%m-%d");_tf14=$(mktemp) &&  jq --arg u "$u" --arg id "$id" '(.inbounds[] | select(.protocol == "vless" and (.tag != "inbound-443" and .tag != "inbound-80"))).settings.clients += [{"id":$id,"email":$u,"level":0}]' $CONFIG > "$_tf14" && mv "$_tf14" $CONFIG; chmod 644 $CONFIG; echo "$u|$id|$exp_date|$limit|ACTIVE|$quota" >> $D_VLESS; echo "0 0" > "/usr/local/etc/xray/quota/$u"
               DMN=$(cat /usr/local/etc/xray/domain)
               ws_tls="vless://${id}@${DMN}:443?path=%2Fvless&security=tls&encryption=none&host=${DMN}&type=ws&sni=${DMN}#${u}"
               ws_ntls="vless://${id}@${DMN}:80?path=%2Fvless&security=none&encryption=none&host=${DMN}&type=ws#${u}"
               grpc_tls="vless://${id}@${DMN}:443?security=tls&encryption=none&host=${DMN}&type=grpc&serviceName=vless-grpc&sni=${DMN}#${u}"
               upg_tls="vless://${id}@${DMN}:443?path=%2Fvless-upg&security=tls&encryption=none&host=${DMN}&type=httpupgrade&sni=${DMN}#${u}"
               upg_ntls="vless://${id}@${DMN}:80?path=%2Fvless-upg&security=none&encryption=none&host=${DMN}&type=httpupgrade#${u}"
               show_account_xray "VLESS" "$u" "$DMN" "$id" "$exp_date" "$limit" "$quota" "0.00" "$ws_tls" "$ws_ntls" "$grpc_tls" "$upg_tls" "$upg_ntls"
               ;;
            2) nl $D_VLESS; read -p "No: " n; [[ -z "$n" ]] && continue; u=$(sed -n "${n}p" $D_VLESS | cut -d'|' -f1); sed -i "${n}d" $D_VLESS;_tf15=$(mktemp) &&  jq --arg u "$u" '(.inbounds[] | select(.protocol == "vless" and (.tag != "inbound-443" and .tag != "inbound-80"))).settings.clients |= map(select(.email != $u))' $CONFIG > "$_tf15" && mv "$_tf15" $CONFIG; chmod 644 $CONFIG; rm -f "/usr/local/etc/xray/quota/$u"
               echo -e "${GREEN}Account Deleted!${NC}"; systemctl restart xray >/dev/null 2>&1; sleep 2;;
            3) nl $D_VLESS; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_VLESS); u=$(echo "$line" | cut -d'|' -f1); id=$(echo "$line" | cut -d'|' -f2); exp_old=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); stat=$(echo "$line" | cut -d'|' -f5); quota=$(echo "$line" | cut -d'|' -f6); read -p " Add Days: " add_days; exp_new=$(date -d "$exp_old + $add_days days" +"%Y-%m-%d"); sed -i "${n}s/.*/$u|$id|$exp_new|$limit|$stat|$quota/" $D_VLESS
               echo -e "${GREEN}Account $u Renewed until $exp_new!${NC}"; systemctl restart xray >/dev/null 2>&1; sleep 2;;
            4) nl $D_VLESS; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_VLESS); u=$(echo "$line" | cut -d'|' -f1); id=$(echo "$line" | cut -d'|' -f2); exp_date=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); quota=$(echo "$line" | cut -d'|' -f6); [[ -z "$quota" ]] && quota=0; DMN=$(cat /usr/local/etc/xray/domain)
               QUOTA_FILE="/usr/local/etc/xray/quota/${u}"
               if [[ -f "$QUOTA_FILE" ]]; then read total_acc last_api < "$QUOTA_FILE"; usage_gb=$(awk "BEGIN {printf \"%.2f\", $total_acc/1073741824}"); else usage_gb="0.00"; fi
               ws_tls="vless://${id}@${DMN}:443?path=%2Fvless&security=tls&encryption=none&host=${DMN}&type=ws&sni=${DMN}#${u}"
               ws_ntls="vless://${id}@${DMN}:80?path=%2Fvless&security=none&encryption=none&host=${DMN}&type=ws#${u}"
               grpc_tls="vless://${id}@${DMN}:443?security=tls&encryption=none&host=${DMN}&type=grpc&serviceName=vless-grpc&sni=${DMN}#${u}"
               upg_tls="vless://${id}@${DMN}:443?path=%2Fvless-upg&security=tls&encryption=none&host=${DMN}&type=httpupgrade&sni=${DMN}#${u}"
               upg_ntls="vless://${id}@${DMN}:80?path=%2Fvless-upg&security=none&encryption=none&host=${DMN}&type=httpupgrade#${u}"
               show_account_xray "VLESS" "$u" "$DMN" "$id" "$exp_date" "$limit" "$quota" "$usage_gb" "$ws_tls" "$ws_ntls" "$grpc_tls" "$upg_tls" "$upg_ntls";;
            5) u="trial-$(tr -dc a-z0-9 </dev/urandom | head -c 5)"; echo -e " Username (Trial): ${GREEN}$u${NC}"; p="$u"; id="$p"; read -p " Duration (e.g., 10m, 1h): " dur;
               if [[ "$dur" == *m ]]; then add_str="+${dur%m} minutes"; elif [[ "$dur" == *h ]]; then add_str="+${dur%h} hours"; else add_str="+1 hours"; fi
               exp_date=$(date -d "$add_str" +"%Y-%m-%d %H:%M:%S"); limit=1; quota=0;_tf16=$(mktemp) &&  jq --arg u "$u" --arg id "$id" '(.inbounds[] | select(.protocol == "vless" and (.tag != "inbound-443" and .tag != "inbound-80"))).settings.clients += [{"id":$id,"email":$u,"level":0}]' $CONFIG > "$_tf16" && mv "$_tf16" $CONFIG; chmod 644 $CONFIG; echo "$u|$id|$exp_date|$limit|ACTIVE|$quota" >> $D_VLESS; echo "0 0" > "/usr/local/etc/xray/quota/$u"
               DMN=$(cat /usr/local/etc/xray/domain)
               ws_tls="vless://${id}@${DMN}:443?path=%2Fvless&security=tls&encryption=none&host=${DMN}&type=ws&sni=${DMN}#${u}"
               ws_ntls="vless://${id}@${DMN}:80?path=%2Fvless&security=none&encryption=none&host=${DMN}&type=ws#${u}"
               grpc_tls="vless://${id}@${DMN}:443?security=tls&encryption=none&host=${DMN}&type=grpc&serviceName=vless-grpc&sni=${DMN}#${u}"
               upg_tls="vless://${id}@${DMN}:443?path=%2Fvless-upg&security=tls&encryption=none&host=${DMN}&type=httpupgrade&sni=${DMN}#${u}"
               upg_ntls="vless://${id}@${DMN}:80?path=%2Fvless-upg&security=none&encryption=none&host=${DMN}&type=httpupgrade#${u}"
               show_account_xray "VLESS" "$u" "$DMN" "$id" "$exp_date" "$limit" "$quota" "0.00" "$ws_tls" "$ws_ntls" "$grpc_tls" "$upg_tls" "$upg_ntls"
               ;;
            6) nl $D_VLESS; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_VLESS); u=$(echo "$line" | cut -d'|' -f1); id=$(echo "$line" | cut -d'|' -f2); exp=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); stat=$(echo "$line" | cut -d'|' -f5); quota=$(echo "$line" | cut -d'|' -f6)
               if [[ "$stat" == "ACTIVE" ]]; then
_tf17=$(mktemp) &&                    jq --arg u "$u" '(.inbounds[] | select(.protocol == "vless" and (.tag != "inbound-443" and .tag != "inbound-80"))).settings.clients |= map(select(.email != $u))' $CONFIG > "$_tf17" && mv "$_tf17" $CONFIG; chmod 644 $CONFIG
                   sed -i "${n}s/.*/$u|$id|$exp|$limit|LOCKED|$quota/" $D_VLESS
                   echo -e "${GREEN}Account $u Locked Successfully!${NC}"; systemctl restart xray >/dev/null 2>&1; sleep 2
               else
                   echo -e "${RED}Account is already locked!${NC}"; sleep 2
               fi;;
            7) nl $D_VLESS; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_VLESS); u=$(echo "$line" | cut -d'|' -f1); id=$(echo "$line" | cut -d'|' -f2); exp=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); stat=$(echo "$line" | cut -d'|' -f5); quota=$(echo "$line" | cut -d'|' -f6)
               if [[ "$stat" != "ACTIVE" ]]; then
_tf18=$(mktemp) &&                    jq --arg u "$u" --arg id "$id" '(.inbounds[] | select(.protocol == "vless" and (.tag != "inbound-443" and .tag != "inbound-80"))).settings.clients += [{"id":$id,"email":$u,"level":0}]' $CONFIG > "$_tf18" && mv "$_tf18" $CONFIG; chmod 644 $CONFIG
                   sed -i "${n}s/.*/$u|$id|$exp|$limit|ACTIVE|$quota/" $D_VLESS
                   echo -e "${GREEN}Account $u Unlocked Successfully!${NC}"; systemctl restart xray >/dev/null 2>&1; sleep 2
               else
                   echo -e "${YELLOW}Account is already Active!${NC}"; sleep 2
               fi;;
            x) return;;
        esac; done
}

function trojan_menu() {
    while true; do header_sub
        print_line " [1] Create Account Trojan"
        print_line " [2] Delete Account Trojan"
        print_line " [3] Renew Account Trojan"
        print_line " [4] Check Config User"
        print_line " [5] Trial Account Trojan"
        print_line " [6] Lock Account Trojan"
        print_line " [7] Unlock Account Trojan"
        print_line " [x] Back"
        echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
        read -p " Select Menu : " opt
        case $opt in
            1) read -p " Username : " u; [[ -z "$u" ]] && continue
               if ! check_exists "$u"; then continue; fi
               read -p " Password : " p; [[ -z "$p" ]] && p="$u"; pass="$p"
               if ! check_uuid "$pass"; then continue; fi
               read -p " Expired (days): " ex; [[ -z "$ex" ]] && ex=30; read -p " Limit IP (0 for unlimited): " limit; [[ -z "$limit" ]] && limit=0; read -p " Quota Bandwidth GB (0 for unlimited): " quota; [[ -z "$quota" ]] && quota=0
               exp_date=$(date -d "+$ex days" +"%Y-%m-%d");_tf19=$(mktemp) &&  jq --arg p "$pass" --arg u "$u" '(.inbounds[] | select(.protocol == "trojan")).settings.clients += [{"password":$p,"email":$u,"level":0}]' $CONFIG > "$_tf19" && mv "$_tf19" $CONFIG; chmod 644 $CONFIG; echo "$u|$pass|$exp_date|$limit|ACTIVE|$quota" >> $D_TROJAN; echo "0 0" > "/usr/local/etc/xray/quota/$u"
               DMN=$(cat /usr/local/etc/xray/domain)
               ws_tls="trojan://${pass}@${DMN}:443?path=%2Ftrojan&security=tls&host=${DMN}&type=ws&sni=${DMN}#${u}"
               ws_ntls="trojan://${pass}@${DMN}:80?path=%2Ftrojan&security=none&host=${DMN}&type=ws#${u}"
               grpc_tls="trojan://${pass}@${DMN}:443?security=tls&host=${DMN}&type=grpc&serviceName=trojan-grpc&sni=${DMN}#${u}"
               upg_tls="trojan://${pass}@${DMN}:443?path=%2Ftrojan-upg&security=tls&host=${DMN}&type=httpupgrade&sni=${DMN}#${u}"
               show_account_xray "TROJAN" "$u" "$DMN" "$pass" "$exp_date" "$limit" "$quota" "0.00" "$ws_tls" "$ws_ntls" "$grpc_tls" "$upg_tls" ""
               ;;
            2) nl $D_TROJAN; read -p "No: " n; [[ -z "$n" ]] && continue; u=$(sed -n "${n}p" $D_TROJAN | cut -d'|' -f1); sed -i "${n}d" $D_TROJAN;_tf20=$(mktemp) &&  jq --arg u "$u" '(.inbounds[] | select(.protocol == "trojan")).settings.clients |= map(select(.email != $u))' $CONFIG > "$_tf20" && mv "$_tf20" $CONFIG; chmod 644 $CONFIG; rm -f "/usr/local/etc/xray/quota/$u"
               echo -e "${GREEN}Account Deleted!${NC}"; systemctl restart xray >/dev/null 2>&1; sleep 2;;
            3) nl $D_TROJAN; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_TROJAN); u=$(echo "$line" | cut -d'|' -f1); pass=$(echo "$line" | cut -d'|' -f2); exp_old=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); stat=$(echo "$line" | cut -d'|' -f5); quota=$(echo "$line" | cut -d'|' -f6); read -p " Add Days: " add_days; exp_new=$(date -d "$exp_old + $add_days days" +"%Y-%m-%d"); sed -i "${n}s/.*/$u|$pass|$exp_new|$limit|$stat|$quota/" $D_TROJAN
               echo -e "${GREEN}Account $u Renewed until $exp_new!${NC}"; systemctl restart xray >/dev/null 2>&1; sleep 2;;
            4) nl $D_TROJAN; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_TROJAN); u=$(echo "$line" | cut -d'|' -f1); pass=$(echo "$line" | cut -d'|' -f2); exp_date=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); quota=$(echo "$line" | cut -d'|' -f6); [[ -z "$quota" ]] && quota=0; DMN=$(cat /usr/local/etc/xray/domain)
               QUOTA_FILE="/usr/local/etc/xray/quota/${u}"
               if [[ -f "$QUOTA_FILE" ]]; then read total_acc last_api < "$QUOTA_FILE"; usage_gb=$(awk "BEGIN {printf \"%.2f\", $total_acc/1073741824}"); else usage_gb="0.00"; fi
               ws_tls="trojan://${pass}@${DMN}:443?path=%2Ftrojan&security=tls&host=${DMN}&type=ws&sni=${DMN}#${u}"
               ws_ntls="trojan://${pass}@${DMN}:80?path=%2Ftrojan&security=none&host=${DMN}&type=ws#${u}"
               grpc_tls="trojan://${pass}@${DMN}:443?security=tls&host=${DMN}&type=grpc&serviceName=trojan-grpc&sni=${DMN}#${u}"
               upg_tls="trojan://${pass}@${DMN}:443?path=%2Ftrojan-upg&security=tls&host=${DMN}&type=httpupgrade&sni=${DMN}#${u}"
               show_account_xray "TROJAN" "$u" "$DMN" "$pass" "$exp_date" "$limit" "$quota" "$usage_gb" "$ws_tls" "$ws_ntls" "$grpc_tls" "$upg_tls" "";;
            5) u="trial-$(tr -dc a-z0-9 </dev/urandom | head -c 5)"; echo -e " Username (Trial): ${GREEN}$u${NC}"; p="$u"; pass="$p"; read -p " Duration (e.g., 10m, 1h): " dur;
               if [[ "$dur" == *m ]]; then add_str="+${dur%m} minutes"; elif [[ "$dur" == *h ]]; then add_str="+${dur%h} hours"; else add_str="+1 hours"; fi
               exp_date=$(date -d "$add_str" +"%Y-%m-%d %H:%M:%S"); limit=1; quota=0;_tf21=$(mktemp) &&  jq --arg p "$pass" --arg u "$u" '(.inbounds[] | select(.protocol == "trojan")).settings.clients += [{"password":$p,"email":$u,"level":0}]' $CONFIG > "$_tf21" && mv "$_tf21" $CONFIG; chmod 644 $CONFIG; echo "$u|$pass|$exp_date|$limit|ACTIVE|$quota" >> $D_TROJAN; echo "0 0" > "/usr/local/etc/xray/quota/$u"
               DMN=$(cat /usr/local/etc/xray/domain)
               ws_tls="trojan://${pass}@${DMN}:443?path=%2Ftrojan&security=tls&host=${DMN}&type=ws&sni=${DMN}#${u}"
               ws_ntls="trojan://${pass}@${DMN}:80?path=%2Ftrojan&security=none&host=${DMN}&type=ws#${u}"
               grpc_tls="trojan://${pass}@${DMN}:443?security=tls&host=${DMN}&type=grpc&serviceName=trojan-grpc&sni=${DMN}#${u}"
               upg_tls="trojan://${pass}@${DMN}:443?path=%2Ftrojan-upg&security=tls&host=${DMN}&type=httpupgrade&sni=${DMN}#${u}"
               show_account_xray "TROJAN" "$u" "$DMN" "$pass" "$exp_date" "$limit" "$quota" "0.00" "$ws_tls" "$ws_ntls" "$grpc_tls" "$upg_tls" ""
               ;;
            6) nl $D_TROJAN; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_TROJAN); u=$(echo "$line" | cut -d'|' -f1); pass=$(echo "$line" | cut -d'|' -f2); exp=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); stat=$(echo "$line" | cut -d'|' -f5); quota=$(echo "$line" | cut -d'|' -f6)
               if [[ "$stat" == "ACTIVE" ]]; then
_tf22=$(mktemp) &&                    jq --arg u "$u" '(.inbounds[] | select(.protocol == "trojan")).settings.clients |= map(select(.email != $u))' $CONFIG > "$_tf22" && mv "$_tf22" $CONFIG; chmod 644 $CONFIG
                   sed -i "${n}s/.*/$u|$pass|$exp|$limit|LOCKED|$quota/" $D_TROJAN
                   echo -e "${GREEN}Account $u Locked Successfully!${NC}"; systemctl restart xray >/dev/null 2>&1; sleep 2
               else
                   echo -e "${RED}Account is already locked!${NC}"; sleep 2
               fi;;
            7) nl $D_TROJAN; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_TROJAN); u=$(echo "$line" | cut -d'|' -f1); pass=$(echo "$line" | cut -d'|' -f2); exp=$(echo "$line" | cut -d'|' -f3); limit=$(echo "$line" | cut -d'|' -f4); stat=$(echo "$line" | cut -d'|' -f5); quota=$(echo "$line" | cut -d'|' -f6)
               if [[ "$stat" != "ACTIVE" ]]; then
_tf23=$(mktemp) &&                    jq --arg p "$pass" --arg u "$u" '(.inbounds[] | select(.protocol == "trojan")).settings.clients += [{"password":$p,"email":$u,"level":0}]' $CONFIG > "$_tf23" && mv "$_tf23" $CONFIG; chmod 644 $CONFIG
                   sed -i "${n}s/.*/$u|$pass|$exp|$limit|ACTIVE|$quota/" $D_TROJAN
                   echo -e "${GREEN}Account $u Unlocked Successfully!${NC}"; systemctl restart xray >/dev/null 2>&1; sleep 2
               else
                   echo -e "${YELLOW}Account is already Active!${NC}"; sleep 2
               fi;;
            x) return;;
        esac; done
}

function zivpn_menu() {
    while true; do header_sub
        print_line " [1] Create Account ZIVPN"
        print_line " [2] Delete Account ZIVPN"
        print_line " [3] Renew Account ZIVPN"
        print_line " [4] Check Config User"
        print_line " [5] Trial Account ZIVPN"
        print_line " [x] Back"
        echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
        read -p " Select Menu : " opt
        case $opt in
            1) read -p " Password : " p; [[ -z "$p" ]] && continue
               u="$p"
               if ! check_exists "$u"; then continue; fi
               if grep -q "|$p|" $D_ZIVPN 2>/dev/null || grep -q "^$p|" $D_ZIVPN 2>/dev/null; then echo -e "${RED}Password '$p' sudah digunakan!${NC}"; sleep 2; continue; fi
               read -p " Expired (days): " ex; [[ -z "$ex" ]] && ex=30; exp=$(date -d "$ex days" +"%Y-%m-%d");_tf25=$(mktemp) &&  jq --arg pwd "$p" '.auth.config += [$pwd]' /etc/zivpn/config.json > "$_tf25" && mv "$_tf25" /etc/zivpn/config.json; echo "$u|$p|$exp" >> $D_ZIVPN; DMN=$(cat /usr/local/etc/xray/domain); show_account_zivpn "$u" "$p" "$DMN" "$exp"
               ;;
            2) nl $D_ZIVPN; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_ZIVPN); IFS="|" read -r f1 f2 f3 <<< "$line"; if [[ -z "$f3" ]]; then p="$f1"; else p="$f2"; fi; sed -i "${n}d" $D_ZIVPN;_tf26=$(mktemp) &&  jq --arg pwd "$p" 'del(.auth.config[] | select(. == $pwd))' /etc/zivpn/config.json > "$_tf26" && mv "$_tf26" /etc/zivpn/config.json
               echo -e "${GREEN}Account Deleted!${NC}"; systemctl restart zivpn >/dev/null 2>&1; sleep 2;;
            3) nl $D_ZIVPN; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_ZIVPN); IFS="|" read -r f1 f2 f3 <<< "$line"; if [[ -z "$f3" ]]; then u="unknown"; p="$f1"; exp_old="$f2"; else u="$f1"; p="$f2"; exp_old="$f3"; fi; read -p " Add Days: " add_days; exp_new=$(date -d "$exp_old + $add_days days" +"%Y-%m-%d"); if [[ "$u" == "unknown" ]]; then sed -i "${n}s/.*/$p|$exp_new/" $D_ZIVPN; else sed -i "${n}s/.*/$u|$p|$exp_new/" $D_ZIVPN; fi
               echo -e "${GREEN}ZIVPN Account Renewed until $exp_new!${NC}"; systemctl restart zivpn >/dev/null 2>&1; sleep 2;;
            4) nl $D_ZIVPN; read -p "No: " n; [[ -z "$n" ]] && continue; line=$(sed -n "${n}p" $D_ZIVPN); IFS="|" read -r f1 f2 f3 <<< "$line"; if [[ -z "$f3" ]]; then u="unknown"; p="$f1"; exp="$f2"; else u="$f1"; p="$f2"; exp="$f3"; fi; DMN=$(cat /usr/local/etc/xray/domain); show_account_zivpn "$u" "$p" "$DMN" "$exp";;
            5) p="trial-$(tr -dc a-z0-9 </dev/urandom | head -c 5)"; echo -e " Password (Trial): ${GREEN}$p${NC}"; u="$p"; read -p " Duration (e.g., 10m, 1h): " dur;
               if [[ "$dur" == *m ]]; then add_str="+${dur%m} minutes"; elif [[ "$dur" == *h ]]; then add_str="+${dur%h} hours"; else add_str="+1 hours"; fi
               exp=$(date -d "$add_str" +"%Y-%m-%d %H:%M:%S");_tf27=$(mktemp) &&  jq --arg pwd "$p" '.auth.config += [$pwd]' /etc/zivpn/config.json > "$_tf27" && mv "$_tf27" /etc/zivpn/config.json; echo "$u|$p|$exp" >> $D_ZIVPN; DMN=$(cat /usr/local/etc/xray/domain); show_account_zivpn "$u" "$p" "$DMN" "$exp"
               ;;
            x) return;;
        esac; done
}

while true; do header_main
    echo -e "${CYAN}┌──────────────────────────────────────────────────────┐${NC}"
    print_line " [1] SSH ACCOUNT          [4] BOT TELEGRAM SETUP"
    print_line " [2] X-RAY MANAGER        [5] FEATURES"
    print_line " [3] ZIVPN UDP            [x] EXIT"
    echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
    read -p " Select Menu : " opt
    case $opt in
        1) ssh_menu ;;
        2) xray_manager_menu ;;
        3) zivpn_menu ;;
        4) bot_menu ;;
        5) features_menu ;;
        x) exit ;;
    esac; done
END_MENU
chmod +x /usr/bin/menu
) >/dev/null 2>&1 & install_spin
print_ok "Finalisasi Script"

echo -e "\n${GREEN}=================================================${NC}"
echo -e "${YELLOW}   Instalasi Selesai! Ketik: ${WHITE}menu${YELLOW} untuk mulai  ${NC}"
echo -e "${GREEN}=================================================${NC}\n"
