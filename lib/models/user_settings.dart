/// UserSettings 모델 클래스
/// React의 UserSettings 인터페이스를 Dart로 변환
class UserSettings {
  final String? startDate;
  final int cigarettesPerDay;
  final int cigarettesPerPack;
  final int pricePerPack;
  final QuitReason quitReason;
  final String personalGoal;
  final PersonalGoalType personalGoalType;
  final String personalGoalCategory;
  final int personalGoalAmount;
  final String healthGoal;
  final String nickname;
  final int age;

  UserSettings({
    this.startDate,
    required this.cigarettesPerDay,
    required this.cigarettesPerPack,
    required this.pricePerPack,
    required this.quitReason,
    required this.personalGoal,
    required this.personalGoalType,
    required this.personalGoalCategory,
    required this.personalGoalAmount,
    required this.healthGoal,
    required this.nickname,
    required this.age,
  });

  /// 기본값을 가진 UserSettings 생성
  factory UserSettings.defaultSettings() {
    return UserSettings(
      startDate: null,
      cigarettesPerDay: 20,
      cigarettesPerPack: 20,
      pricePerPack: 4500,
      quitReason: QuitReason.health,
      personalGoal: '',
      personalGoalType: PersonalGoalType.money,
      personalGoalCategory: '',
      personalGoalAmount: 0,
      healthGoal: '',
      nickname: '',
      age: 0,
    );
  }

  /// JSON으로부터 UserSettings 생성
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      startDate: json['startDate'] as String?,
      cigarettesPerDay: json['cigarettesPerDay'] as int? ?? 20,
      cigarettesPerPack: json['cigarettesPerPack'] as int? ?? 20,
      pricePerPack: json['pricePerPack'] as int? ?? 4500,
      quitReason: QuitReason.fromString(json['quitReason'] as String? ?? 'health'),
      personalGoal: json['personalGoal'] as String? ?? '',
      personalGoalType: PersonalGoalType.fromString(json['personalGoalType'] as String? ?? 'money'),
      personalGoalCategory: json['personalGoalCategory'] as String? ?? '',
      personalGoalAmount: json['personalGoalAmount'] as int? ?? 0,
      healthGoal: json['healthGoal'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      age: json['age'] as int? ?? 0,
    );
  }

  /// UserSettings를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'cigarettesPerDay': cigarettesPerDay,
      'cigarettesPerPack': cigarettesPerPack,
      'pricePerPack': pricePerPack,
      'quitReason': quitReason.value,
      'personalGoal': personalGoal,
      'personalGoalType': personalGoalType.value,
      'personalGoalCategory': personalGoalCategory,
      'personalGoalAmount': personalGoalAmount,
      'healthGoal': healthGoal,
      'nickname': nickname,
      'age': age,
    };
  }

  /// Firestore에 저장하기 위한 Map 변환 (toJson과 동일)
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// copyWith 메서드 (불변성 유지)
  UserSettings copyWith({
    String? startDate,
    int? cigarettesPerDay,
    int? cigarettesPerPack,
    int? pricePerPack,
    QuitReason? quitReason,
    String? personalGoal,
    PersonalGoalType? personalGoalType,
    String? personalGoalCategory,
    int? personalGoalAmount,
    String? healthGoal,
    String? nickname,
    int? age,
  }) {
    return UserSettings(
      startDate: startDate ?? this.startDate,
      cigarettesPerDay: cigarettesPerDay ?? this.cigarettesPerDay,
      cigarettesPerPack: cigarettesPerPack ?? this.cigarettesPerPack,
      pricePerPack: pricePerPack ?? this.pricePerPack,
      quitReason: quitReason ?? this.quitReason,
      personalGoal: personalGoal ?? this.personalGoal,
      personalGoalType: personalGoalType ?? this.personalGoalType,
      personalGoalCategory: personalGoalCategory ?? this.personalGoalCategory,
      personalGoalAmount: personalGoalAmount ?? this.personalGoalAmount,
      healthGoal: healthGoal ?? this.healthGoal,
      nickname: nickname ?? this.nickname,
      age: age ?? this.age,
    );
  }
}

/// 금연 이유 열거형
enum QuitReason {
  health('health'),
  money('money'),
  family('family'),
  selfImprovement('self-improvement');

  final String value;
  const QuitReason(this.value);

  static QuitReason fromString(String value) {
    return QuitReason.values.firstWhere(
      (e) => e.value == value,
      orElse: () => QuitReason.health,
    );
  }
}

/// 개인 목표 타입 열거형
enum PersonalGoalType {
  money('money'),
  healthFamily('health-family'),
  none('none');

  final String value;
  const PersonalGoalType(this.value);

  static PersonalGoalType fromString(String value) {
    return PersonalGoalType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PersonalGoalType.money,
    );
  }
}

