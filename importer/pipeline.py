from pathlib import Path
from config_loader import load_config
from archive_service import archive_file

def run_pipeline():
    cfg = load_config()
    incoming = Path(cfg["paths"]["incoming"])
    archive = Path(cfg["paths"]["archive"])

    files = [f for f in incoming.iterdir() if f.is_file()]

    if not files:
        print("Ingen fil att importera.")
        return

    for f in files:
        dest = archive_file(f, archive)
        print(f"Arkiverad: {f.name} -> {dest}")