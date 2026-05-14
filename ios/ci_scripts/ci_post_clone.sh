#!/bin/sh

# 1. Flutter'ı indir
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# 2. Ana dizine git ve paketleri çek
cd ../..
flutter pub get

# 3. İŞTE BURAYA EKLE: Xcode için gerekli dosyaları önceden oluştur
flutter build ios --config-only --release

# 4. iOS klasörüne dön ve Pod'ları kur
cd ios
pod install

exit 0