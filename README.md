# heimwatt

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

firebase projects:list
flutter build web --release
firebase deploy
firebase use <project id>


spacial instruction for deploy : 
1. in firebase.json file i set site and mention client's firebase project id so it will everytime deploy on this perticular domain. 
2. after run this command firebase deploy --only hosting:project-photo-upload-staging. 
3. url : https://erfassung.staging.heim-watt.de/