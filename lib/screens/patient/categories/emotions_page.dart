import 'package:flutter/material.dart';
import '../widgets/console_widget.dart';
import '../widgets/preview_box.dart';

class EmotionsPage extends StatelessWidget {
  const EmotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "DUYGULAR",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFF66BB6A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Column(
        children: [
          Padding(padding: EdgeInsets.all(16), child: PreviewBox()),
          Expanded(
            child: Center(
              child: Text("Duygular tasarımı daha sonra buraya eklenecek."),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ConsoleWidget(
        onConfirm: () {
          // �imdilik bo�, t�klay�nca bir �ey yapmayacak
        },
      ),
    );
  }
}
