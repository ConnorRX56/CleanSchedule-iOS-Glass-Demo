"""Package an unsigned ARM64 device build for the owner's local signing tool."""
import hashlib
import json
import plistlib
import sys
import zipfile
from pathlib import Path

app = Path(sys.argv[1]).resolve()
destination = Path(sys.argv[2]).resolve()
if not app.is_dir() or app.suffix != '.app':
    raise SystemExit('Expected an iPhone device .app directory')
info = plistlib.loads((app / 'Info.plist').read_bytes())
if info.get('CFBundleSupportedPlatforms') != ['iPhoneOS']:
    raise SystemExit('Refusing to package a simulator build as an installable device IPA')
executable = app / info['CFBundleExecutable']
if not executable.is_file() or executable.stat().st_size < 4096:
    raise SystemExit('Device executable is missing')
if (app / 'embedded.mobileprovision').exists():
    raise SystemExit('Demo cloud build must not contain an account provisioning profile')
destination.parent.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(destination, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
    for file in sorted(app.rglob('*')):
        if file.is_file():
            archive.write(file, 'Payload/' + app.name + '/' + file.relative_to(app).as_posix())
with zipfile.ZipFile(destination) as archive:
    bad = archive.testzip()
    if bad:
        raise SystemExit('Archive integrity failed: ' + bad)
manifest = {
    'file': destination.name,
    'bundle_id': info['CFBundleIdentifier'],
    'version': info['CFBundleShortVersionString'],
    'build': info['CFBundleVersion'],
    'minimum_ios': info['MinimumOSVersion'],
    'supported_platforms': info['CFBundleSupportedPlatforms'],
    'signed': False,
    'installation': 'Sign locally with the owner Apple account before installation.',
    'bytes': destination.stat().st_size,
    'sha256': hashlib.sha256(destination.read_bytes()).hexdigest(),
}
destination.with_suffix('.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
print(json.dumps(manifest, indent=2))
