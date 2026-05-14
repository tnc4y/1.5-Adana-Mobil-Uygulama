#!/bin/sh

# Xcode Cloud post_clone script
# Flutter uygulamasının Xcode Cloud ortamında derlenmesini sağlar

set -e  # Hata varsa scripti durdur

echo "=== Flutter CI/CD Script Başlatılıyor ==="

# 1. Ana dizine dön (ios/ci_scripts -> ana dizin)
cd "$(cd "$(dirname "$0")" && pwd)/../.."
echo "✓ Çalışma dizini: $(pwd)"

# 2. Flutter'ı indir ve kur (Xcode Cloud ortamında)
echo "⬇️ Flutter indiriliyor..."
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"
echo "✓ Flutter kuruldu"

# 3. Flutter bağımlılıklarını çek
echo "📦 Flutter bağımlılıkları çekiliyor..."
flutter pub get
echo "✓ Bağımlılıklar yüklendi"

# 4. CocoaPods kurulumu ve iOS bağımlılıkları
echo "📱 iOS bağımlılıkları kuruluyuyor..."
cd ios
pod install
echo "✓ Pod bağımlılıkları kuruldu"

echo "=== Flutter CI/CD Script Tamamlandı ==="

exit 0
