import 'package:flutter/material.dart';
import '../widgets/console_widget.dart';
import '../widgets/preview_box.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "HABERLEŞME",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFF81C784),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Column(
        children: [
          Padding(padding: EdgeInsets.all(16), child: PreviewBox()),
          Expanded(
            child: Center(
              child: Text("Haberleşme tasarımı daha sonra buraya eklenecek."),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ConsoleWidget(
        onConfirm: () {
          // Şimdilik boş, tıklayınca bir şey yapmayacak.
        },
      ),
    );
  }
}
