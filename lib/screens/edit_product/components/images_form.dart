import 'dart:io';
import 'package:app_tcc/models/product.dart';
import 'package:app_tcc/screens/edit_product/components/image_source_sheet.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImagesForm extends StatefulWidget {
  final Product product;
  const ImagesForm(this.product, {Key? key}) : super(key: key);

  @override
  _ImagesFormState createState() => _ImagesFormState();
}

class _ImagesFormState extends State<ImagesForm> {
  late List<dynamic> _images;

  @override
  void initState() {
    super.initState();
    // Inicia com URLs existentes e arquivos novos
    _images = List<dynamic>.from(widget.product.images);
    _images.addAll(widget.product.newImages);
  }

  void _onImageSelected(File file) {
    setState(() {
      _images.add(file);
      // Apenas novos arquivos
      widget.product.newImages = _images.where((e) => e is File).toList();
    });
  }

  void _removeImage(dynamic image) {
    setState(() {
      _images.remove(image);
      if (image is String) {
        // remove URL existente
        widget.product.images.remove(image);
      } else if (image is File) {
        // remove arquivo não enviado
        widget.product.newImages.remove(image);
      }
    });
  }

  Future<void> _showImageSourceSheet() async {
    if (Platform.isAndroid) {
      showModalBottomSheet(
        context: context,
        builder: (_) => ImageSourceSheet(onImageSelected: _onImageSelected),
      );
    } else {
      showCupertinoModalPopup(
        context: context,
        builder: (_) => ImageSourceSheet(onImageSelected: _onImageSelected),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: CarouselSlider(
            items: [
              ..._images.map((image) {
                final provider = image is String
                    ? NetworkImage(image)
                    : FileImage(image as File) as ImageProvider;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(image: provider, fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _removeImage(image),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child:
                              Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              // Placeholder expansível
              SizedBox.expand(
                child: Material(
                  color: Colors.grey[200],
                  child: IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    color: Theme.of(context).primaryColor,
                    iconSize: 40,
                    onPressed: _showImageSourceSheet,
                  ),
                ),
              ),
            ],
            options: CarouselOptions(
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              enlargeCenterPage: false,
            ),
          ),
        ),
        if (_images.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Insira ao menos uma imagem',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
