import 'package:json_annotation/json_annotation.dart';

part 'exam.g.dart';

@JsonSerializable()
class Exam {
  final int id;
  final String name;
  @JsonKey(name: 'full_name')
  final String? fullName;
  final String type;
  @JsonKey(name: 'conducting_body')
  final String? conductingBody;
  final String? frequency;
  @JsonKey(name: 'application_start_date')
  final String? applicationStartDate;
  @JsonKey(name: 'application_end_date')
  final String? applicationEndDate;
  @JsonKey(name: 'exam_date')
  final String? examDate;
  @JsonKey(name: 'result_date')
  final String? resultDate;
  final String? eligibility;
  final String? syllabus;
  @JsonKey(name: 'exam_pattern')
  final String? examPattern;
  @JsonKey(name: 'total_marks')
  final int? totalMarks;
  final String? duration;
  final String? website;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  Exam({
    required this.id,
    required this.name,
    this.fullName,
    required this.type,
    this.conductingBody,
    this.frequency,
    this.applicationStartDate,
    this.applicationEndDate,
    this.examDate,
    this.resultDate,
    this.eligibility,
    this.syllabus,
    this.examPattern,
    this.totalMarks,
    this.duration,
    this.website,
    this.createdAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);
  Map<String, dynamic> toJson() => _$ExamToJson(this);
}