import 'package:app_tcc/models/product_size.dart';
import 'package:flutter/material.dart';

class SizeWidget extends StatefulWidget {
  const SizeWidget({super.key, required this.size});

  final ProductSize size;

  @override
  _SizeWidgetState createState() => _SizeWidgetState();
}

class _SizeWidgetState extends State<SizeWidget> {
  @override
  Widget build(BuildContext context) {
    Color color;
    if (widget.size.hasStock) {
      color = Theme.of(context).primaryColor;
    } else {
      color = Colors.red.withAlpha(100);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: color,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              widget.size.sizeValue.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
