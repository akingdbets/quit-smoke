import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// 목표 아이템 데이터
/// 매일 변경되는 목표 아이템 시스템
class GoalItems {
  /// 목표 아이템 리스트
  static const List<Map<String, dynamic>> items = [
    {
      'id': 'tesla',
      'name': '테슬라 주식',
      'price': 644997,
      'unit': '주',
      'icon': LucideIcons.trendingUp,
      'bgColor': Color(0xFFF3E8FF), // purple-100
      'textColor': Color(0xFF9333EA), // purple-600
      'description': 'TSLA',
    },
    {
      'id': 'nvidia',
      'name': '엔비디아 주식',
      'price': 267000,
      'unit': '주',
      'icon': LucideIcons.zap,
      'bgColor': Color(0xFFDCFCE7), // green-100
      'textColor': Color(0xFF16A34A), // green-600
      'description': 'NVDA',
    },
    {
      'id': 'apple',
      'name': '애플 주식',
      'price': 375930,
      'unit': '주',
      'icon': LucideIcons.apple,
      'bgColor': Color(0xFFF3F4F6), // gray-100
      'textColor': Color(0xFF4B5563), // gray-600
      'description': 'AAPL',
    },
    {
      'id': 'ferrari',
      'name': '페라리 488',
      'price': 350000000,
      'unit': '개',
      'icon': LucideIcons.car,
      'bgColor': Color(0xFFFEE2E2), // red-100
      'textColor': Color(0xFFDC2626), // red-600
      'description': '슈퍼카',
    },
    {
      'id': 'iphone',
      'name': '아이폰 16 Pro',
      'price': 1550000,
      'unit': '개',
      'icon': LucideIcons.smartphone,
      'bgColor': Color(0xFFDBEAFE), // blue-100
      'textColor': Color(0xFF2563EB), // blue-600
      'description': '최신형',
    },
    {
      'id': 'macbook',
      'name': '맥북 Pro',
      'price': 3200000,
      'unit': '개',
      'icon': LucideIcons.laptop,
      'bgColor': Color(0xFFE0E7FF), // indigo-100
      'textColor': Color(0xFF4F46E5), // indigo-600
      'description': '16인치',
    },
    {
      'id': 'porsche',
      'name': '포르쉐 911',
      'price': 180000000,
      'unit': '개',
      'icon': LucideIcons.car,
      'bgColor': Color(0xFFFEF9C3), // yellow-100
      'textColor': Color(0xFFCA8A04), // yellow-600
      'description': '스포츠카',
    },
  ];

  /// ID로 아이템 찾기
  static Map<String, dynamic>? findById(String id) {
    try {
      return items.firstWhere((item) => item['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// 날짜 기반으로 아이템 선택 (기존 로직)
  static Map<String, dynamic> getByDayOfYear(int dayOfYear) {
    return items[dayOfYear % items.length];
  }
}

