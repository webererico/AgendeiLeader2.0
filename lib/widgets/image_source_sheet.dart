import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {

  final Function(File) onImageSelected;
  ImageSourceSheet({this.onImageSelected});

  void imageSelected(File img) async{
    if(img!=null){
      File croppedImg = await ImageCropper.cropImage(
        sourcePath: img.path,
//        ratioX: 1.0,
//        ratioY: 1.0
      );
      onImageSelected(croppedImg);
    }
  }


  @override
  Widget build(BuildContext context) {
    return BottomSheet(
        onClosing: () {},
        builder: (context) => Column(
              children: <Widget>[
                FlatButton(
                    onPressed: () async {
                      File img = await ImagePicker.pickImage(
                          source: ImageSource.camera);
                      imageSelected(img);
                    },
                    child: Text('Camêra')),
                FlatButton(
                    onPressed: () async {
                      File img = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      imageSelected(img);
                    },
                    child: Text('Camêra'))
              ],
            ));
  }
}
