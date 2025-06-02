# UEBA + OpenSearch - Proof of Concept

**Une stack complète d'analyse comportementale (User and Entity Behavior Analytics) utilisant OpenSearch pour l'ingestion de logs, la détection d'anomalies, l'alerte et la visualisation en temps réel.**

---

## Architecture

```
Logs → Fluent Bit → Data Prepper → OpenSearch → Alerting → Notifications
                                        ↓
                                   Dashboards
```

- **Ingestion** : Fluent Bit collecte les logs et les envoie à Data Prepper via HTTP
- **Data Prepper** : Route et transforme les logs vers OpenSearch
- **OpenSearch** : Indexe les données dans l'index `ueba-events`
- **Alerting** : Des monitors détectent les patterns suspects et déclenchent des alertes
- **Notifications** : Les alertes sont envoyées via un channel webhook unique
- **Dashboard** : OpenSearch Dashboards permet de superviser en temps réel les détections et alertes

---

## Structure du projet

```
UEBA/
├── channels/
│   └── webhook-ueba.json           # Configuration du channel webhook
├── dashboard/
│   └── export.ndjson               # Export du dashboard OpenSearch
├── data-prepper/
│   └── pipelines/
│       └── pipelines.yaml          # Configuration des pipelines Data Prepper
├── fluent-bit/
│   ├── inject_logs.sh              # Script d'injection de logs de test
│   └── simulateur_injection.sh     # Simulateur de charge continue
├── monitors/
│   ├── monitor_bruteforce.json     # Détection d'attaques par brute force
│   ├── monitor_powershell.json     # Détection de commandes PowerShell suspectes
│   ├── monitor_priv_escalation.json # Détection d'élévation de privilèges
│   ├── monitor_process_suspect.json # Détection de processus suspects
│   └── setup_alerting.sh           # Script de déploiement des monitors
├── .env                            # Variables d'environnement
├── .gitignore
└── docker-compose.yml              # Configuration Docker
```

---

## Installation et utilisation

### 1. Lancer l'infrastructure

```bash
# Cloner le repository
git clone <repo-url>
cd UEBA

# Démarrer l'infrastructure
docker-compose up -d
```

### 2. Configurer le pipeline

Vérifiez et adaptez les configurations selon vos besoins :
- **Data Prepper** : `data-prepper/pipelines/pipelines.yaml`
- **Fluent Bit** : fichiers dans le dossier `fluent-bit/`

### 3. Déployer les monitors et le channel d'alerting

```bash
# Déployer automatiquement tous les monitors
cd monitors/
chmod +x setup_alerting.sh
./setup_alerting.sh
```

### 4. Injection de logs de test

```bash
# Injection ponctuelle de logs de test
cd fluent-bit/
chmod +x inject_logs.sh
./inject_logs.sh

# Simulation de charge continue
chmod +x simulateur_injection.sh
./simulateur_injection.sh
```

### 5. Supervision et visualisation

1. Accédez à OpenSearch Dashboards (généralement http://localhost:5601)
2. Allez dans **Stack Management** > **Saved Objects** > **Import**
3. Importez le fichier `dashboard/export.ndjson`

---

## Fonctionnalités principales

### Détections implémentées

- **Brute Force SSH** : Détection d'attaques par dictionnaire sur SSH
- **PowerShell suspect** : Analyse des commandes PowerShell potentiellement malveillantes
- **⬆Élévation de privilèges** : Détection des tentatives d'escalade de privilèges
- **Processus suspects** : Identification de processus anormaux ou malveillants

### Capacités système

- **Alertes automatiques** avec notifications webhook
- **Dashboard interactif** pour le suivi en temps réel
- **Ingestion haute performance** via Fluent Bit et Data Prepper
- **Extensibilité** pour ajouter de nouveaux scénarios de détection

---

## Export/Import du Dashboard

### Export
1. Dans OpenSearch Dashboards : **Stack Management** > **Saved Objects**
2. Sélectionnez les objets à exporter
3. Cliquez sur **Export**

### Import
1. **Stack Management** > **Saved Objects** > **Import**
2. Sélectionnez le fichier `dashboard/export.ndjson`
3. Cliquez sur **Import**

---

## Idées pour aller plus loin

### Nouvelles détections
- **Ransomware** : Détection de comportements de chiffrement suspect
- **Exfiltration** : Analyse des transferts de données anormaux
- **Lateral Movement** : Détection de mouvements latéraux dans le réseau
- **Reconnaissance** : Identification des phases de reconnaissance

### Intégrations
- **SIEM** : Connecter les alertes à votre SIEM existant
- **Slack/Teams** : Notifications directes dans vos canaux de communication
- **Email** : Alertes par email pour les incidents critiques
- **PagerDuty** : Escalade automatique des incidents

### Automatisation
- **Monitoring continu** : Injection automatisée de logs pour tests
- **CI/CD** : Intégration dans vos pipelines de déploiement
- **Response automatique** : Actions automatiques en cas de détection

### Visualisations
- **Métriques personnalisées** : KPIs spécifiques à votre environnement
- **Thèmes personnalisés** : Adaptation de l'interface à votre charte graphique
- **Rapports automatiques** : Génération de rapports périodiques

---

## Prérequis

- **Docker** et **Docker Compose**
- **OpenSearch** 2.x+
- **Fluent Bit** 1.9+
- **Data Prepper** 2.x+

---

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
- Proposer de nouvelles détections
- Améliorer les dashboards existants
- Signaler des bugs ou problèmes
- Suggérer des améliorations


## Auteur et contact
Abdelkarim REZGUI

---

**Tip** : Pour une meilleure expérience, consultez la documentation officielle d'[OpenSearch](https://opensearch.org/docs/) et de [Fluent Bit](https://docs.fluentbit.io/)
