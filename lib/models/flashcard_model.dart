import 'package:fsrs/fsrs.dart';

class FlashcardModel {
  String frontpage;
  String backpage;
  Card state; // stores the information for scheduling the card review

  FlashcardModel({required this.frontpage, required this.backpage, required this.state});
}