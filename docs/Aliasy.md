# Rozpiska wszystkich aliasów, które wytworzyłem w WSL komendą *nano ~/.bashrc* (po każdym dodaniu aliasa należy użyć komendy *source ~/.bashrc* )

```bash
# Aliases
alias vm1='gcloud compute ssh platform-admin-01 --zone=europe-central2-a --tunnel-through-iap'
alias vm1-stop='gcloud compute instances stop platform-admin-01 --zone=europe-central2-a'
alias vm1-start='gcloud compute instances start platform-admin-01 --zone=europe-central2-a'
alias vm2='gcloud compute ssh monitoring-01 --zone=europe-central2-a --tunnel-through-iap'
alias vm3='gcloud compute ssh k8s-master-01 --zone=europe-central2-a --tunnel-through-iap'
alias iap='gcloud compute start-iap-tunnel platform-admin-01 22 --local-host-port=localhost:2222 --zone=europe-central2-a'
alias hardening='cd ~/projects/gcp-platform-lab/ansible && ansible-playbook playbooks/hardening.yml'
```
