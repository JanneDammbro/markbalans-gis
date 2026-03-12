import yaml
from pathlib import Path

def load_config():
    cfg_path = Path("C:/Markbalans/config/config.yaml")
    with open(cfg_path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

if __name__ == "__main__":
    cfg = load_config()
    print("Projekt:", cfg["project"]["default"])
    print("Incoming:", cfg["paths"]["incoming"])