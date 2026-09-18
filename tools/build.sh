#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build dist

export HOMEBREW_NO_AUTO_UPDATE=1
if ! command -v xcodegen >/dev/null 2>&1; then
  brew install xcodegen
fi
swift tools/make_icon.swift Assets.xcassets/AppIcon.appiconset/AppIcon.png
xcodegen generate --spec project.yml
xcodebuild -version | tee dist/xcode-version.txt

args=(-project CleanScheduleGlass.xcodeproj -scheme CleanScheduleGlass
      -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
      "CURRENT_PROJECT_VERSION=${GITHUB_RUN_NUMBER:-1}")

# No account, certificate, password, or signing service is used by the cloud job.
xcodebuild "${args[@]}" -configuration Release -sdk iphoneos \
  -destination 'generic/platform=iOS' build 2>&1 | tee dist/device-build.log
python3 tools/package_ipa.py build/DerivedData/Build/Products/Release-iphoneos/CleanScheduleGlass.app \
  dist/CleanSchedule-Glass-Demo-0.1.0-unsigned.ipa

simulator_id="$(python3 tools/choose_simulator.py)"
printf '%s\n' "$simulator_id" > dist/simulator-id.txt
xcrun simctl boot "$simulator_id" 2>/dev/null || true
xcrun simctl bootstatus "$simulator_id" -b
xcodebuild "${args[@]}" -configuration Debug \
  -destination "platform=iOS Simulator,id=$simulator_id" \
  -parallel-testing-enabled NO -maximum-concurrent-test-simulator-destinations 1 \
  -resultBundlePath build/Tests.xcresult test 2>&1 | tee dist/test.log
xcrun xcresulttool get test-results summary --path build/Tests.xcresult --compact > dist/test-summary.json
xcrun simctl shutdown "$simulator_id"
