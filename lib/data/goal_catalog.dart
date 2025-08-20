import 'package:flutter/material.dart';

/// Lightweight catalog to drive goal-based UI (can be replaced by backend later)
class GoalCatalog {
  static const defaultGoals = <String>[
    'BCA', 'B.Tech', 'MBA', 'M.Tech', 'MBBS', 'B.Com', 'B.Sc', 'B.Sc (Nursing)'
  ];

  // Additional courses to list under the "All Courses" dropdown in the drawer
  static const otherCourses = <String>[
    'B.Arch',
    'BBA',
    'BA',
    'B.Pharm',
    'BDS',
    'LLB',
    'B.Ed',
    'BHM',
    'B.Voc',
    'MCA',
    'M.Com',
  ];

  static const Map<String, List<String>> specializations = {
    'BCA': [
      'Data Science',
      'Computer Programming',
      'Cyber Security',
      'Information Technology',
      'Software Engineering',
      'Web Development',
      'Computer Operation',
      'Digital Education',
      'Game Development',
      'Networking Technologies',
      'Animation',
      'Web Designing',
      'Data Mining',
    ],
    'B.Tech': [
      'CSE', 'ECE', 'EEE', 'Mechanical', 'Civil', 'AI & ML', 'Aerospace'
    ],
    'MBBS': ['General Medicine', 'Pediatrics', 'Surgery', 'Orthopedics'],
    'MBA': ['Finance', 'Marketing', 'HR', 'Operations', 'Analytics'],
  };

  static const Map<String, List<String>> topPlaces = {
    'BCA': ['Mumbai', 'Bangalore', 'Pune', 'Chennai', 'Delhi'],
    'B.Tech': ['Delhi', 'Hyderabad', 'Bangalore', 'Chennai', 'Pune'],
    'MBBS': ['Delhi', 'Chennai', 'Kolkata', 'Bangalore'],
    'MBA': ['Ahmedabad', 'Bangalore', 'Mumbai', 'Delhi'],
  };

  static IconData goalIcon(String goal) {
    switch (goal.toUpperCase()) {
      case 'BCA':
      case 'B.COM':
        return Icons.computer;
      case 'B.TECH':
      case 'M.TECH':
        return Icons.engineering;
      case 'MBBS':
        return Icons.local_hospital;
      case 'MBA':
        return Icons.business_center;
      default:
        return Icons.school;
    }
  }
}
