import 'package:flutter/material.dart';
import '../widgets/console_widget.dart';

class EmotionsPage extends StatelessWidget {
  const EmotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Duygular"),
        backgroundColor: const Color(0xFF66BB6A),
      ),
      body: const Center(
        child: Text("Duygular tasarımı daha sonra buraya eklenecek."),
      ),
      bottomNavigationBar: ConsoleWidget(
        onConfirm: () {
          // Şimdilik boş, tıklayınca bir şey yapmayacak
        },
      ),
    );
  }
}
