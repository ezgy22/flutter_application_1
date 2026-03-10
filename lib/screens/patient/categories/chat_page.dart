import 'package:flutter/material.dart';
import '../widgets/console_widget.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Haberleşme"),
        backgroundColor: const Color(0xFF81C784),
      ),
      body: const Center(
        child: Text("Haberleşme tasarımı daha sonra buraya eklenecek."),
      ),
      bottomNavigationBar: ConsoleWidget(
        onConfirm: () {
          // Şimdilik boş, tıklayınca bir şey yapmayacak
        },
      ),
    );
  }
}
