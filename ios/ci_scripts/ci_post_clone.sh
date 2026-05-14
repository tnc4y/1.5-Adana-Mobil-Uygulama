#!/bin/sh

# Flutter'ı indir
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Bağımlılıkları yükle
cd ../..
flutter pub get

# iOS yapılandırmasını zorla tetikle
flutter build ios --config-only --release

# Pod kurulumunu temizle ve güncelle
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update

exit 0