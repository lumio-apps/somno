# Somno

Offline sleep tracker. If your phone stays locked for a long stretch (3 hours by default),
Somno counts it as sleep. No account, no ads, no cloud. The only network use is an optional daily check for a newer release on GitHub (can be turned off in Settings).

- Tracking modes: Night, Day or Any time, each with its own start and stop time
- Sleep goal set from your age (National Sleep Foundation ranges)
- History for the week and month, with add, edit and delete for every session
- Dark, light and system themes; English and Hindi

## How it works

A small Android foreground service listens only for screen off and unlock events and
stores their timestamps on the phone. When you open the app, the events are turned into
sleep sessions. Nothing leaves the device.

## Build

```
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

Releases are built by GitHub Actions when a version tag such as `v1.0.0` is pushed.
