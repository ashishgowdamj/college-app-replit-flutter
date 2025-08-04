// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'college.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

College _$CollegeFromJson(Map<String, dynamic> json) => College(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      shortName: json['short_name'] as String?,
      location: json['location'] as String,
      state: json['state'] as String,
      city: json['city'] as String,
      establishedYear: (json['established_year'] as num?)?.toInt(),
      type: json['type'] as String,
      affiliation: json['affiliation'] as String?,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      website: json['website'] as String?,
      overallRank: (json['overall_rank'] as num?)?.toInt(),
      nirfRank: (json['nirf_rank'] as num?)?.toInt(),
      fees: json['fees'] as String?,
      feesPeriod: json['fees_period'] as String?,
      rating: json['rating'] as String?,
      reviewCount: (json['review_count'] as num?)?.toInt(),
      admissionProcess: json['admission_process'] as String?,
      cutoffScore: (json['cutoff_score'] as num?)?.toInt(),
      placementRate: json['placement_rate'] as String?,
      averagePackage: json['average_package'] as String?,
      highestPackage: json['highest_package'] as String?,
      hostelFees: json['hostel_fees'] as String?,
      hasHostel: json['has_hostel'] as bool?,
      createdAt: const TimestampConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$CollegeToJson(College instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'short_name': instance.shortName,
      'location': instance.location,
      'state': instance.state,
      'city': instance.city,
      'established_year': instance.establishedYear,
      'type': instance.type,
      'affiliation': instance.affiliation,
      'image_url': instance.imageUrl,
      'description': instance.description,
      'website': instance.website,
      'overall_rank': instance.overallRank,
      'nirf_rank': instance.nirfRank,
      'fees': instance.fees,
      'fees_period': instance.feesPeriod,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'admission_process': instance.admissionProcess,
      'cutoff_score': instance.cutoffScore,
      'placement_rate': instance.placementRate,
      'average_package': instance.averagePackage,
      'highest_package': instance.highestPackage,
      'hostel_fees': instance.hostelFees,
      'has_hostel': instance.hasHostel,
      'created_at': const TimestampConverter().toJson(instance.createdAt),
    };
