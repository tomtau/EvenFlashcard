import 'package:demo_ai_even/models/flashcard_model.dart';
import 'package:get/get.dart';
import 'package:fsrs/fsrs.dart';

class FlashcardController extends GetxController {
  var items = <FlashcardModel>[].obs; // FIXME: persistant storage
  var reviewLogs = <ReviewLog>[].obs;

  var scheduler = FSRS();

  void addItem(String frontpage, String backpage) {
    final newItem = FlashcardModel(frontpage: frontpage, backpage: backpage, state: Card());
    items.insert(0, newItem);
    items.sort((a, b) => a.state.due.compareTo(b.state.due)); // TODO: store in a sorted set / priority queue
    update();
  }

  void removeItem(int index) {
    items.removeAt(index);
    update();
  }

  FlashcardModel? getDueCard() {
    final now = DateTime.now();
    if (items.isEmpty) {
      return null;
    }
    if (items[0].state.due.isBefore(now)) {
        return items[0];
    }
    return null;
  }

  void updateFirstCardState(Rating rating) {
    if (items.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final card = items[0];
    final ratings = scheduler.repeat(card.state, now);
    final newState = ratings[rating]!;
    reviewLogs.insert(0, newState.reviewLog);
    items[0].state = newState.card;
    items.sort((a, b) => a.state.due.compareTo(b.state.due)); // TODO: store in a sorted set / priority queue
    update();
  }

  void clearItems() {
    items.clear();
    update();
  }

}