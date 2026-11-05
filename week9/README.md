## Week 09 – FireCards + Firebase

For Week 09, I chose Option 1 and used the class `09-FireCards` project as a starting point to learn how an iOS app can save and sync data in the cloud with Firebase Firestore.

### What I Did

* Downloaded the `09-FireCards` class example and renamed the project folder to `week9`.
* Created my own Firebase project called `firecards-ran`.
* Changed the Signing Team and Bundle Identifier in Xcode .
* Registered my iOS app in Firebase with the same Bundle ID.
* Replaced the original Firebase configuration with my own `GoogleService-Info.plist`.
* Enabled Anonymous Authentication in Firebase.
* Created a Cloud Firestore database in test mode.
* Added cards in the app and verified that they appeared in the `cards` collection in my Firestore database.
* Replaced test-mode rules with per-user security rules

### What I Learned

In previous weeks, I saved data locally with `@AppStorage` and JSON files. This week I learned how Firebase Firestore stores app data remotely in the cloud.

* `CardRepository` reads and writes a `cards` collection in Firestore.
* Anonymous sign-in gives each device a unique `userId`. Every card is saved with that ID, and the app only loads cards that belong to the current user.
* The app uses a snapshot listener, so changes sync in real time. When I edited a card in the Firebase console, the app updated without a refresh.
* The project is pinned to Firebase SDK 10.23.1. Newer versions merge `FirebaseFirestoreSwift` into `FirebaseFirestore`, so updating the packages would break the build.

### Problems & Solutions

* **Couldn't create a Firebase project with my NYU account.** It required selecting a parent resource under the NYU organization. I switched to my personal Google account.
* **Simulator launch error** ("No such process"). This was a temporary simulator issue. The app launched after I ran it again.

### AI Use

I used Claude to help me understand the Firebase setup process, to debug build errors and connect the class example to my own Firebase project. 
I followed the setup steps myself in Xcode and Firebase Console, and I tested the result by adding cards and checking Firestore.

### Reference

* Class example: `molab-itp/09-FireCards`
* Original tutorial: [Getting Started with Cloud Firestore and SwiftUI](https://www.kodeco.com/11609977-getting-started-with-cloud-firestore-and-swiftui) (Kodeco)
