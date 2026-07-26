# Ship Checklist

## Automated checks

- Run `dart format lib test`.
- Run `flutter analyze` with zero errors.
- Run `flutter test`.
- Build Android release: `flutter build appbundle --release`.
- Build iOS release on macOS: `flutter build ipa --release`.

## Device QA

- Small Android phone at large text scale.
- Current Android phone, portrait and landscape.
- Current iPhone and a smaller iPhone size.
- VoiceOver and TalkBack navigation.
- Reduced motion enabled.
- Dark system appearance; Actly should preserve its own deliberate dark blueprint theme.
- Airplane mode from first launch through export.
- App background/foreground around the trigger time.
- Two snoozes, then the third-attempt redirect.
- Full completion, backup completion, and every skip reason.
- Simulation count, simulation-only deletion, export, and full reset.
- Corrupt-storage recovery on a development build.

## Store preparation still required

- Generate Android/iOS host folders with the target bundle identifiers.
- Add signed app icons, launch screens, store screenshots, privacy-policy URL, support URL, and store metadata.
- Configure Android signing and Apple certificates/profiles.
- Complete App Store privacy labels and Google Play Data safety answers based on the final binary.
- Run a closed beta before public release.
