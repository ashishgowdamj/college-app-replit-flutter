import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int id;
  @JsonKey(name: 'college_id')
  final int? collegeId;
  @JsonKey(name: 'student_name')
  final String? studentName;
  final String? course;
  @JsonKey(name: 'graduation_year')
  final int? graduationYear;
  final String? rating;
  final String? title;
  final String? content;
  final int? likes;
  final bool? verified;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  Review({
    required this.id,
    this.collegeId,
    this.studentName,
    this.course,
    this.graduationYear,
    this.rating,
    this.title,
    this.content,
    this.likes,
    this.verified,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  double get ratingAsDouble => double.tryParse(rating ?? '0') ?? 0.0;
}