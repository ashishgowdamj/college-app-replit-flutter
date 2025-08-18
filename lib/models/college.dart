import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'college.g.dart';

// Custom converter for Firebase Timestamp
class TimestampConverter implements JsonConverter<String?, dynamic> {
  const TimestampConverter();

  @override
  String? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) {
      return json.toDate().toIso8601String();
    }
    if (json is String) {
      return json;
    }
    return null;
  }

  @override
  dynamic toJson(String? object) {
    return object;
  }
}

@JsonSerializable()
class College {
  final int id;
  final String name;
  @JsonKey(name: 'short_name')
  final String? shortName;
  final String location;
  final String state;
  final String city;
  @JsonKey(name: 'established_year')
  final int? establishedYear;
  final String type;
  final String? affiliation;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final String? description;
  final String? website;
  @JsonKey(name: 'overall_rank')
  final int? overallRank;
  @JsonKey(name: 'nirf_rank')
  final int? nirfRank;
  final String? fees;
  @JsonKey(name: 'fees_period')
  final String? feesPeriod;
  final String? rating;
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  @JsonKey(name: 'admission_process')
  final String? admissionProcess;
  @JsonKey(name: 'cutoff_score')
  final int? cutoffScore;
  @JsonKey(name: 'placement_rate')
  final String? placementRate;
  @JsonKey(name: 'average_package')
  final String? averagePackage;
  @JsonKey(name: 'highest_package')
  final String? highestPackage;
  @JsonKey(name: 'hostel_fees')
  final String? hostelFees;
  @JsonKey(name: 'has_hostel')
  final bool? hasHostel;
  @JsonKey(defaultValue: [])
  final List<String> exams;
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  final String? createdAt;

  College({
    required this.id,
    required this.name,
    this.shortName,
    required this.location,
    required this.state,
    required this.city,
    this.establishedYear,
    required this.type,
    this.affiliation,
    this.imageUrl,
    this.description,
    this.website,
    this.overallRank,
    this.nirfRank,
    this.fees,
    this.feesPeriod,
    this.rating,
    this.reviewCount,
    this.admissionProcess,
    this.cutoffScore,
    this.placementRate,
    this.averagePackage,
    this.highestPackage,
    this.hostelFees,
    this.hasHostel,
    this.exams = const [],
    this.createdAt,
  });

  factory College.fromJson(Map<String, dynamic> json) {
    // First, create the college from the generated code
    final college = _$CollegeFromJson(json);
    
    // Then manually handle the exams field if it exists
    if (json['exams'] is List) {
      final exams = List<String>.from(json['exams'] as List);
      return college.copyWith(exams: exams);
    }
    
    return college;
  }
  
  Map<String, dynamic> toJson() => _$CollegeToJson(this);
  
  College copyWith({
    int? id,
    String? name,
    String? shortName,
    String? location,
    String? state,
    String? city,
    int? establishedYear,
    String? type,
    String? affiliation,
    String? imageUrl,
    String? description,
    String? website,
    int? overallRank,
    int? nirfRank,
    String? fees,
    String? feesPeriod,
    String? rating,
    int? reviewCount,
    String? admissionProcess,
    int? cutoffScore,
    String? placementRate,
    String? averagePackage,
    String? highestPackage,
    String? hostelFees,
    bool? hasHostel,
    List<String>? exams,
    String? createdAt,
  }) {
    return College(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      location: location ?? this.location,
      state: state ?? this.state,
      city: city ?? this.city,
      establishedYear: establishedYear ?? this.establishedYear,
      type: type ?? this.type,
      affiliation: affiliation ?? this.affiliation,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      website: website ?? this.website,
      overallRank: overallRank ?? this.overallRank,
      nirfRank: nirfRank ?? this.nirfRank,
      fees: fees ?? this.fees,
      feesPeriod: feesPeriod ?? this.feesPeriod,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      admissionProcess: admissionProcess ?? this.admissionProcess,
      cutoffScore: cutoffScore ?? this.cutoffScore,
      placementRate: placementRate ?? this.placementRate,
      averagePackage: averagePackage ?? this.averagePackage,
      highestPackage: highestPackage ?? this.highestPackage,
      hostelFees: hostelFees ?? this.hostelFees,
      hasHostel: hasHostel ?? this.hasHostel,
      exams: exams ?? this.exams,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get ratingAsDouble => double.tryParse(rating ?? '0') ?? 0.0;
  double get feesAsDouble => double.tryParse(fees ?? '0') ?? 0.0;
}
