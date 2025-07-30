import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

@JsonSerializable()
class Course {
  final int id;
  @JsonKey(name: 'college_id')
  final int? collegeId;
  final String name;
  final String degree;
  final String duration;
  final String? specialization;
  final String? fees;
  final int? seats;
  final String? eligibility;
  @JsonKey(name: 'entrance_exam')
  final String? entranceExam;
  @JsonKey(name: 'cutoff_score')
  final int? cutoffScore;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  Course({
    required this.id,
    this.collegeId,
    required this.name,
    required this.degree,
    required this.duration,
    this.specialization,
    this.fees,
    this.seats,
    this.eligibility,
    this.entranceExam,
    this.cutoffScore,
    this.createdAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);

  double get feesAsDouble => double.tryParse(fees ?? '0') ?? 0.0;
}