import 'package:flutter/material.dart';
import '../widgets/console_widget.dart';

class NeedsPage extends StatelessWidget {
  const NeedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İhtiyaçlar"),
        backgroundColor: const Color(0xFF388E3C),
      ),
      body: const Center(
        child: Text("İhtiyaçlar tasarımı daha sonra buraya eklenecek."),
      ),
      bottomNavigationBar: ConsoleWidget(
        onConfirm: () {
          // Şimdilik boş, tıklayınca bir şey yapmayacak
        },
      ),
    );
  }
}
