// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      id: (json['id'] as num).toInt(),
      collegeId: (json['college_id'] as num?)?.toInt(),
      name: json['name'] as String,
      degree: json['degree'] as String,
      duration: json['duration'] as String,
      specialization: json['specialization'] as String?,
      fees: json['fees'] as String?,
      seats: (json['seats'] as num?)?.toInt(),
      eligibility: json['eligibility'] as String?,
      entranceExam: json['entrance_exam'] as String?,
      cutoffScore: (json['cutoff_score'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'id': instance.id,
      'college_id': instance.collegeId,
      'name': instance.name,
      'degree': instance.degree,
      'duration': instance.duration,
      'specialization': instance.specialization,
      'fees': instance.fees,
      'seats': instance.seats,
      'eligibility': instance.eligibility,
      'entrance_exam': instance.entranceExam,
      'cutoff_score': instance.cutoffScore,
      'created_at': instance.createdAt,
    };
