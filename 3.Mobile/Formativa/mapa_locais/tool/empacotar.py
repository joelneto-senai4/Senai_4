"""Cria o ZIP dos fontes, sem caches nem configuração de SDK da máquina."""
from pathlib import Path
import os
import zipfile

root = Path(__file__).resolve().parents[1]
output = root.parent / 'Perto-projeto.zip'
skip_dirs = {'.dart_tool', '.git', '.gradle', '.idea', '.kotlin', 'build'}
skip_files = {'local.properties', '.flutter-plugins', '.flutter-plugins-dependencies'}

with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as archive:
    for folder, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in skip_dirs]
        for name in sorted(files):
            if name in skip_files or name.endswith(('.iml', '.log', '.pyc')):
                continue
            file = Path(folder) / name
            archive.write(file, Path('mapa_locais') / file.relative_to(root))

with zipfile.ZipFile(output) as archive:
    assert archive.testzip() is None
    print(f'{output.name}: {len(archive.namelist())} arquivos; CRC OK')
