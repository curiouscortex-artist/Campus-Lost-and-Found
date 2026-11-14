# Campus Lost & Found

Flutter application for reporting and recovering campus lost-and-found items.

## Run locally

Install Flutter, then run:

```sh
flutter pub get
flutter run
```

The project includes Android, iOS, web, Linux, and Windows runners. QR camera
scanning is available on Android, iOS, macOS, and web; Linux and Windows use
the verification-code entry field instead. On web, camera access requires a
secure origin (HTTPS or localhost) and browser permission.

## Demo sign-in

- Admin: `admin@campus.edu` / `Admin123!`
- Student: `alex@student.edu` / `Student123!`

The app currently stores sample data in memory, so it resets when restarted.
