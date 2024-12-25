
import 'package:demo_ai_even/ble_manager.dart';
import 'package:demo_ai_even/controllers/evenai_model_controller.dart';
import 'package:demo_ai_even/controllers/flashcard_controller.dart';
import 'package:demo_ai_even/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


void main() {
  BleManager.get();
  Get.put(EvenaiModelController());
  Get.put(FlashcardController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Even AI Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), 
    );
  }
}
