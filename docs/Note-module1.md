# Notatki do modułu 1

### 1. Włączenie wymaganych serwisów GCP

GCP docelowo ma wszystkie serwisy wyłączone. Nim zacznie się wdrażanie czegokolwiek, należy je podpiąć, przykładowo tak jak poniżej:

```powershell
gcloud services enable `
  compute.googleapis.com `
  iam.googleapis.com `
  iamcredentials.googleapis.com `
  cloudresourcemanager.googleapis.com `
  sts.googleapis.com `
  serviceusage.googleapis.com
```

### 2. Sprawdzenie aktywnego projektu w GCP

```powershell
gcloud config get-value project
```

### 3. Utworzenie bucketu

```powershell
gcloud storage buckets create `
  gs://tfstate-lbobak-gcp-platform-lab-dev `
  --location=europe-central2 `
  --uniform-bucket-level-access
```

### 4. Włączenie versioningu i weryfikacja konfiguracji

Włączenie versioningu:

```powershell
gcloud storage buckets update `
  gs://tfstate-lbobak-gcp-platform-lab-dev `
  --versioning
```

Weryfikacja konfiguracji:

```powershell
gcloud storage buckets describe `
  gs://tfstate-lbobak-gcp-platform-lab-dev
```

Gdy versioning jest włączony, widoczny będzie wpis:

```text
versioning_enabled: true
```

Jest to ważne, ponieważ jeśli `terraform apply` uszkodzi plik state lub ktoś go nadpisze, GCS przechowuje starsze wersje obiektu. Dzięki temu możliwe jest odzyskanie wcześniejszej wersji stanu Terraform. W praktyce stanowi to mechanizm backupu dla Terraform State.

```text
Po wykonaniu powyższych kroków skonfigurowane będą:

- Projekt GCP
- Billing
- Terraform State Bucket
- Versioning
- Uniform Access
```

### 5. Konfiguracja pierwszych plików Terraform-owych

- Pliki są widoczne w:

```text
infra/environments/dev/<plik>.tf

oraz

infra/modules/service_accounts/<plik>.tf
```

- Przechodzimy do pierwszego 'Apply' wedle wzorca: terraform fmt -recursive → terraform validate → terraform plan → terraform apply

- CO ZOSTANIE UTWORZONE?

1. Potrzebne API (Terraform, IAM, Workload Identity Federation, VM, VPC, Cloud NAT) - czyli interfejs do zarządzania usługą GCP
1. Service Account dla Terraform (terraform-sa). Powstanie: terraform-sa@lbobak-gcp-platform-lab-dev.iam.gserviceaccount.com to będzie konto używane później przez: GitHub Actions → OIDC → terraform-sa → GCP. - To konto, którego używa Terraform do tworzenia zasobów w GCP. Terraform nie powinien działać na Twoim koncie osobistym. Zamiast tego używa dedykowanego Service Account i otrzymuje odpowiednie role (Compute Admin, Network Admin, Service Account Admin)
1. Service Account dla VM (vm-platform-sa). - To konto przypisywane do maszyny wirtualnej. Zamiast trzymać hasła w aplikacji, VM "dziedziczy" uprawnienia przypisane w Service Account.
```text
Service Account to techniczne konto używane przez aplikacje, Terraform, VM, Cloud Run i inne usługi GCP do uwierzytelniania i wykonywania operacji zgodnie z przypisanymi uprawnieniami IAM. 
- terraform-sa zarządza infrastrukturą 
- vm-platform-sa jest używane przez maszyny wirtualne do wykonywania swoich zadań.
```

### 6. Konfiguracja sieci

Od sieci wszystkie dalsze komponenty będą zależeć, dlatego od niej zaczynam.

VM → Subnet

Firewall → VPC

Kubernetes → VPC

Monitoring → VPC

Zostało utworzone:
network_name = "platform-vpc"
project_id = "lbobak-gcp-platform-lab-dev"
region = "europe-central2"
subnet_name = "platform-subnet"

### 7. Konfiguracja routera

Router jest fundamentem pod NAT. 

platform-vpc -> platform-router -> platform-nat -> private vm

router_name = "platform-router"
subnet_name = "platform-subnet"

```text
Po tych krokach 7 punktach jest już utworzone:
✅ APIs
✅ Service Accounts
✅ VPC
✅ Subnet
✅ Cloud Router
```

### 8. Konfiguracja NAT

platform-vpc -> platform-subnet -> platform-router -> platform-nat -> Internet

Dzięki NAT późniejsza VM będzie mogła działać bez publicznego IP.

