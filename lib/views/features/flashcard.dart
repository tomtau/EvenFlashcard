import 'package:demo_ai_even/ble_manager.dart';
import 'package:demo_ai_even/controllers/flashcard_controller.dart';
import 'package:demo_ai_even/services/evenai.dart';
import 'package:demo_ai_even/services/text_service.dart';
import 'package:flutter/material.dart';
import 'package:fsrs/fsrs.dart' as FSRS;
import 'package:get/get.dart';

class FlashCardPage extends StatefulWidget {
  const FlashCardPage({super.key});

  @override
  _FlashCardPageState createState() => _FlashCardPageState();
}

class _FlashCardPageState extends State<FlashCardPage> {
  late TextEditingController newCardFront;
  late TextEditingController newCardBack;

  String frontContent = '''''';
  String backContent = '''''';

  @override
  void initState() {
    newCardFront = TextEditingController(text: frontContent);
    newCardBack = TextEditingController(text: backContent);
    super.initState();
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new card'),
          content:
              Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(8),
                child: TextField(
                  decoration:
                      const InputDecoration.collapsed(hintText: "front page"),
                  controller: newCardFront,
                  onChanged: (newNotify) => setState(() {}),
                  maxLines: null,
                )),
            Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(8),
                child: TextField(
                  decoration:
                      const InputDecoration.collapsed(hintText: "back page"),
                  controller: newCardBack,
                  onChanged: (newNotify) => setState(() {}),
                  maxLines: null,
                )),
          ]),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Add'),
              onPressed: () {
                final controller = Get.find<FlashcardController>();
                controller.addItem(newCardFront.text, newCardBack.text);
                print(controller.items);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Flash card app'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: OutlinedButton(
                  onPressed: () => _dialogBuilder(context),
                  child: const Text('Add a flashcard'),
                ),
              ),
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(8),
                child: GetBuilder<FlashcardController>(
                  builder: (controller) => ListView.builder(
                      itemCount: controller.items.length,
                      itemBuilder: (context, index) {
                        final item = controller.items[index];
                        final dueDate = item.state.due.toLocal().toString();
                        return ListTile(
                          title: Text(item.frontpage),
                          subtitle: Text("Next card review due: $dueDate"),
                        );
                      }),
                ),
              ),
              GestureDetector(
                onTap: !BleManager.get().isConnected
                    ? null
                    : () async {
                        final controller = Get.find<FlashcardController>();
                        while (true) {
                          final item = controller.getDueCard();
                          if (item == null) {
                            break;
                          }
                          await TextService.get.startSendText(item.frontpage);
                          await Future.delayed(const Duration(seconds: 5));
                          // TODO: or should this wait for a microphone response (e.g. "reveal") from the glasses?
                          await TextService.get.startSendText(item.backpage);
                          // get feedback from the glasses microphone
                          var rating = null;
                          while (rating == null) {
                            EvenAI.get.toStartEvenAIByOS();
                            await Future.delayed(const Duration(seconds: 5));
                            var response = await EvenAI.get.recordText();
                            if (response.toLowerCase().contains("easy")) {
                              rating = FSRS.Rating.easy;
                            } else if (response.toLowerCase().contains("hard")) {
                              rating = FSRS.Rating.hard;
                            } else if (response.toLowerCase().contains("good")) {
                              rating = FSRS.Rating.good;
                            } else if (response.toLowerCase().contains("again")) {
                              rating = FSRS.Rating.again;
                            }
                          }
                          controller.updateFirstCardState(rating);
                        }
                        TextService.get.startSendText("All cards reviewed");
                      },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Review Cards on Glasses",
                    style: TextStyle(
                      color: BleManager.get().isConnected
                          ? Colors.black
                          : Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
