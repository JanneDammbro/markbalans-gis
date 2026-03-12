import shutil
from datetime import datetime
from pathlib import Path

def archive_file(src, archive_root):
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    dest = Path(archive_root) / f"{ts}_{src.name}"
    Path(archive_root).mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dest)
    return dest