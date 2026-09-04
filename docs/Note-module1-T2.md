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

### 5. SSH Hardening

Zmodyfikowano parametr SSH:

1.

MaxAuthTries 3

Dlaczego:

- ograniczenie liczby nieudanych prób logowania
- utrudnienie ataków brute-force
- szybsze zrywanie niepoprawnych sesji uwierzytelnienia

Wdrożenie:

Ansible → role ssh

Weryfikacja:

sudo grep MaxAuthTries /etc/ssh/sshd_config

Efekt:

Po trzech nieudanych próbach logowania połączenie SSH zostaje zamknięte przez serwer.

1.

- ClientAliveInterval 120 - co 120 sekund serwer sprawdza, czy klient SSH nadal odpowiada.
- ClientAliveCountMax 2 - po dwóch nieudanych odpowiedziach klient jest rozłączany.

Dzięki temu redukujemy ryzyko nagromadzenia nieaktywnych sesji SSH.

### 6. Instalacja UFW (Uncomplicated Firewall)

Wdrożono lokalny firewall systemowy UFW za pomocą Ansible.

Weryfikacja:

```bash
sudo ufw status verbose
```

### 7. Aliasy

Wytworzyłem aliasy w WSL komendą *nano ~/.bashrc*

```bash
# Aliases
alias vm1='gcloud compute ssh platform-admin-01 --zone=europe-central2-a --tunnel-through-iap'
alias vm2='gcloud compute ssh monitoring-01 --zone=europe-central2-a --tunnel-through-iap'
alias vm3='gcloud compute ssh k8s-master-01 --zone=europe-central2-a --tunnel-through-iap'
alias iap='gcloud compute start-iap-tunnel platform-admin-01 22 --local-host-port=localhost:2222 --zone=europe-central2-a'
```

### 8. Weryfikacja parametrów sysctl (network hardening)

Zweryfikowano podstawowe parametry jądra odpowiedzialne za bezpieczeństwo sieciowe.

Sprawdzone ustawienia:

net.ipv4.ip_forward
net.ipv4.conf.all.accept_redirects
net.ipv4.conf.default.accept_redirects
net.ipv4.conf.all.send_redirects
net.ipv4.conf.default.send_redirects
net.ipv4.conf.all.accept_source_route
net.ipv4.conf.default.accept_source_route

Wynik:

ip_forward = 0

accept_redirects = 0
send_redirects = 0

accept_source_route = 0

Dlaczego:

- VM nie pełni roli routera
- ograniczenie możliwości manipulacji trasowaniem pakietów
- zgodność z dobrymi praktykami hardeningu oraz CIS-lite

Wniosek:

Nie były wymagane dodatkowe zmiany konfiguracji. Domyślne ustawienia Debian 12 są zgodne z oczekiwanym poziomem bezpieczeństwa dla platform-admin-01.

### 9. Utworzenie Auditd

**Cel:**

Rejestrowanie zmian w krytycznych elementach systemu. Np.:

- Kto usunął plik?
- Kto dodał użytkownika?
- Kto zmienił sudoers?
- Kto próbował użyć sudo?

**Dlaczego?**

Umożliwia określenie:

- kto wykonał zmianę
- kiedy została wykonana
- jaki plik został zmodyfikowany

**Monitorowane obszary:**

- /etc/passwd  - tworzenie/usuwanie użytkowników
- /etc/group   - uprawnienia grup
- /etc/shadow  - hasła
- /etc/sudoers - eskalacja uprawnień
- /etc/ssh/sshd_config - dostęp do systemu

**Konfiguracja i testy Auditd**

Wdrożono usługę auditd odpowiedzialną za rejestrowanie operacji wykonywanych na kluczowych elementach systemu.

Skonfigurowane reguły:

- /etc/passwd
- /etc/group
- /etc/shadow
- /etc/sudoers
- /etc/ssh/sshd_config

Klucze audytu:

- identity
- privilege
- ssh

Weryfikacja:

sudo auditctl -l

Testy:

1. Modyfikacja pliku sshd_config
2. Modyfikacja pliku passwd
3. Utworzenie użytkownika testowego
4. Usunięcie użytkownika testowego

Analiza zdarzeń:

sudo ausearch -k ssh

sudo ausearch -k identity

Wynik:

Auditd poprawnie rejestruje zmiany wykonywane na krytycznych plikach systemowych oraz operacje związane z zarządzaniem użytkownikami.

Status usługi:

sudo systemctl status auditd

Wynik:

auditd.service - active (running)

Korzyści:

- możliwość śledzenia zmian administracyjnych
- wsparcie procesu analizy incydentów bezpieczeństwa
- identyfikacja nieautoryzowanych zmian konfiguracji
- podstawa dla przyszłego monitoringu i alertowania
