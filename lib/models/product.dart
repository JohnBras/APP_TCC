import 'dart:io';
import 'package:app_tcc/models/product_size.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class Product extends ChangeNotifier {
  String? id;
  String? name;
  String? description;
  num? price;
  List<String> images = [];
  List<ProductSize>? sizes;

  bool? deleted = false;
  List<dynamic> _newImages = [];
  List<dynamic> get newImages => _newImages;
  set newImages(List<dynamic> imgs) {
    _newImages = imgs;
    notifyListeners(); // dispara a notificação para o Consumer
  }

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    List<String>? images,
    List<ProductSize>? sizes,
    this.deleted = false,
  })  : images = images ?? [],
        sizes = sizes ?? [];

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  DocumentReference get productRef => firestore.doc('products/$id');
  Reference get storageRef => storage.ref().child('products').child(id!);

  Product.fromDocument(DocumentSnapshot document) {
    id = document.id;
    name = document['name'] as String;
    description = document['description'] as String;
    price = document['price'] as num;
    images = List<String>.from(
      document['images'] as List<dynamic>? ?? <String>[],
    );

    try {
      sizes = (document.get('sizes') as List<dynamic>)
          .map((s) => ProductSize.fromMap(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      sizes = []
          .map((s) => ProductSize.fromMap(s as Map<String, dynamic>))
          .toList();
    }
    deleted = ((document['deleted']) ?? false) as bool;
  }

  List<Map<String, dynamic>> exportSizeList() {
    return sizes!.map((size) => size.toMap()).toList();
  }

  num exportAppStock() {
    int stock = 0;
    for (final size in sizes ?? <ProductSize>[]) {
      stock += size.stock ?? 0;
    }
    return stock;
  }

  Future<void> save() async {
    loading = true;

    // 1) Guarde a lista antiga
    final List<String> oldImages = List.from(images);

    // 2) Atualize dados principais (sem imagens)
    final data = {
      'name': name,
      'description': description,
      'price': price,
      'sizes': exportSizeList(),
      'deleted': false,
    };
    if (id == null) {
      final doc = await firestore.collection('products').add(data);
      id = doc.id;
    } else {
      await productRef.update(data);
    }

    // 3) Upload apenas das novas imagens e coleta de URLs
    final List<String> newUploadedUrls = [];
    for (final newImage in newImages) {
      if (newImage is File) {
        final snap =
            await storageRef.child(const Uuid().v1()).putFile(newImage);
        newUploadedUrls.add(await snap.ref.getDownloadURL());
      }
    }

    // 4) Combine as URLs antigas e as recém‑enviadas
    final List<String> updatedImages = [
      ...oldImages,
      ...newUploadedUrls,
    ];

    // 5) Atualiza o Firestore com a lista completa de URLs
    await productRef.update({'images': updatedImages});
    // e no objeto local
    images = updatedImages;

    // 6) (Opcional) delete URLs removidas do Storage
    for (final url in oldImages) {
      if (!updatedImages.contains(url)) {
        try {
          final ref = url.startsWith('http')
              ? storage.refFromURL(url)
              : storage.ref(url);
          await ref.delete();
        } catch (_) {
          // ignora erros
        }
      }
    }

    loading = false;
  }

  ProductSize? _selectedSize;
  ProductSize get selectedSize => _selectedSize!;
  set selectedSize(ProductSize value) {
    _selectedSize = value;
    notifyListeners();
    print(selectedSize);
  }

  int get totalStock {
    // Se sizes for null, itera sobre lista vazia
    int stock = 0;
    for (final size in sizes ?? <ProductSize>[]) {
      // Se size.stock for null, usa 0
      stock += size.stock ?? 0;
    }
    return stock;
  }

  bool get hasStock {
    return totalStock > 0 && deleted == false;
  }

  ProductSize? findSize(String sizeValue) {
    try {
      return sizes!.firstWhere((s) => s.sizeValue.toString() == sizeValue);
    } catch (e) {
      return null;
    }
  }

  Product clone() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      images: List.from(images),
      sizes: sizes!.map((size) => size.clone()).toList(),
      deleted: deleted,
    );
  }

  void delete() {
    productRef.update({'deleted': true});
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, description: $description, price: $price, images: $images, sizes: $sizes, deleted: $deleted}';
  }
}
