import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/user_settings.dart';

/// 실시간 아이템 수량 표시 위젯
/// 목표 아이템의 획득량을 실시간으로 표시
class RealTimeItemAmountTicker extends StatefulWidget {
  final DateTime startDate;
  final UserSettings settings;
  final Map<String, dynamic> todayItem;
  final TextStyle? style;

  const RealTimeItemAmountTicker({
    super.key,
    required this.startDate,
    required this.settings,
    required this.todayItem,
    this.style,
  });

  @override
  State<RealTimeItemAmountTicker> createState() => _RealTimeItemAmountTickerState();
}

class _RealTimeItemAmountTickerState extends State<RealTimeItemAmountTicker> {
  Timer? _timer;
  double _itemAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _updateAmount();
    // 100ms마다 업데이트하여 부드러운 애니메이션 효과
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        setState(() {
          _updateAmount();
        });
      }
    });
  }

  void _updateAmount() {
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
    final moneySaved = totalSeconds * moneyPerSecond;

    // 아이템 수량 계산 (소수점 5~6자리까지)
    final itemPrice = widget.todayItem['price'] as int;
    _itemAmount = moneySaved / itemPrice;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 아이템 수량 포맷 (소수점 5~6자리)
    String itemAmountText;
    if (_itemAmount >= 0.01) {
      itemAmountText = _itemAmount.toStringAsFixed(5);
    } else {
      itemAmountText = _itemAmount.toStringAsFixed(6);
    }

    final itemUnit = widget.todayItem['unit'] as String;

    return Text(
      '$itemAmountText$itemUnit',
      style: widget.style?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ) ?? TextStyle(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

