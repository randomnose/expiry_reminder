import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;

//   // collection reference
//   // a reference to a particular collection in FireStore Database
  final CollectionReference appUserCollection =
      Firestore.instance.collection('appUsers');
//   // final CollectionReference expiryReminderCollection =
//   //     Firestore.instance.collection('testingCollection');
//   final CollectionReference testingCollection =
//       Firestore.instance.collection('testingCollection');

  DatabaseService({this.uid});

//   // Future updateUserData(String name, List<dynamic> reminders) async {
//   //   return await expiryReminderCollection.document(uid).setData({
//   //     'name': name,
//   //     'noOfReminders': reminders.length,
//   //     'reminders': reminders
//   //   });
//   // }
  Future updateUserData(String name, String email) async {
    return await appUserCollection
        .document(uid)
        .setData({'name': name, 'email': email});
  }

//   // // reminder list from snapshot
//   // List<Reminder> _reminderListFromSnapshot(QuerySnapshot snapshot) {
//   //   return snapshot.documents.map((doc) {
//   //     return Reminder(
//   //         name: doc.data['name'] ?? '',
//   //         strength: doc.data['strength'] ?? 0,
//   //         sugars: doc.data['sugars'] ?? '0');
//   //   }).toList();
//   // }

//   // // userData from snapshot
//   // UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
//   //   return UserData(
//   //       uid: uid,
//   //       name: snapshot.data['name'],
//   //       sugars: snapshot.data['sugars'],
//   //       strength: snapshot.data['strength']);
//   // }

//   // // get stream from firestore
//   // Stream<List<Reminder>> get testCollection {
//   //   return testingCollection.snapshots().map(_reminderListFromSnapshot);
//   //   // return testingCollection.document(uid).snapshots().map(_reminderListFromSnapshot);
//   // }

//   // // get user doc stream
//   // Stream<UserData> get userData {
//   //   return testingCollection
//   //       .document(uid)
//   //       .snapshots()
//   //       .map((_userDataFromSnapshot));
//   // }

//   // // convert a userdata object into reminder object
//   // Reminder convertToReminder(UserData userData) {
//   //   return Reminder(
//   //     name: userData.name,
//   //     sugars: userData.sugars,
//   //     strength: userData.strength
//   //   );
//   // }
}
