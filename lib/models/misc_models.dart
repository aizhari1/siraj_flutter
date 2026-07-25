class CertificateModel {
  final String id;
  final String certificateNo;
  final String courseTitle;
  final DateTime issuedAt;
  final String? pdfUrl;

  CertificateModel({
    required this.id,
    required this.certificateNo,
    required this.courseTitle,
    required this.issuedAt,
    this.pdfUrl,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) => CertificateModel(
        id: json['id']?.toString() ?? '',
        certificateNo: json['certificateNo'] ?? '',
        courseTitle: json['course']?['title'] ?? json['courseTitle'] ?? '',
        issuedAt: DateTime.tryParse(json['issuedAt'] ?? '') ?? DateTime.now(),
        pdfUrl: json['pdfUrl'],
      );
}

class OrderModel {
  final String id;
  final String status;
  final double amount;
  final String? courseTitle;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.status,
    required this.amount,
    this.courseTitle,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id']?.toString() ?? '',
        status: json['status'] ?? 'PENDING',
        amount: (json['amount'] ?? json['total'] ?? 0).toDouble(),
        courseTitle: json['items']?[0]?['course']?['title'],
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? json['message'] ?? '',
        isRead: json['isRead'] ?? json['readAt'] != null,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}

class EnrollmentModel {
  final String id;
  final CourseSummary course;
  final double progressPercent;

  EnrollmentModel({required this.id, required this.course, this.progressPercent = 0});

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) => EnrollmentModel(
        id: json['id']?.toString() ?? '',
        course: CourseSummary.fromJson(json['course'] ?? {}),
        progressPercent: (json['progressPercent'] ?? json['progress'] ?? 0).toDouble(),
      );
}

class CourseSummary {
  final String id;
  final String title;
  final String? thumbnailUrl;

  CourseSummary({required this.id, required this.title, this.thumbnailUrl});

  factory CourseSummary.fromJson(Map<String, dynamic> json) => CourseSummary(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        thumbnailUrl: json['thumbnailUrl'],
      );
}
