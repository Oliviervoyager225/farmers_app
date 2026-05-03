class AppNotification {
  final String key;
  final String type; // 'near_limit' | 'over_limit' | 'overdue_debt'
  final int farmerId;
  final String farmerName;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.key,
    required this.type,
    required this.farmerId,
    required this.farmerName,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        key:        json['key'] as String,
        type:       json['type'] as String,
        farmerId:   json['farmer_id'] as int,
        farmerName: json['farmer_name'] as String,
        title:      json['title'] as String,
        body:       json['body'] as String,
        isRead:     json['read_at'] != null,
        createdAt:  DateTime.parse(json['created_at'] as String),
      );
}
