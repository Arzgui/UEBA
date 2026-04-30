# UEBA Pipeline — Détection d'anomalies comportementales sur logs Windows

> Pipeline complet d'ingestion, d'analyse et d'alerting sur événements Windows (EVTX), capable de détecter en temps réel des attaques par brute force, élévations de privilèges, commandes PowerShell suspectes et processus anormaux.

---

## Pourquoi ce projet

Les équipes sécurité manquent souvent d'un outil simple pour corréler des événements Windows et déclencher des alertes automatiques sans investir dans un SIEM commercial. Ce PoC démontre qu'une stack open source (Fluent Bit + OpenSearch) suffit pour couvrir les cas d'usage UEBA les plus critiques.

---

## Architecture

```
Logs Windows (EVTX)
        │
        ▼
   Fluent Bit          ← Collecte & forwarding HTTP
        │
        ▼
  Data Prepper         ← Routage & transformation
        │
        ▼
   OpenSearch          ← Indexation (index: ueba-events)
     │       │
     ▼       ▼
 Alerting  Dashboards  ← Monitors + visualisation temps réel
     │
     ▼
 Webhook / Notifications
```

---

## Détections implémentées

| Scénario | Fichier monitor | Ce qui est détecté |
|---|---|---|
| Brute force SSH | `monitor_bruteforce.json` | Tentatives répétées d'authentification |
| PowerShell suspect | `monitor_powershell.json` | Commandes encodées ou obfusquées |
| Élévation de privilèges | `monitor_priv_escalation.json` | Changements de tokens ou groupes |
| Processus suspects | `monitor_process_suspect.json` | Processus anormaux ou non signés |

---

## Stack technique

- **Fluent Bit** — ingestion légère et forwarding HTTP
- **Data Prepper** — pipeline de transformation des logs
- **OpenSearch 2.x** — indexation, alerting, dashboards
- **Docker Compose** — déploiement one-shot de l'infrastructure

---

## Lancer le projet

### Prérequis

- Docker & Docker Compose installés
- Ports 5601 et 9200 disponibles

### Démarrage

```bash
git clone <repo-url>
cd UEBA
docker-compose up -d
```

### Déployer les monitors d'alerting

```bash
cd monitors/
chmod +x setup_alerting.sh
./setup_alerting.sh
```

### Injecter des logs de test

```bash
cd fluent-bit/

# Injection ponctuelle
chmod +x inject_logs.sh && ./inject_logs.sh

# Simulation de charge continue
chmod +x simulateur_injection.sh && ./simulateur_injection.sh
```

### Importer le dashboard

1. Ouvrir OpenSearch Dashboards → [http://localhost:5601](http://localhost:5601)
2. **Stack Management** → **Saved Objects** → **Import**
3. Sélectionner `dashboard/export.ndjson`

---

## Structure du projet

```
UEBA/
├── channels/
│   └── webhook-ueba.json               # Channel webhook pour les alertes
├── dashboard/
│   └── export.ndjson                   # Dashboard OpenSearch (import prêt)
├── data-prepper/
│   └── pipelines/pipelines.yaml        # Pipeline de transformation
├── fluent-bit/
│   ├── inject_logs.sh                  # Injection ponctuelle de logs
│   └── simulateur_injection.sh         # Simulation de charge continue
├── monitors/
│   ├── monitor_bruteforce.json
│   ├── monitor_powershell.json
│   ├── monitor_priv_escalation.json
│   ├── monitor_process_suspect.json
│   └── setup_alerting.sh               # Déploiement automatique des monitors
├── .env
├── .gitignore
└── docker-compose.yml
```

---

## Pistes d'évolution

**Nouvelles détections** — ransomware (chiffrement suspect), exfiltration de données, lateral movement, phase de reconnaissance

**Intégrations** — Slack/Teams, PagerDuty, connexion à un SIEM existant, alertes email

**Automatisation** — réponse automatique aux incidents, intégration CI/CD, rapports périodiques

---

## Auteur

**Abdelkarim Rezgui** — [LinkedIn](https://linkedin.com) · [GitHub](https://github.com)
