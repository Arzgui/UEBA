# UEBA + OpenSearch - Proof of Concept

Ce projet démontre une stack complète d’analyse comportementale (UEBA) utilisant OpenSearch pour l’ingestion de logs, la détection, l’alerte et la visualisation.

---

## Architecture

- **Ingestion** : Fluent Bit collecte les logs et les envoie à Data Prepper via HTTP.
- **Data Prepper** : Route et transforme les logs vers OpenSearch.
- **OpenSearch** : Indexe les données dans l’index `ueba-events`.
- **Alerting** : Des monitors détectent les patterns suspects et déclenchent des alertes.
- **Notifications** : Les alertes sont envoyées via un channel webhook unique (voir `channels/webhook-ueba.json`).
- **Dashboard** : OpenSearch Dashboards permet de superviser en temps réel les détections et alertes.

---

## Structure du projet

UEBA/
├── channels/
│ └── webhook-ueba.json
├── dashboard/
│ └── export.ndjson
├── data-prepper/
│ └── pipelines/
│ └── pipelines.yaml
├── fluent-bit/
│ └── inject_logs.sh
│ └── simulateur_injection.sh
├── monitors/
│ ├── monitor_bruteforce.json
│ ├── monitor_powershell.json
│ ├── monitor_priv_escalation.json
│ ├── monitor_process_suspect.json
│ └── setup_alerting.sh
├── .env
├── .gitignore
└── docker-compose.yml


---

## Installation et utilisation

1. **Lancer l’infrastructure**

   Configure et démarre tout avec `docker-compose up` (si fourni), sinon suis les instructions d’installation pour chaque composant.

2. **Configurer le pipeline**

   - Data Prepper (`data-prepper/pipelines/pipelines.yaml`)
   - Fluent Bit (`fluent-bit/`)

3. **Déployer les monitors et le channel d’alerting**

   - Modifie ou utilise `monitors/setup_alerting.sh` pour créer les monitors dans OpenSearch, en indiquant l’ID du channel Webhook unique (`channels/webhook-ueba.json`).

4. **Injection de logs de test**

   - Utilise `inject_logs.sh` pour tester l’injection de différents types de logs.
   - Utilise `simulateur_injection.sh` pour simuler une charge continue de logs.

5. **Supervision et visualisation**

   - Va dans OpenSearch Dashboards et importe le dashboard `dashboard/export.ndjson` via Stack Management > Saved Objects > Import.

---

## Fonctionnalités principales

- Détection brute force (SSH)
- Détection de commandes PowerShell suspectes
- Détection d’élévation de privilèges
- Détection de processus suspects
- Alertes automatiques et notifications webhook
- Dashboard interactif pour le suivi des détections et alertes

---

## Export/Import du Dashboard

- Pour exporter : Menu Saved Objects > Export.
- Pour importer : Menu Saved Objects > Import (`dashboard/export.ndjson`).

---

## Idées pour aller plus loin

- Ajouter de nouveaux scénarios de détection (ransomware, exfiltration…)
- Brancher le webhook vers un SIEM, Slack, Teams, etc.
- Automatiser l’injection de logs pour un monitoring continu
- Personnaliser les visualisations

---

## Auteur et contact

Projet réalisé par Abdelkarim REZGUI.  


