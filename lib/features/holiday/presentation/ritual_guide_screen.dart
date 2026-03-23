import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../../../core/database/tables/settings_table.dart';
import '../../../shared/repositories/settings_repository.dart';

/// 추모 가이드 — 종교 중립적 추모 방식 안내
///
/// 3개 탭:
///   1. 전통 (유교/제사)
///   2. 종교 (기독교/천주교)
///   3. 자유 (현대식)
class RitualGuideScreen extends ConsumerStatefulWidget {
  const RitualGuideScreen({super.key});

  @override
  ConsumerState<RitualGuideScreen> createState() => _RitualGuideScreenState();
}

class _RitualGuideScreenState extends ConsumerState<RitualGuideScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '추모 가이드',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: '전통'),
            Tab(text: '종교'),
            Tab(text: '자유'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TraditionalTab(),
          _ReligiousTab(),
          _ModernTab(),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// ── 탭 1: 전통 (유교/제사) ─────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════

class _TraditionalTab extends ConsumerStatefulWidget {
  const _TraditionalTab();

  @override
  ConsumerState<_TraditionalTab> createState() => _TraditionalTabState();
}

class _TraditionalTabState extends ConsumerState<_TraditionalTab>
    with AutomaticKeepAliveClientMixin {
  final Set<int> _checkedItems = {};

  @override
  void initState() {
    super.initState();
    _loadCheckedItems();
  }

  Future<void> _loadCheckedItems() async {
    final repo = ref.read(settingsRepositoryProvider);
    final raw = await repo.get(SettingsKey.ritualCheckTraditional);
    if (!mounted) return;
    if (raw != null && raw.isNotEmpty) {
      setState(() {
        _checkedItems
          ..clear()
          ..addAll(raw.split(',').map((e) => int.tryParse(e.trim())).whereType<int>());
      });
    }
  }

  Future<void> _saveCheckedItems() async {
    final repo = ref.read(settingsRepositoryProvider);
    final value = _checkedItems.toList()..sort();
    await repo.set(SettingsKey.ritualCheckTraditional, value.join(','));
  }

  static const _steps = [
    _GuideStep(
      order: 1,
      title: '강신(降神)',
      subtitle: '신을 모셔오는 절차',
      description:
          '제주가 향을 피우고, 술을 모사(茅沙)에 세 번 나누어 부은 후 두 번 절합니다.',
      icon: Icons.local_fire_department_outlined,
    ),
    _GuideStep(
      order: 2,
      title: '참신(參神)',
      subtitle: '신에게 인사하는 절차',
      description: '참석자 모두 두 번 절합니다. (여자는 네 번)',
      icon: Icons.people_outlined,
    ),
    _GuideStep(
      order: 3,
      title: '초헌(初獻)',
      subtitle: '첫 번째 잔 올리기',
      description:
          '제주가 첫 번째 술잔을 올리고, 젓가락을 음식 위에 놓습니다.',
      icon: Icons.wine_bar_outlined,
    ),
    _GuideStep(
      order: 4,
      title: '아헌(亞獻)',
      subtitle: '두 번째 잔 올리기',
      description:
          '주부(제주의 배우자) 또는 다음 서열이 두 번째 술잔을 올립니다.',
      icon: Icons.wine_bar_outlined,
    ),
    _GuideStep(
      order: 5,
      title: '종헌(終獻)',
      subtitle: '세 번째 잔 올리기',
      description: '다음 서열의 사람이 마지막 술잔을 올립니다.',
      icon: Icons.wine_bar_outlined,
    ),
    _GuideStep(
      order: 6,
      title: '유식(侑食)',
      subtitle: '식사를 권하는 절차',
      description:
          '메(밥)의 뚜껑을 열고 수저를 꽂습니다. 숟가락은 동쪽, 젓가락은 서쪽으로.',
      icon: Icons.restaurant_outlined,
    ),
    _GuideStep(
      order: 7,
      title: '합문(闔門)',
      subtitle: '문을 닫고 기다리기',
      description:
          '참석자 모두 잠시 자리를 비우거나 고개를 숙여 조상이 식사하시도록 기다립니다.',
      icon: Icons.door_front_door_outlined,
    ),
    _GuideStep(
      order: 8,
      title: '헌다(獻茶)',
      subtitle: '차/숭늉 올리기',
      description:
          '기침 소리를 내어 문을 열고 다시 들어갑니다. 숭늉(물)을 올리고 수저를 거둡니다.',
      icon: Icons.emoji_food_beverage_outlined,
    ),
    _GuideStep(
      order: 9,
      title: '사신(辭神)',
      subtitle: '신을 보내드리기',
      description:
          '참석자 모두 두 번 절합니다. 축문과 지방을 불사릅니다.',
      icon: Icons.waving_hand_outlined,
    ),
    _GuideStep(
      order: 10,
      title: '철상/음복',
      subtitle: '상을 치우고 나눠 먹기',
      description:
          '제사 음식을 거두고, 가족이 함께 나누어 먹으며 조상을 기억합니다.',
      icon: Icons.groups_outlined,
    ),
  ];

  static const _checklistItems = [
    '과일 (사과, 배, 감 등)',
    '떡 (시루떡, 인절미)',
    '나물 (고사리, 시금치, 도라지)',
    '전 (동태전, 육전, 녹두전)',
    '포 (북어포, 대구포)',
    '향과 초',
    '술 (소주 또는 정종)',
    '밥과 국',
    '축문 / 지방',
    '모사 그릇',
    '제기 세트',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // ── 헤더 ──
        _buildHeader(
          icon: Icons.auto_stories,
          title: '전통 제사/차례',
          subtitle: '유교식 전통 추모 절차입니다\n가정마다 차이가 있을 수 있습니다',
          color: AppColors.primary,
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── 순서 카드 ──
        ..._steps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _StepCard(step: step, accentColor: AppColors.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── 준비물 체크리스트 ──
        _buildChecklistSection(
          title: '준비물 체크리스트',
          items: _checklistItems,
          checkedItems: _checkedItems,
          accentColor: AppColors.primary,
          onToggle: (index) {
            setState(() {
              if (_checkedItems.contains(index)) {
                _checkedItems.remove(index);
              } else {
                _checkedItems.add(index);
              }
            });
            _saveCheckedItems();
          },
        ),
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// ── 탭 2: 종교 (기독교/천주교) ──────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════

class _ReligiousTab extends ConsumerStatefulWidget {
  const _ReligiousTab();

  @override
  ConsumerState<_ReligiousTab> createState() => _ReligiousTabState();
}

class _ReligiousTabState extends ConsumerState<_ReligiousTab>
    with AutomaticKeepAliveClientMixin {
  final Set<int> _checkedItems = {};

  @override
  void initState() {
    super.initState();
    _loadCheckedItems();
  }

  Future<void> _loadCheckedItems() async {
    final repo = ref.read(settingsRepositoryProvider);
    final raw = await repo.get(SettingsKey.ritualCheckReligious);
    if (!mounted) return;
    if (raw != null && raw.isNotEmpty) {
      setState(() {
        _checkedItems
          ..clear()
          ..addAll(raw.split(',').map((e) => int.tryParse(e.trim())).whereType<int>());
      });
    }
  }

  Future<void> _saveCheckedItems() async {
    final repo = ref.read(settingsRepositoryProvider);
    final value = _checkedItems.toList()..sort();
    await repo.set(SettingsKey.ritualCheckReligious, value.join(','));
  }

  static const _steps = [
    _GuideStep(
      order: 1,
      title: '묵상',
      subtitle: '고인을 추모하며 마음 정리',
      description:
          '참석자들이 자리에 앉아 조용히 고인을 떠올리며 마음을 가다듬습니다.',
      icon: Icons.self_improvement_outlined,
    ),
    _GuideStep(
      order: 2,
      title: '찬송',
      subtitle: '찬송가로 예배 시작',
      description:
          '고인이 좋아하던 찬송가 또는 추모에 맞는 찬송을 함께 부릅니다.\n추천: 찬송가 488장 "주 날개 밑"',
      icon: Icons.music_note_outlined,
    ),
    _GuideStep(
      order: 3,
      title: '기도',
      subtitle: '고인과 유족을 위한 기도',
      description:
          '위로와 평안을 구하며, 고인의 영혼과 남은 가족을 위해 기도합니다.',
      icon: Icons.volunteer_activism_outlined,
    ),
    _GuideStep(
      order: 4,
      title: '성경 봉독',
      subtitle: '추모 성경 말씀 낭독',
      description:
          '시편 23편 "여호와는 나의 목자시니"\n'
          '요한복음 14:1-3 "너희는 마음에 근심하지 말라"\n'
          '고린도전서 15:55-57 "사망아 너의 승리가 어디 있느냐"',
      icon: Icons.menu_book_outlined,
    ),
    _GuideStep(
      order: 5,
      title: '말씀/추도사',
      subtitle: '목사님 말씀 또는 추도사',
      description:
          '목사님이 위로의 말씀을 전하거나, 가족이 고인에 대한 추도사를 낭독합니다.',
      icon: Icons.record_voice_over_outlined,
    ),
    _GuideStep(
      order: 6,
      title: '기도',
      subtitle: '마무리 기도',
      description:
          '고인의 안식과 유족에게 위로를 구하는 마무리 기도를 드립니다.',
      icon: Icons.volunteer_activism_outlined,
    ),
    _GuideStep(
      order: 7,
      title: '찬송',
      subtitle: '마무리 찬송',
      description:
          '은혜와 위로의 찬송을 함께 부르며 예배를 마무리합니다.\n추천: 찬송가 543장 "주의 사랑이 나를"',
      icon: Icons.music_note_outlined,
    ),
    _GuideStep(
      order: 8,
      title: '축도',
      subtitle: '축복의 기도로 마침',
      description:
          '목사님이 참석자들에게 축복의 말씀을 선포하며 추도 예배를 마칩니다.',
      icon: Icons.church_outlined,
    ),
  ];

  static const _bibleVerses = [
    '시편 23:1-6 — "여호와는 나의 목자시니 내게 부족함이 없으리로다"',
    '요한복음 14:1-3 — "너희는 마음에 근심하지 말라"',
    '고린도전서 15:55-57 — "사망아 너의 승리가 어디 있느냐"',
    '데살로니가전서 4:13-14 — "소망 없는 다른 이와 같이 슬퍼하지 않게 하려 함이라"',
    '요한계시록 21:4 — "다시는 사망이 없고 애통하는 것이나 곡하는 것이 없으리니"',
  ];

  static const _checklistItems = [
    '성경',
    '찬송가',
    '꽃 (헌화용)',
    '고인 사진',
    '촛불',
    '추도사 원고',
    '간식/다과 (교제 시간용)',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // ── 헤더 ──
        _buildHeader(
          icon: Icons.church_outlined,
          title: '추도 예배',
          subtitle: '기독교/천주교식 추모 예배 순서입니다\n교단과 교회마다 차이가 있을 수 있습니다',
          color: const Color(0xFF2563EB), // Blue-600
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── 순서 카드 ──
        ..._steps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _StepCard(
              step: step,
              accentColor: const Color(0xFF2563EB),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── 추천 성경 구절 ──
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bookmark_outlined,
                    size: 18,
                    color: const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '추천 성경 구절',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ..._bibleVerses.map(
                (verse) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u2022 ',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF2563EB),
                          height: 1.5,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          verse,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── 준비물 체크리스트 ──
        _buildChecklistSection(
          title: '준비물 체크리스트',
          items: _checklistItems,
          checkedItems: _checkedItems,
          accentColor: const Color(0xFF2563EB),
          onToggle: (index) {
            setState(() {
              if (_checkedItems.contains(index)) {
                _checkedItems.remove(index);
              } else {
                _checkedItems.add(index);
              }
            });
            _saveCheckedItems();
          },
        ),
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// ── 탭 3: 자유 (현대식) ─────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════

class _ModernTab extends ConsumerStatefulWidget {
  const _ModernTab();

  @override
  ConsumerState<_ModernTab> createState() => _ModernTabState();
}

class _ModernTabState extends ConsumerState<_ModernTab>
    with AutomaticKeepAliveClientMixin {
  final Set<int> _checkedItems = {};

  @override
  void initState() {
    super.initState();
    _loadCheckedItems();
  }

  Future<void> _loadCheckedItems() async {
    final repo = ref.read(settingsRepositoryProvider);
    final raw = await repo.get(SettingsKey.ritualCheckModern);
    if (!mounted) return;
    if (raw != null && raw.isNotEmpty) {
      setState(() {
        _checkedItems
          ..clear()
          ..addAll(raw.split(',').map((e) => int.tryParse(e.trim())).whereType<int>());
      });
    }
  }

  Future<void> _saveCheckedItems() async {
    final repo = ref.read(settingsRepositoryProvider);
    final value = _checkedItems.toList()..sort();
    await repo.set(SettingsKey.ritualCheckModern, value.join(','));
  }

  static const _steps = [
    _GuideStep(
      order: 1,
      title: '묵념',
      subtitle: '고인을 떠올리며 잠시 묵념',
      description:
          '1~2분간 눈을 감고 고인과의 소중한 시간을 떠올립니다. '
          '조용한 음악을 배경으로 흘려도 좋습니다.',
      icon: Icons.self_improvement_outlined,
    ),
    _GuideStep(
      order: 2,
      title: '헌화',
      subtitle: '꽃을 놓으며 마음 전하기',
      description:
          '준비한 꽃을 고인의 사진 앞에 놓으며 마음을 전합니다. '
          '고인이 좋아하던 꽃이면 더욱 의미 있습니다.',
      icon: Icons.local_florist_outlined,
    ),
    _GuideStep(
      order: 3,
      title: '추억 나눔',
      subtitle: '고인과의 추억 이야기하기',
      description:
          '가족들이 돌아가며 고인과의 추억을 자유롭게 이야기합니다. '
          '웃음이든 눈물이든 자연스럽게 나누세요.',
      icon: Icons.forum_outlined,
    ),
    _GuideStep(
      order: 4,
      title: '편지 낭독',
      subtitle: '고인에게 쓴 편지 읽기',
      description:
          '미리 준비한 편지를 소리 내어 읽습니다. '
          '쓰지 못한 이야기, 감사, 그리움을 담아보세요.',
      icon: Icons.mail_outlined,
    ),
    _GuideStep(
      order: 5,
      title: '음악 감상',
      subtitle: '고인이 좋아하던 노래 듣기',
      description:
          '고인이 즐겨 듣던 노래나, 추모 분위기에 맞는 음악을 함께 감상합니다.',
      icon: Icons.headphones_outlined,
    ),
    _GuideStep(
      order: 6,
      title: '기념 촬영',
      subtitle: '가족 사진 남기기',
      description:
          '모인 가족이 함께 사진을 찍으며 오늘을 기록합니다. '
          '고인의 사진과 함께 찍어도 좋습니다.',
      icon: Icons.photo_camera_outlined,
    ),
  ];

  static const _checklistItems = [
    '꽃 (고인이 좋아하던 종류)',
    '고인 사진 / 영정',
    '편지 (고인에게 쓴 것)',
    '음악 재생 준비 (스피커 등)',
    '초 또는 LED 캔들',
    '간단한 다과 / 음료',
    '추억 앨범 또는 영상',
    '카메라 (기념 촬영용)',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // ── 헤더 ──
        _buildHeader(
          icon: Icons.favorite_outlined,
          title: '자유 추모 (리멤버링)',
          subtitle: '형식에 얽매이지 않는 현대식 추모입니다\n가족의 스타일에 맞게 자유롭게 진행하세요',
          color: AppColors.accent,
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── 순서 카드 ──
        ..._steps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _StepCard(step: step, accentColor: AppColors.accent),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── 자유 추모 팁 ──
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outlined,
                    size: 18,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '이런 방법도 있어요',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ..._tips.map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u2022 ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.accent,
                          height: 1.5,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── 준비물 체크리스트 ──
        _buildChecklistSection(
          title: '준비물 체크리스트',
          items: _checklistItems,
          checkedItems: _checkedItems,
          accentColor: AppColors.accent,
          onToggle: (index) {
            setState(() {
              if (_checkedItems.contains(index)) {
                _checkedItems.remove(index);
              } else {
                _checkedItems.add(index);
              }
            });
            _saveCheckedItems();
          },
        ),
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }

  static const _tips = [
    '고인이 좋아하던 음식을 함께 만들어 먹기',
    '고인의 취미를 함께 해보기 (산책, 낚시 등)',
    '고인이 좋아하던 장소 방문하기',
    '영상 편지를 촬영해 기록으로 남기기',
    '가족 모두가 한 줄씩 추모의 글을 남기기',
    'Re-Link에 추억 사진과 음성을 기록하기',
  ];
}

// ════════════════════════════════════════════════════════════════════════════════
// ── 공통 위젯 & 모델 ──────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════

/// 순서 데이터 모델
class _GuideStep {
  const _GuideStep({
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

/// 헤더 카드 빌더 (탭 공통)
Widget _buildHeader({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
}) {
  return GlassCard(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textTertiary,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

/// 순서 단계 카드 (번호 + 아이콘 + 제목 + 설명)
class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.accentColor,
  });

  final _GuideStep step;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 순서 번호 원
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withAlpha(30),
            ),
            child: Center(
              child: Text(
                '${step.order}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
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
                    Icon(step.icon, size: 18, color: accentColor),
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
    );
  }
}

/// 인터랙티브 체크리스트 섹션 빌더
Widget _buildChecklistSection({
  required String title,
  required List<String> items,
  required Set<int> checkedItems,
  required Color accentColor,
  required ValueChanged<int> onToggle,
}) {
  return GlassCard(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.checklist_outlined,
              size: 18,
              color: accentColor,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${checkedItems.length}/${items.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(items.length, (index) {
          final isChecked = checkedItems.contains(index);
          return GestureDetector(
            onTap: () => onToggle(index),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: isChecked
                          ? accentColor
                          : Colors.transparent,
                      border: Border.all(
                        color: isChecked
                            ? accentColor
                            : AppColors.textTertiary,
                        width: 1.5,
                      ),
                    ),
                    child: isChecked
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      items[index],
                      style: TextStyle(
                        fontSize: 14,
                        color: isChecked
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: AppColors.textTertiary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    ),
  );
}
