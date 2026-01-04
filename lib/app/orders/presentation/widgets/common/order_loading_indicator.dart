import 'package:flutter/material.dart';

class OrderLoadingIndicator extends StatelessWidget {
  const OrderLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
      ),
    );
  }
}
