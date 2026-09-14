# Notatki do modułu 1 - T3

<https://github.com/TheLukass1997/devops-advanced-blackbox/tree/main/modules/m1-cloud-linux>

## Zarys

Na potrzeby tego zadania, została utworozna nowa wirtualna maszyna przeznaczona tylko do monitoringu. Jej parametry i głębszy opis są zawarte w dokumentacji BASELINE.md. Na utworzonej VM został otwarty port 3000 w celu konfiguracji Grafany, a bezpośrednio w Grafanie został skonfigurowany Prometheus wraz z trzema alertami, które zostały opisane poniżej.

## Architektura

platform-admin-01
└── node_exporter :9100

monitoring-01
├── prometheus :9090
└── grafana :3000

## Alerty

Wszystkie 3 alerty zostały ustawione w Grafanie.

### 1. Host Down

```bash
up{job="platform-admin-01"} < 1
```

### 2. High CPU

```bash
100 - (avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

Alert uruchamia się po przekroczeniu progu użycia 80%.

### 3. High Memory

```bash
100 * (
1 - (
node_memory_MemAvailable_bytes /
node_memory_MemTotal_bytes
))
```

Alert uruchamia się po przekroczeniu 90% zużycia pamięci.
