#!/bin/sh

# 1. Flutter'ı bulut makinesine indir (stable kanal)
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# 2. Bağımlılıkları yükle
cd ../..
flutter pub get

# 3. CocoaPods kurulumu
cd ios
pod install

exit 0