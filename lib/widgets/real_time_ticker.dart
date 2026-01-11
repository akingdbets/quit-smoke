import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 실시간 타이머 위젯
/// D+15 03:20:45 형식으로 표시
class RealTimeTicker extends StatefulWidget {
  final DateTime startDate;
  final TextStyle? style;

  const RealTimeTicker({
    super.key,
    required this.startDate,
    this.style,
  });

  @override
  State<RealTimeTicker> createState() => _RealTimeTickerState();
}

class _RealTimeTickerState extends State<RealTimeTicker> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateElapsed();
        });
      }
    });
  }

  void _updateElapsed() {
    final now = DateTime.now();
    _elapsed = now.difference(widget.startDate);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _elapsed.inDays;
    final hours = _elapsed.inHours % 24;
    final minutes = _elapsed.inMinutes % 60;
    final seconds = _elapsed.inSeconds % 60;

    final text = 'D+$days ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Text(
      text,
      style: widget.style?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ) ?? TextStyle(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// 실시간 Duration 타이머 위젯
/// 00일 00:00:00 형식으로 표시
class RealTimeDurationTicker extends StatefulWidget {
  final DateTime startDate;
  final TextStyle? style;

  const RealTimeDurationTicker({
    super.key,
    required this.startDate,
    this.style,
  });

  @override
  State<RealTimeDurationTicker> createState() => _RealTimeDurationTickerState();
}

class _RealTimeDurationTickerState extends State<RealTimeDurationTicker> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateElapsed();
        });
      }
    });
  }

  void _updateElapsed() {
    final now = DateTime.now();
    _elapsed = now.difference(widget.startDate);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _elapsed.inDays;
    final hours = _elapsed.inHours % 24;
    final minutes = _elapsed.inMinutes % 60;
    final seconds = _elapsed.inSeconds % 60;

    final text = '${days.toString().padLeft(2, '0')}일 ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Text(
      text,
      style: widget.style?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ) ?? TextStyle(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// 실시간 EXP 진행률 표시 위젯
/// 소수점 4자리까지 표시 (98.1234%)
class RealTimeExpTicker extends StatefulWidget {
  final DateTime startDate;
  final int currentTitleDays;
  final int? nextTitleDays;
  final TextStyle? style;

  const RealTimeExpTicker({
    super.key,
    required this.startDate,
    required this.currentTitleDays,
    this.nextTitleDays,
    this.style,
  });

  @override
  State<RealTimeExpTicker> createState() => _RealTimeExpTickerState();
}

class _RealTimeExpTickerState extends State<RealTimeExpTicker> {
  Timer? _timer;
  double _expProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _updateExp();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        setState(() {
          _updateExp();
        });
      }
    });
  }

  void _updateExp() {
    final now = DateTime.now();
    final elapsed = now.difference(widget.startDate);
    final daysSinceQuit = elapsed.inMilliseconds / (1000 * 60 * 60 * 24);

    if (widget.nextTitleDays == null) {
      _expProgress = 100.0;
    } else {
      final currentDays = widget.currentTitleDays.toDouble();
      final nextDays = widget.nextTitleDays!.toDouble();
      
      if (nextDays <= currentDays) {
        _expProgress = 100.0;
      } else {
        _expProgress = ((daysSinceQuit - currentDays) / (nextDays - currentDays)) * 100;
        _expProgress = _expProgress.clamp(0.0, 100.0);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = '${_expProgress.toStringAsFixed(4)}%';

    return Text(
      text,
      style: widget.style?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ) ?? TextStyle(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// 실시간 금액 계산 위젯
class RealTimeMoneyTicker extends StatefulWidget {
  final DateTime startDate;
  final int cigarettesPerDay;
  final int cigarettesPerPack;
  final int pricePerPack;
  final TextStyle? style;
  final NumberFormat? numberFormat;

  const RealTimeMoneyTicker({
    super.key,
    required this.startDate,
    required this.cigarettesPerDay,
    required this.cigarettesPerPack,
    required this.pricePerPack,
    this.style,
    this.numberFormat,
  });

  @override
  State<RealTimeMoneyTicker> createState() => _RealTimeMoneyTickerState();
}

class _RealTimeMoneyTickerState extends State<RealTimeMoneyTicker> {
  Timer? _timer;
  int _moneySaved = 0;

  @override
  void initState() {
    super.initState();
    _updateMoney();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateMoney();
        });
      }
    });
  }

  void _updateMoney() {
    final now = DateTime.now();
    final elapsed = now.difference(widget.startDate);
    final daysSinceQuit = elapsed.inMilliseconds / (1000 * 60 * 60 * 24);
    
    final cigarettesNotSmoked = (daysSinceQuit * widget.cigarettesPerDay).round();
    final cigarettesPerPack = widget.cigarettesPerPack > 0 ? widget.cigarettesPerPack : 20;
    _moneySaved = ((cigarettesNotSmoked / cigarettesPerPack) * widget.pricePerPack).floor();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.numberFormat != null
        ? '${widget.numberFormat!.format(_moneySaved)}원'
        : '$_moneySaved원';

    return Text(
      text,
      style: widget.style?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ) ?? TextStyle(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// 실시간 시간 표시 위젯 (일, 시, 분 형식)
class RealTimeHoursTicker extends StatefulWidget {
  final DateTime startDate;
  final TextStyle? style;

  const RealTimeHoursTicker({
    super.key,
    required this.startDate,
    this.style,
  });

  @override
  State<RealTimeHoursTicker> createState() => _RealTimeHoursTickerState();
}

class _RealTimeHoursTickerState extends State<RealTimeHoursTicker> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateElapsed();
        });
      }
    });
  }

  void _updateElapsed() {
    final now = DateTime.now();
    _elapsed = now.difference(widget.startDate);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes = _elapsed.inMinutes;
    final days = totalMinutes ~/ (24 * 60);
    final hours = (totalMinutes % (24 * 60)) ~/ 60;
    final minutes = totalMinutes % 60;

    String text;
    if (days > 0) {
      text = '${days}일 ${hours}시간 ${minutes}분';
    } else if (hours > 0) {
      text = '${hours}시간 ${minutes}분';
    } else {
      text = '${minutes}분';
    }

    return Text(
      text,
      style: widget.style?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ) ?? TextStyle(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

