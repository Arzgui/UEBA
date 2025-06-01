set -e

OPENSEARCH_URL="http://localhost:9200"
ALERTING_API="$OPENSEARCH_URL/_plugins/_alerting"
CHANNEL_ID="VcduLJcB_WPuNZx3lk_6"
USER="admin"
PASS="admin"

# Brute Force Generic
cat > monitor_bruteforce.json <<EOF
{
  "type": "monitor",
  "name": "Brute Force Generic",
  "enabled": true,
  "schedule": { "period": { "interval": 1, "unit": "MINUTES" } },
  "inputs": [{
    "search": {
      "indices": ["ueba-events"],
      "query": {
        "size": 0,
        "query": {
          "bool": {
            "must": [
              { "match_phrase": { "log": "failed to log on" } },
              { "range": { "@timestamp": { "gte": "now-5m", "lte": "now" } } }
            ]
          }
        }
      }
    }
  }],
  "triggers": [{
    "name": "TooManyFailedLogins",
    "severity": "HIGH",
    "condition": {
      "script": {
        "source": "ctx.results[0].hits.total.value > 5",
        "lang": "painless"
      }
    },
    "actions": [{
      "name": "NotifyOnBruteForce",
      "destination_id": "$CHANNEL_ID",
      "subject_template": { "source": "ALERTE [Brute Force] (Criticité: HIGH)" },
      "message_template": { "source": "Plus de 5 échecs de login dans les 5 dernières minutes. Détails: {{ctx.results.0.hits.total.value}} tentatives détectées." }
    }]
  }]
}
EOF

# PowerShell
cat > monitor_powershell.json <<EOF
{
  "type": "monitor",
  "name": "Detect Suspicious PowerShell Command",
  "enabled": true,
  "schedule": { "period": { "interval": 1, "unit": "MINUTES" } },
  "inputs": [{
    "search": {
      "indices": ["ueba-events"],
      "query": {
        "size": 1,
        "query": {
          "bool": {
            "must": [
              { "match_phrase": { "tags": "mitre_powershell" } }
            ],
            "filter": [
              { "range": { "@timestamp": { "gte": "now-2m" } } }
            ]
          }
        }
      }
    }
  }],
  "triggers": [{
    "name": "PowerShell Suspicious Trigger",
    "severity": "HIGH",
    "condition": {
      "script": {
        "source": "ctx.results[0].hits.total.value > 0",
        "lang": "painless"
      }
    },
    "actions": [{
      "name": "Send webhook alert",
      "destination_id": "$CHANNEL_ID",
      "subject_template": { "source": "ALERTE [PowerShell] (Criticité: HIGH)" },
      "message_template": { "source": "Suspicious PowerShell command detected!\\nCommand: {{ctx.results.0.hits.hits.0._source.ps_command}}\\nUser: {{ctx.results.0.hits.hits.0._source.user}}\\nTimestamp: {{ctx.results.0.hits.hits.0._source.@timestamp}}" }
    }]
  }]
}
EOF

# Privilege Escalation
cat > monitor_priv_escalation.json <<EOF
{
  "type": "monitor",
  "name": "Privilege Escalation Detection",
  "enabled": true,
  "schedule": { "period": { "interval": 1, "unit": "MINUTES" } },
  "inputs": [{
    "search": {
      "indices": ["ueba-events"],
      "query": {
        "size": 1,
        "query": {
          "bool": {
            "must": [
              { "match_phrase": { "tags": "mitre_privilege_escalation" } }
            ],
            "filter": [
              { "range": { "@timestamp": { "gte": "now-5m" } } }
            ]
          }
        }
      }
    }
  }],
  "triggers": [{
    "name": "PrivilegeEscalationDetected",
    "severity": "HIGH",
    "condition": {
      "script": {
        "source": "ctx.results[0].hits.total.value > 0",
        "lang": "painless"
      }
    },
    "actions": [{
      "name": "NotifyOnPrivilegeEscalation",
      "destination_id": "$CHANNEL_ID",
      "subject_template": { "source": "ALERTE [Privilege Escalation] (Criticité: HIGH)" },
      "message_template": { "source": "ALERTE : Élèvation de privilèges détectée ! Utilisateur : {{ctx.results.0.hits.hits.0._source.user}} Commande : {{ctx.results.0.hits.hits.0._source.command}}" }
    }]
  }]
}
EOF

# Suspicious Process
cat > monitor_process_suspect.json <<EOF
{
  "type": "monitor",
  "name": "Suspicious Process Detection",
  "enabled": true,
  "schedule": { "period": { "interval": 1, "unit": "MINUTES" } },
  "inputs": [{
    "search": {
      "indices": ["ueba-events"],
      "query": {
        "size": 1,
        "query": {
          "bool": {
            "must": [
              { "match_phrase": { "tags": "mitre_process_suspect" } }
            ],
            "filter": [
              { "range": { "@timestamp": { "gte": "now-5m" } } }
            ]
          }
        }
      }
    }
  }],
  "triggers": [{
    "name": "SuspiciousProcessDetected",
    "severity": "MEDIUM",
    "condition": {
      "script": {
        "source": "ctx.results[0].hits.total.value > 0",
        "lang": "painless"
      }
    },
    "actions": [{
      "name": "NotifyOnProcessSuspect",
      "destination_id": "$CHANNEL_ID",
      "subject_template": { "source": "ALERTE [Process Suspect] (Criticité: MEDIUM)" },
      "message_template": { "source": "ALERTE : Processus suspect détecté ! Process : {{ctx.results.0.hits.hits.0._source.new_process}} Commande : {{ctx.results.0.hits.hits.0._source.command}}" }
    }]
  }]
}
EOF

# Envoi des monitors
for f in monitor_*.json; do
  echo "Envoi $f"
  curl -u $USER:$PASS -XPOST "$ALERTING_API/monitors" -H 'Content-Type: application/json' -d @"$f"
done

echo "Monitors créés avec le bon channel !"
