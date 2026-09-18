import json
import re
import subprocess

data = json.loads(subprocess.check_output(['xcrun', 'simctl', 'list', 'devices', 'available', '--json']))
candidates = []
for runtime, devices in data['devices'].items():
    match = re.search(r'iOS-(\d+)(?:-(\d+))?', runtime)
    if not match or int(match[1]) < 26:
        continue
    for device in devices:
        if device.get('isAvailable') and 'iPhone' in device['name']:
            candidates.append(((int(match[1]), int(match[2] or 0), 'Pro' in device['name']), device['udid']))
if not candidates:
    raise SystemExit('No installed iPhone simulator with iOS 26 or newer. No runtime download was started.')
print(max(candidates)[1])
