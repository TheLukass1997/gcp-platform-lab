# Notatki do modułu 1 - T2

<https://github.com/TheLukass1997/devops-advanced-blackbox/tree/main/modules/m1-cloud-linux>

## 1 - Baseline systemu

Aktualny stan VM przed hardeningiem. Przydatne komendy linuxa:

```powershell
id                      # pokazuje aktualnego użytkownika oraz jego UID, GID i grupy

cat /etc/passwd | tail  # wyświetla ostatnie wpisy z listy użytkowników systemu

sudo -l                 # pokazuje jakie polecenia możesz uruchamiać przez sudo

systemctl --failed      # lista usług, które są w stanie FAILED

ss -tulpn               # pokazuje nasłuchujące porty i procesy, które ich używają

free -h                 # pokazuje wykorzystanie pamięci RAM i swap w czytelnych jednostkach

df -h                   # pokazuje zajętość systemów plików i dostępne miejsce na dyskach

sudo journalctl -p err -b   # wyświetla błędy (error) z logów bieżącego uruchomienia systemu

sudo systemctl status ssh   # sprawdza status usługi SSH (czy działa, logi, PID itp.)

curl ifconfig.me        # wyświetla publiczny adres IP, z którego VM wychodzi do Internetu
```

## 2 - Konfiguracja i hardening Linuxa

### 1. Wybór narzędzia konfiguracyjnego

Wybrano model:

Terraform → Cloud-Init → Ansible → Linux Hardening

Podział odpowiedzialności:

- Terraform odpowiada za tworzenie infrastruktury
- Cloud-Init odpowiada za bootstrap maszyny
- Ansible odpowiada za konfigurację i hardening systemu

Dlaczego:

- zachowanie zasady rozdzielenia infrastruktury od konfiguracji systemu
- łatwiejsze utrzymanie i rozwój konfiguracji
- możliwość wielokrotnego uruchamiania playbooków
- podejście zbliżone do środowisk produkcyjnych

### 2. Instalacja i przygotowanie Ansible

Ansible został uruchomiony z lokalnego środowiska WSL.

Model działania:

Control Node (WSL) → SSH → Managed Node (platform-admin-01)

Weryfikacja:

```wsl
ansible --version

    ansible-core 2.16.3
```

Dlaczego:

- Ansible nie jest instalowany na zarządzanych serwerach
- konfiguracja wykonywana jest z jednego centralnego miejsca
- zgodność z modelem używanym w GitHub Actions i środowiskach produkcyjnych

### 3. Konfiguracja środowiska Ansible Control Node

Ansible został uruchomiony z lokalnego środowiska WSL.

WSL wymaga oddzielnej konfiguracji Google Cloud CLI, ponieważ nie współdzieli sesji uwierzytelnienia z PowerShell.

Wykonane kroki:

```wsl
gcloud auth login

gcloud config set project lbobak-gcp-platform-lab-dev
```

Dlaczego:

- Ansible będzie komunikował się z infrastrukturą GCP z poziomu WSL
- wymagany jest dostęp do informacji o instancjach oraz konfiguracji środowiska
- WSL pełni rolę Control Node dla Ansible

### 4. Identyfikacja hosta zarządzanego przez Ansible

Pobrano prywatny adres IP maszyny:

platform-admin-01 → 10.10.0.2

Komenda:

```wsl
gcloud compute instances describe platform-admin-01 \
  --zone=europe-central2-a \
  --format="get(networkInterfaces[0].networkIP)"
```

Dlaczego:

- Ansible potrzebuje znać adres hosta zarządzanego
- VM znajduje się w prywatnej sieci VPC
- dalsza konfiguracja będzie wykonywana z wykorzystaniem SSH

```text
Ansible ignoruje plik `ansible.cfg`, jeżeli repozytorium znajduje się w katalogu montowanym z Windows:
```

### Ansible Connectivity

VM nie posiada publicznego IP.

Połączenie realizowane jest przez IAP Tunnel:

WSL → localhost:2222 → IAP Tunnel → platform-admin-01

Uruchomienie tunelu:

```bash
gcloud compute start-iap-tunnel platform-admin-01 22 \
  --local-host-port=localhost:2222 \
  --zone=europe-central2-a
```
