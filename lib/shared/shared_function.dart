import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

// this function is meant to find difference in expiry date, not reminder time
int showDateDifference(DateTime date) {
  return DateTime(date.year, date.month, date.day)
      .difference(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day))
      .inDays;
}

// Function to delete reminder along with the image
deleteReminder(DocumentSnapshot docToDelete, bool ifDeleteImage) async {
  if (ifDeleteImage == true) {
    // if the productImage is not '', then we delete the image.
    if (docToDelete.data['productImage'] != '') {
      StorageReference imgStorageRef = await FirebaseStorage.instance
          .getReferenceFromUrl(docToDelete.data['productImage']);

      print(imgStorageRef.path);

      await imgStorageRef.delete().catchError((onError) =>
          print('An error has occured when deleting image.\n $onError'));

      print(
          'Image corresponding to >>>>>${docToDelete.data['reminderName']}<<<<< has been successfuly deleted.');
    }
  }
  // delete the document reference along with the image.
  await docToDelete.reference.delete().catchError((onError) =>
      print('An error has occured when deleting reminder.\n $onError'));
}

// TODO: send email notification
// get product name, and expiry date using the following method:
// forEach reminder, if reminderDate <= DateTime.now(),
// then append the product name and expiry date into a dynamic list.
// email that dynamic list to user's email.
