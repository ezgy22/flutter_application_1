import 'package:flutter/material.dart';
import '../widgets/console_widget.dart';

class QuestionsPage extends StatelessWidget {
  const QuestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sorular"),
        backgroundColor: const Color(0xFF43A047),
      ),
      body: const Center(
        child: Text("Sorular tasarımı daha sonra buraya eklenecek."),
      ),
      bottomNavigationBar: ConsoleWidget(
        onConfirm: () {
          // Şimdilik boş, tıklayınca bir şey yapmayacak
        },
      ),
    );
  }
}
