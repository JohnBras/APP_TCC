import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {
  final void Function(File) onImageSelected;
  ImageSourceSheet({required this.onImageSelected, Key? key}) : super(key: key);

  final ImagePicker _picker = ImagePicker();

  Future<void> _pick(ImageSource source, BuildContext context) async {
    final XFile? file = await _picker.pickImage(source: source);
    if (file != null) {
      onImageSelected(File(file.path));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              onPressed: () => _pick(ImageSource.camera, context),
              child: const Text('Câmera'),
            ),
            TextButton(
              onPressed: () => _pick(ImageSource.gallery, context),
              child: const Text('Galeria'),
            ),
          ],
        ),
      );
    } else {
      return SafeArea(
        child: CupertinoActionSheet(
          title: const Text('Selecionar foto'),
          message: const Text('Escolha a origem da foto'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => _pick(ImageSource.camera, context),
              child: const Text('Câmera'),
            ),
            CupertinoActionSheetAction(
              onPressed: () => _pick(ImageSource.gallery, context),
              child: const Text('Galeria'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ),
      );
    }
  }
}
