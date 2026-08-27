**Notatki do modułu 1:**

- GCP docelowo ma wszystkie serwisy wyłączone. Nim zacznie się wdrażanie czegokolwiek, należy je podpiąć, przykładowo tak jak poniżej:

```powershell
gcloud services enable `
  compute.googleapis.com `
  iam.googleapis.com `
  iamcredentials.googleapis.com `
  cloudresourcemanager.googleapis.com `
  sts.googleapis.com `
  serviceusage.googleapis.com
```


- sprawdzenie aktywnego projektu w GCP:

```powershell
gcloud config get-value project
```

