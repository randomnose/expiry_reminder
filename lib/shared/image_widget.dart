import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class ImageWidget {
  static Future getImage() async {
    final image = await ImagePicker().getImage(source: ImageSource.camera, imageQuality: 80);
    File newImage;
    if (image != null) {
      newImage = File(image.path);
    }
    return newImage;
  }

  static Future<String> uploadImageToFirebase(File imageToBeUpload, bool deleteImage,
      [String imageUrl]) async {
    String fileName = basename(imageToBeUpload.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('images/$fileName');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageToBeUpload);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    final String newImageUrl = await taskSnapshot.ref.getDownloadURL();

    // delete old image
    if (deleteImage == true) {
      deleteImageFromStorage(imageUrl);
    }

    return newImageUrl;
  }

  static deleteImageFromStorage(String url) async {
    if (url != null) {
      StorageReference imgStorageRef = await FirebaseStorage.instance.getReferenceFromUrl(url);
      await imgStorageRef
          .delete()
          .catchError((onError) => print('An error has occured when deleting image.\n $onError'));
    }
  }
}
