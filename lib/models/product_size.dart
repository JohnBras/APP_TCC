class ProductSize {
  int? sizeValue;
  int? stock;

  ProductSize({this.sizeValue, this.stock});

  ProductSize.fromMap(Map<String, dynamic> map) {
    sizeValue = map['sizeValue'] as int;
    stock = map['stock'] as int;
  }

  bool get hasStock => stock! > 0;

  ProductSize clone() {
    return ProductSize(
      sizeValue: sizeValue,
      stock: stock,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sizeValue': sizeValue,
      'stock': stock,
    };
  }

  @override
  String toString() {
    return 'ProductSize{sizeValue: $sizeValue, stock: $stock}';
  }
}
