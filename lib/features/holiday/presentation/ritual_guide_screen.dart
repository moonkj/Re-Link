import 'package:flutter/material.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';

/// 제사/차례 순서 안내 가이드
class RitualGuideScreen extends StatelessWidget {
  const RitualGuideScreen({super.key});

  static const _steps = [
    _RitualStep(
      order: 1,
      title: '강신(降神)',
      subtitle: '신을 모셔오는 절차',
      description:
          '제주가 향을 피우고, 술을 모사(茅沙)에 세 번 나누어 부은 후 두 번 절합니다.',
      icon: Icons.local_fire_department_outlined,
    ),
    _RitualStep(
      order: 2,
      title: '참신(參神)',
      subtitle: '신에게 인사하는 절차',
      description: '참석자 모두 두 번 절합니다. (여자는 네 번)',
      icon: Icons.people_outlined,
    ),
    _RitualStep(
      order: 3,
      title: '초헌(初獻)',
      subtitle: '첫 번째 잔 올리기',
      description:
          '제주가 첫 번째 술잔을 올리고, 젓가락을 음식 위에 놓습니다.',
      icon: Icons.wine_bar_outlined,
    ),
    _RitualStep(
      order: 4,
      title: '독축(讀祝)',
      subtitle: '축문 읽기',
      description:
          '제주가 무릎 꿇고 축문을 읽습니다. 참석자 모두 무릎 꿇어 앉습니다.',
      icon: Icons.menu_book_outlined,
    ),
    _RitualStep(
      order: 5,
      title: '아헌(亞獻)',
      subtitle: '두 번째 잔 올리기',
      description:
          '주부(제주의 배우자) 또는 다음 서열이 두 번째 술잔을 올립니다.',
      icon: Icons.wine_bar_outlined,
    ),
    _RitualStep(
      order: 6,
      title: '종헌(終獻)',
      subtitle: '세 번째 잔 올리기',
      description: '다음 서열의 사람이 마지막 술잔을 올립니다.',
      icon: Icons.wine_bar_outlined,
    ),
    _RitualStep(
      order: 7,
      title: '유식(侑食)',
      subtitle: '식사를 권하는 절차',
      description:
          '메(밥)의 뚜껑을 열고 수저를 꽂습니다. 숟가락은 동쪽, 젓가락은 서쪽으로.',
      icon: Icons.restaurant_outlined,
    ),
    _RitualStep(
      order: 8,
      title: '합문(闔門)',
      subtitle: '문을 닫고 기다리는 절차',
      description:
          '참석자 모두 잠시 자리를 비우거나 고개를 숙여 조상이 식사하시도록 기다립니다.',
      icon: Icons.door_front_door_outlined,
    ),
    _RitualStep(
      order: 9,
      title: '계문(啓門)',
      subtitle: '문을 여는 절차',
      description:
          '기침 소리를 내어 문을 열고 다시 들어갑니다. 숭늉(물)을 올리고 수저를 거둡니다.',
      icon: Icons.meeting_room_outlined,
    ),
    _RitualStep(
      order: 10,
      title: '사신(辭神)',
      subtitle: '신을 보내드리는 절차',
      description:
          '참석자 모두 두 번 절합니다. 축문과 지방을 불사르고, 음식을 나누어 먹습니다(음복).',
      icon: Icons.waving_hand_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '제사 순서 안내',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // 안내 헤더
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Icon(Icons.auto_stories,
                    color: AppColors.primary, size: 32),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '전통 제사(기제사) 순서',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '가정마다 차이가 있을 수 있습니다',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // 단계별 카드
          ..._steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 순서 번호
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withAlpha(30),
                      ),
                      child: Center(
                        child: Text(
                          '${step.order}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(step.icon,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                step.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(
                                child: Text(
                                  step.subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            step.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 차례 안내
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '차례(茶禮)와의 차이',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$bulletPoint 차례는 명절(설날, 추석)에 지내는 약식 제사입니다\n'
                  '$bulletPoint 축문을 읽지 않고, 술은 한 번만 올립니다\n'
                  '$bulletPoint 설날에는 떡국, 추석에는 송편을 올립니다\n'
                  '$bulletPoint 절차가 간소하여 강신 → 헌작 → 사신 순으로 진행합니다',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }

  static const bulletPoint = '\u2022';
}

class _RitualStep {
  const _RitualStep({
    required this.order,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });

  final int order;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
}
