import 'package:flutter/material.dart';
import '../widgets/console_widget.dart';
import '../widgets/preview_box.dart';

class QuestionsPage extends StatelessWidget {
  const QuestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sorular",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFF43A047),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Column(
        children: [
          Padding(padding: EdgeInsets.all(16), child: PreviewBox()),
          Expanded(
            child: Center(
              child: Text("Sorular tasarımı daha sonra buraya eklenecek."),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ConsoleWidget(
        onConfirm: () {
          // Şimdilik boş, tıklayınca bir şey yapmayacak
        },
      ),
    );
  }
}
