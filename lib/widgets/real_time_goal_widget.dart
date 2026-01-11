import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../models/user_settings.dart';

/// 실시간 목표 위젯
/// 실시간 자산 증식 컨셉의 메인 위젯
class RealTimeGoalWidget extends StatefulWidget {
  final DateTime startDate;
  final UserSettings settings;
  final Map<String, dynamic> todayItem;
  final VoidCallback? onTap;

  const RealTimeGoalWidget({
    super.key,
    required this.startDate,
    required this.settings,
    required this.todayItem,
    this.onTap,
  });

  @override
  State<RealTimeGoalWidget> createState() => _RealTimeGoalWidgetState();
}

class _RealTimeGoalWidgetState extends State<RealTimeGoalWidget> {
  Timer? _timer;
  double _moneySaved = 0.0;
  double _itemAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _updateValues();
    // 100ms마다 업데이트하여 부드러운 애니메이션 효과
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        setState(() {
          _updateValues();
        });
      }
    });
  }

  void _updateValues() {
    final now = DateTime.now();
    final elapsed = now.difference(widget.startDate);
    final totalSeconds = elapsed.inSeconds;

    // 하루 담배 가격 계산
    final dailyCost = (widget.settings.cigarettesPerDay /
            (widget.settings.cigarettesPerPack > 0
                ? widget.settings.cigarettesPerPack
                : 20)) *
        widget.settings.pricePerPack;

    // 초당 절약 금액 계산
    final moneyPerSecond = dailyCost / 86400;

    // 실시간 절약 금액 = 총 초 * 초당 절약 금액
    _moneySaved = totalSeconds * moneyPerSecond;

    // 아이템 수량 계산 (소수점 5~6자리까지)
    final itemPrice = widget.todayItem['price'] as int;
    _itemAmount = _moneySaved / itemPrice;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern('ko');
    final itemIcon = widget.todayItem['icon'] as IconData;
    final itemBgColor = widget.todayItem['bgColor'] as Color;
    final itemTextColor = widget.todayItem['textColor'] as Color;
    final itemName = widget.todayItem['name'] as String;
    final itemUnit = widget.todayItem['unit'] as String;
    final itemDescription = widget.todayItem['description'] as String;

    // 아이템 수량 포맷 (소수점 5~6자리)
    String itemAmountText;
    if (_itemAmount >= 0.01) {
      itemAmountText = _itemAmount.toStringAsFixed(5);
    } else {
      itemAmountText = _itemAmount.toStringAsFixed(6);
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              itemBgColor.withOpacity(0.2),
              itemBgColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: itemTextColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 메인 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: itemBgColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: itemTextColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                itemIcon,
                size: 64,
                color: itemTextColor,
              ),
            ),
            const SizedBox(height: 24),
            // 아이템 이름
            Text(
              itemName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: itemTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              itemDescription,
              style: TextStyle(
                fontSize: 16,
                color: itemTextColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            // 실시간 수량 표시
            Text(
              '$itemAmountText$itemUnit',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: itemTextColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '획득',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            // 실시간 금액 표시
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: itemTextColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    '현재 절약 중',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${numberFormat.format(_moneySaved.floor())}원',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

