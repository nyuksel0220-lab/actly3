# Flutter kurmadan Android APK oluşturma

1. GitHub'da boş bir repository oluşturun.
2. Bu klasörün içindeki dosyaları repository köküne yükleyin. `pubspec.yaml` GitHub ana sayfasında görünmelidir.
3. Repository içinden **Actions** sekmesini açın.
4. Soldan **Build Android APK** iş akışını seçin.
5. **Run workflow** > **Run workflow** düğmesine basın.
6. İşlem yeşil onay alınca ilgili çalışmayı açın.
7. Sayfanın altındaki **Artifacts** bölümünden `actly-release-apk` dosyasını indirin.
8. İnen ZIP'i açın ve `app-release.apk` dosyasını Android telefona aktarın.
9. Telefonda APK'ya dokunun. Gerekirse tarayıcı veya dosya yöneticisi için **Bilinmeyen uygulamaları yükle** izni verin.

Not: Bu APK test kurulumu içindir. Google Play yayını için ayrıca imzalı App Bundle, mağaza bilgileri ve sürüm kontrolleri gerekir.
