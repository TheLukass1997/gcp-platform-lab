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