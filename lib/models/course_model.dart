enum CourseStatus { draft, pendingReview, published, archived, rejected }
enum CourseLevel { beginner, intermediate, advanced, allLevels }

CourseStatus _statusFromString(String? v) {
  switch (v) {
    case 'PENDING_REVIEW':
      return CourseStatus.pendingReview;
    case 'PUBLISHED':
      return CourseStatus.published;
    case 'ARCHIVED':
      return CourseStatus.archived;
    case 'REJECTED':
      return CourseStatus.rejected;
    default:
      return CourseStatus.draft;
  }
}

CourseLevel _levelFromString(String? v) {
  switch (v) {
    case 'INTERMEDIATE':
      return CourseLevel.intermediate;
    case 'ADVANCED':
      return CourseLevel.advanced;
    case 'ALL_LEVELS':
      return CourseLevel.allLevels;
    default:
      return CourseLevel.beginner;
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? icon;

  CategoryModel({required this.id, required this.name, required this.slug, this.icon});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        slug: json['slug'] ?? '',
        icon: json['icon'],
      );
}

class CourseModel {
  final String id;
  final String title;
  final String slug;
  final String? shortDescription;
  final String? description;
  final String? thumbnailUrl;
  final double price;
  final double? discountPrice;
  final CourseLevel level;
  final CourseStatus status;
  final String? teacherName;
  final String? teacherId;
  final String? categoryName;
  final double rating;
  final int studentsCount;
  final int lessonsCount;

  CourseModel({
    required this.id,
    required this.title,
    required this.slug,
    this.shortDescription,
    this.description,
    this.thumbnailUrl,
    this.price = 0,
    this.discountPrice,
    this.level = CourseLevel.beginner,
    this.status = CourseStatus.draft,
    this.teacherName,
    this.teacherId,
    this.categoryName,
    this.rating = 0,
    this.studentsCount = 0,
    this.lessonsCount = 0,
  });

  bool get isFree => price == 0;

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      shortDescription: json['shortDescription'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'] ?? json['coverImage'],
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discountPrice'] != null ? (json['discountPrice']).toDouble() : null,
      level: _levelFromString(json['level']),
      status: _statusFromString(json['status']),
      teacherName: json['teacher']?['fullName'] ?? json['teacherName'],
      teacherId: json['teacherId']?.toString() ?? json['teacher']?['id']?.toString(),
      categoryName: json['category']?['name'] ?? json['categoryName'],
      rating: (json['averageRating'] ?? json['rating'] ?? 0).toDouble(),
      studentsCount: json['enrollmentsCount'] ?? json['studentsCount'] ?? 0,
      lessonsCount: json['lessonsCount'] ?? 0,
    );
  }
}
