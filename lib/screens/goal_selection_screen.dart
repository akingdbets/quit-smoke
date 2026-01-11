import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../data/goal_items.dart';

/// 목표 선택 화면
/// 사용자가 목표 아이템을 선택할 수 있는 화면
class GoalSelectionScreen extends StatelessWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        title: const Text(
          '목표 선택',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final selectedGoalId = userProvider.settings.selectedGoalId;
          final numberFormat = NumberFormat.decimalPattern('ko');

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: GoalItems.items.length,
            itemBuilder: (context, index) {
              final item = GoalItems.items[index];
              final itemId = item['id'] as String;
              final itemName = item['name'] as String;
              final itemPrice = item['price'] as int;
              final itemUnit = item['unit'] as String;
              final itemIcon = item['icon'] as IconData;
              final itemBgColor = item['bgColor'] as Color;
              final itemTextColor = item['textColor'] as Color;
              final isSelected = selectedGoalId == itemId;

              return GestureDetector(
                onTap: () async {
                  try {
                    await userProvider.updateSelectedGoal(itemId);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('목표 선택 중 오류가 발생했습니다: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? itemTextColor
                          : const Color(0xFFE5E7EB), // gray-200
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 아이콘
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: itemBgColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            itemIcon,
                            size: 28,
                            color: itemTextColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 이름
                        Text(
                          itemName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: itemTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // 가격
                        Text(
                          '${numberFormat.format(itemPrice)}원 / ${itemUnit}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280), // gray-500
                          ),
                          textAlign: TextAlign.center,
                        ),
                          ],
                        ),
                      ),
                      // 선택 표시 (체크 아이콘)
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: itemTextColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

