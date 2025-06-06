#!/usr/bin/env python3
import os
import json
import requests
import argparse

OPENSEARCH_URL = "http://localhost:9200"
ALERTING_API = f"{OPENSEARCH_URL}/_plugins/_alerting/monitors"
USERNAME = "admin"
PASSWORD = "admin"
CHANNEL_ID = "VcduLJcB_WPuNZx3lk_6"  # À adapter si besoin

def inject_monitor(json_path):
    with open(json_path, encoding="utf-8") as f:
        monitor = json.load(f)
    # Remplace les destination_id
    for trigger in monitor.get("triggers", []):
        for action in trigger.get("actions", []):
            action["destination_id"] = CHANNEL_ID
    r = requests.post(ALERTING_API, auth=(USERNAME, PASSWORD),
                    json=monitor,
                    headers={"Content-Type": "application/json"})
    if r.ok:
        print(f"Monitor {monitor.get('name','')} créé")
    else:
        print(f"Erreur création monitor {json_path} : {r.status_code} {r.text}")

def main():
    parser = argparse.ArgumentParser(description="Créateur de monitors OpenSearch")
    parser.add_argument("--dir", default="monitors", help="Répertoire contenant les .json monitors")
    args = parser.parse_args()
    files = [f for f in os.listdir(args.dir) if f.endswith(".json")]
    if not files:
        print("Aucun monitor trouvé.")
        return
    for file in files:
        inject_monitor(os.path.join(args.dir, file))

if __name__ == "__main__":
    main()
