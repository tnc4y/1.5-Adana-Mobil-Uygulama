import 'model_helpers.dart';

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.order,
    required this.visible,
    this.buttonText = '',
    this.buttonUrl = '',
    this.isImportant = false,
    this.showAsPopup = false,
    this.popupDismissKey = '',
    this.createdAt,
  });

  final String id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final int order;
  final bool visible;
  final String buttonText;
  final String buttonUrl;
  final bool isImportant;
  final bool showAsPopup;
  final String popupDismissKey;
  final DateTime? createdAt;

  factory Announcement.fromMap(String id, Map<String, dynamic> map) {
    return Announcement(
      id: id,
      title: stringOf(map['title']),
      summary: stringOf(map['summary']),
      content: stringOf(map['content']),
      imageUrl: stringOf(map['imageUrl']),
      order: intOf(map['order']),
      visible: boolOf(map['visible'], fallback: true),
      buttonText: stringOf(map['buttonText']),
      buttonUrl: stringOf(map['buttonUrl']),
      isImportant: boolOf(map['isImportant']),
      showAsPopup: boolOf(map['showAsPopup']),
      popupDismissKey: stringOf(map['popupDismissKey']),
      createdAt: dateOf(map['createdAt']),
    );
  }
}
