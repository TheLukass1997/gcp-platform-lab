
---

# Maszyna

## Typ instancji

Komenda:

```bash
hostnamectl
free -h
lsblk
```

Wynik:

- Google Compute Engine
- 3.8 GiB RAM
- Dysk 30 GB
- Wirtualizacja: Google

Wnioski:

Maszyna administracyjna o niewielkim rozmiarze, wystarczająca do nauki, hardeningu i zarządzania środowiskiem.

---

## Dystrybucja

Komenda:

```bash
cat /etc/os-release
```

Wynik:

Debian GNU/Linux 12 (bookworm)

Wnioski:

Aktualna wersja LTS Debiana.

---

## Kernel

Komenda:

```bash
uname -r
```

Wynik:

```text
6.1.0-52-cloud-amd64
```

Wnioski:

Kernel zoptymalizowany pod środowiska chmurowe.

---

## Systemd

Komenda:

```bash
systemctl --version
```

Wynik:

```text
systemd 252
```

Wnioski:

Nowoczesna wersja systemd z obsługą cgroups v2.

---

## Układ partycji

Komendy:

```bash
lsblk
df -h
```

Wynik:

```text
/           30G
/boot/efi  124M
```

Partycje:

```text
sda1   29.9G   /
sda15  124M    /boot/efi
```

Wnioski:

- Prosty układ partycji.
- Brak wydzielonego /var.
- Dla małej VM administracyjnej wystarczające.

---

# Obciążenie w spoczynku

## Load Average

Komenda:

```bash
uptime
```

Wynik:

```text
0.00 0.00 0.00
```

Wnioski:

Maszyna w stanie całkowitego spoczynku.

---

## Liczba procesów

Komenda:

```bash
ps -ef | wc -l
```

Wynik:

```text
90
```

---

## Liczba wątków

Komenda:

```bash
ps -eLf | wc -l
```

Wynik:

```text
133
```

---

## Procesy zużywające CPU

Komenda:

```bash
ps aux --sort=-%cpu | head -10
```

Wynik:

Najwyższe chwilowe użycie CPU:

```text
systemd-hostnamed
```

Pozostałe procesy praktycznie nie obciążają CPU.

Wnioski:

Brak procesów generujących znaczące obciążenie.

---

# Pamięć

## Zużycie pamięci

Komenda:

```bash
free -h
```

Wynik:

```text
RAM całkowity: 3.8 GiB
RAM użyty:     445 MiB
RAM wolny:     3.3 GiB
Available:     3.4 GiB
```

Wnioski:

Maszyna wykorzystuje około 12% pamięci RAM.

---

## Dlaczego free "kłamie"

Linux wykorzystuje wolną pamięć jako cache.

Najważniejszą wartością jest:

```text
available
```

a nie:

```text
free
```

Obecnie:

```text
available = 3.4 GiB
```

co oznacza bardzo duży zapas pamięci.

---

## Swap

Komendy:

```bash
swapon --show
free -h
```

Wynik:

```text
Swap: 0B
```

Wnioski:

Swap nie jest skonfigurowany.

---

## Swappiness

Komenda:

```bash
sudo sysctl vm.swappiness
```

Wynik:

```text
vm.swappiness = 60
```

Wnioski:

Domyślna wartość Debiana.

---

# Dysk

## Zajętość partycji

Komenda:

```bash
df -h
```

Wynik:

```text
/          30G  2.6G  26G  10%
/boot/efi 124M   12M 112M  10%
```

Wnioski:

Duży zapas miejsca.

---

## Zajętość inode

Komenda:

```bash
df -i
```

Wynik:

```text
/  7% wykorzystania inode
```

Wnioski:

Brak ryzyka wyczerpania inode.

---

## Potencjalne źródła przyrostu danych

- journald
- auditd
- logi systemowe
- aktualizacje pakietów

---

# Sieć

## Otwarte porty

Komenda:

```bash
ss -tulpn
```

Wynik:

```text
22/tcp     ssh
25/tcp     exim4 (localhost)
53/tcp     systemd-resolved
53/udp     systemd-resolved
5355/tcp   LLMNR
5355/udp   LLMNR
```

Wnioski:

Jedyną publicznie nasłuchującą usługą administracyjną jest SSH.

---

## DNS

Komenda:

```bash
resolvectl status
```

Wynik:

```text
DNS Server:
169.254.169.254
```

Wnioski:

Maszyna korzysta z metadata DNS Google Cloud.

---

## MTU

Komenda:

```bash
ip link
```

Wynik:

```text
ens4 mtu 1460
```

Wnioski:

Standardowa wartość dla Google Cloud.

---

# Usługi

## Uruchomione usługi

Komenda:

```bash
systemctl list-units --type=service --state=running
```

Najważniejsze:

```text
auditd
cron
dbus
google-osconfig-agent
google-guest-agent-manager
haveged
rsyslog
ssh
systemd-journald
systemd-networkd
systemd-resolved
systemd-timesyncd
unattended-upgrades
```

Wnioski:

Większość uruchomionych usług jest związana z działaniem systemu Debian oraz integracją z Google Cloud.
Wymaga dalszej analizy obecność usługi exim4 (MTA).

---

## Uzasadnienie najważniejszych usług

### auditd

Audyt zdarzeń bezpieczeństwa.

### ssh

Zdalny dostęp administracyjny.

### systemd-journald

Lokalne logowanie zdarzeń.

### rsyslog

Przetwarzanie logów systemowych.

### systemd-timesyncd

Synchronizacja czasu.

### unattended-upgrades

Automatyczne instalowanie aktualizacji bezpieczeństwa.

### google-osconfig-agent

Integracja zarządzania z Google Cloud.

---

# Logi

## Zajętość journald

Komenda:

```bash
journalctl --disk-usage
```

Wynik:

```text
27.9 MB
```

---

## Konfiguracja journald

```ini
Storage=persistent
SystemMaxUse=500M
RuntimeMaxUse=100M
MaxRetentionSec=1month
Compress=yes
```

---

## Retencja

```text
1 miesiąc
```

---

## Maksymalny rozmiar

```text
500 MB
```

---

# Czas

## Synchronizacja

Komenda:

```bash
timedatectl status
```

Wynik:

```text
System clock synchronized: yes
NTP service: active
Time zone: UTC
```

Wnioski:

Maszyna poprawnie synchronizuje czas.

---

# Cgroups v2

## Potwierdzenie

Komenda:

```bash
mount | grep cgroup
```

Wynik:

```text
cgroup2 on /sys/fs/cgroup
```

Wnioski:

Maszyna korzysta z cgroups v2.

---

## Hierarchia procesów

Komenda:

```bash
systemd-cgls
```

Wnioski:

Procesy są zarządzane przez systemd w ramach cgroups.

---

## Największe zużycie pamięci

Komenda:

```bash
systemd-cgtop -b -n 1
```

Wynik:

```text
google-guest-agent-manager.service  ~97 MB
google-osconfig-agent.service       ~67 MB
networkd-dispatcher.service         ~26 MB
google-guest-compat-manager.service ~25 MB
```

Wnioski:

Najwięcej pamięci zużywają komponenty integrujące maszynę z Google Cloud.
