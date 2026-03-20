// 가족 관련 데일리 프롬프트 데이터
//
// 100개의 한국어 가족 질문을 카테고리별로 분류.
// 서버 없이 로컬에서 날짜 기반으로 매일 하나씩 표시.

/// 프롬프트 데이터 모델
class FamilyPrompt {
  const FamilyPrompt({
    required this.id,
    required this.category,
    required this.question,
    this.relatedRelation,
  });

  final int id;
  final String category;
  final String question;

  /// 힌트: 관련 관계 유형 (부모, 조부모, 형제 등)
  final String? relatedRelation;
}

/// 프롬프트 카테고리 아이콘 매핑
const Map<String, String> promptCategoryIcons = {
  '고향': '🏡',
  '어린시절': '👶',
  '음식': '🍚',
  '명절': '🎊',
  '관계': '💑',
  '추억': '📸',
  '꿈': '🌟',
  '가치관': '💎',
};

/// 100개 가족 프롬프트 정적 목록
const List<FamilyPrompt> familyPrompts = [
  // ── 고향 (13개) ─────────────────────────────────────────────────────────
  FamilyPrompt(id: 0, category: '고향', question: '아버지의 고향은 어디인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 1, category: '고향', question: '어머니의 고향은 어디인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 2, category: '고향', question: '할아버지가 태어나신 마을은 어떤 곳이었나요?', relatedRelation: 'grandparent'),
  FamilyPrompt(id: 3, category: '고향', question: '할머니의 고향에는 어떤 특산물이 있었나요?', relatedRelation: 'grandparent'),
  FamilyPrompt(id: 4, category: '고향', question: '부모님의 고향집은 어떤 모습이었나요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 5, category: '고향', question: '고향에 아직 살고 있는 친척이 있나요?'),
  FamilyPrompt(id: 6, category: '고향', question: '가족이 지금 사는 곳으로 이사 온 이유는 무엇인가요?'),
  FamilyPrompt(id: 7, category: '고향', question: '부모님이 자라신 동네의 풍경은 어떠했나요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 8, category: '고향', question: '고향에서 가장 기억에 남는 장소는 어디인가요?'),
  FamilyPrompt(id: 9, category: '고향', question: '외할머니 댁은 어디에 있었나요?', relatedRelation: 'grandparent'),
  FamilyPrompt(id: 10, category: '고향', question: '가족 중 해외에서 살았던 분이 계신가요?'),
  FamilyPrompt(id: 11, category: '고향', question: '부모님이 고향을 떠나실 때 어떤 기분이셨을까요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 12, category: '고향', question: '고향의 사투리 중 기억나는 표현이 있나요?'),

  // ── 어린시절 (13개) ──────────────────────────────────────────────────────
  FamilyPrompt(id: 13, category: '어린시절', question: '아버지의 어린 시절 별명은 무엇이었나요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 14, category: '어린시절', question: '어머니가 어렸을 때 가장 좋아했던 놀이는 무엇인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 15, category: '어린시절', question: '할아버지는 학교 다닐 때 어떤 학생이셨나요?', relatedRelation: 'grandparent'),
  FamilyPrompt(id: 16, category: '어린시절', question: '할머니의 어린 시절 꿈은 무엇이었나요?', relatedRelation: 'grandparent'),
  FamilyPrompt(id: 17, category: '어린시절', question: '부모님의 첫 번째 학교는 어디였나요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 18, category: '어린시절', question: '어렸을 때 가족과 함께 자주 갔던 곳은 어디인가요?'),
  FamilyPrompt(id: 19, category: '어린시절', question: '형제자매와 가장 많이 싸웠던 이유는 무엇인가요?', relatedRelation: 'sibling'),
  FamilyPrompt(id: 20, category: '어린시절', question: '어린 시절 가장 무서웠던 경험은 무엇인가요?'),
  FamilyPrompt(id: 21, category: '어린시절', question: '부모님이 어렸을 때 갖고 놀던 장난감은 무엇인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 22, category: '어린시절', question: '가족 중 어린 시절 사고를 친 에피소드가 있나요?'),
  FamilyPrompt(id: 23, category: '어린시절', question: '아버지는 어렸을 때 어떤 과목을 좋아하셨나요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 24, category: '어린시절', question: '어머니의 소녀 시절 사진을 본 적이 있나요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 25, category: '어린시절', question: '어린 시절 가장 좋아했던 TV 프로그램은 무엇이었나요?'),

  // ── 음식 (13개) ──────────────────────────────────────────────────────────
  FamilyPrompt(id: 26, category: '음식', question: '어머니가 가장 좋아하시는 음식은 무엇인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 27, category: '음식', question: '할머니가 가장 잘 만드시던 음식은 무엇인가요?', relatedRelation: 'grandparent'),
  FamilyPrompt(id: 28, category: '음식', question: '아버지가 즐겨 드시는 안주는 무엇인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 29, category: '음식', question: '가족 모임에 빠지지 않는 음식은 무엇인가요?'),
  FamilyPrompt(id: 30, category: '음식', question: '어머니의 손맛 비법이 있다면 무엇인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 31, category: '음식', question: '할아버지가 좋아하시던 과일은 무엇인가요?', relatedRelation: 'grandparent'),
  FamilyPrompt(id: 32, category: '음식', question: '가족끼리 외식할 때 주로 어디에 가나요?'),
  FamilyPrompt(id: 33, category: '음식', question: '부모님이 절대 못 드시는 음식이 있나요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 34, category: '음식', question: '집에서 전해져 내려오는 특별한 레시피가 있나요?'),
  FamilyPrompt(id: 35, category: '음식', question: '아이들이 가장 좋아하는 엄마/아빠 요리는 무엇인가요?', relatedRelation: 'child'),
  FamilyPrompt(id: 36, category: '음식', question: '명절에 꼭 만드는 전통 음식은 무엇인가요?'),
  FamilyPrompt(id: 37, category: '음식', question: '가족이 함께 요리한 적이 있나요? 무엇을 만들었나요?'),
  FamilyPrompt(id: 38, category: '음식', question: '부모님의 첫 데이트 때 드신 음식을 알고 있나요?', relatedRelation: 'parent'),

  // ── 명절 (12개) ──────────────────────────────────────────────────────────
  FamilyPrompt(id: 39, category: '명절', question: '가족과 함께한 가장 행복했던 명절은 언제인가요?'),
  FamilyPrompt(id: 40, category: '명절', question: '설날에 꼭 하는 가족 전통이 있나요?'),
  FamilyPrompt(id: 41, category: '명절', question: '추석에 가장 기억에 남는 순간은 무엇인가요?'),
  FamilyPrompt(id: 42, category: '명절', question: '가족 생일은 보통 어떻게 보내나요?'),
  FamilyPrompt(id: 43, category: '명절', question: '어른들에게 세배할 때 들었던 재미있는 덕담이 있나요?'),
  FamilyPrompt(id: 44, category: '명절', question: '명절에 친척들이 모이면 주로 무엇을 하나요?'),
  FamilyPrompt(id: 45, category: '명절', question: '가족 여행 중 가장 기억에 남는 여행은 어디였나요?'),
  FamilyPrompt(id: 46, category: '명절', question: '어버이날에 부모님께 해 드린 특별한 일이 있나요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 47, category: '명절', question: '크리스마스에 가족끼리 하는 특별한 활동이 있나요?'),
  FamilyPrompt(id: 48, category: '명절', question: '가장 많은 가족이 모였던 명절은 언제였나요?'),
  FamilyPrompt(id: 49, category: '명절', question: '명절에 벌어진 재미있는 해프닝이 있나요?'),
  FamilyPrompt(id: 50, category: '명절', question: '가족 기념일 중 가장 중요하게 여기는 날은 언제인가요?'),

  // ── 관계 (13개) ──────────────────────────────────────────────────────────
  FamilyPrompt(id: 51, category: '관계', question: '부모님이 처음 만난 이야기를 알고 있나요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 52, category: '관계', question: '할아버지와 할머니의 러브스토리는 어떠했나요?', relatedRelation: 'grandparent'),
  FamilyPrompt(id: 53, category: '관계', question: '형제자매 중 가장 닮은 사람은 누구인가요?', relatedRelation: 'sibling'),
  FamilyPrompt(id: 54, category: '관계', question: '가족 중 가장 유머 감각이 뛰어난 사람은 누구인가요?'),
  FamilyPrompt(id: 55, category: '관계', question: '부모님이 가장 자주 하시는 다툼의 주제는 무엇인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 56, category: '관계', question: '가족 중 나와 성격이 가장 비슷한 사람은 누구인가요?'),
  FamilyPrompt(id: 57, category: '관계', question: '가장 가까운 사촌은 누구이고 왜 가까운가요?', relatedRelation: 'cousin'),
  FamilyPrompt(id: 58, category: '관계', question: '부모님이 결혼을 결심한 계기를 알고 있나요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 59, category: '관계', question: '가족 중 가장 엄격한 분은 누구인가요?'),
  FamilyPrompt(id: 60, category: '관계', question: '형제자매끼리 화해한 감동적인 에피소드가 있나요?', relatedRelation: 'sibling'),
  FamilyPrompt(id: 61, category: '관계', question: '어머니와 아버지 중 누가 더 다정하신가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 62, category: '관계', question: '가족 중 연락이 뜸해진 분이 있나요? 이유를 알고 있나요?'),
  FamilyPrompt(id: 63, category: '관계', question: '부모님이 서로에게 부르는 애칭이 있나요?', relatedRelation: 'parent'),

  // ── 추억 (12개) ──────────────────────────────────────────────────────────
  FamilyPrompt(id: 64, category: '추억', question: '할머니가 자주 해주시던 이야기가 있나요?', relatedRelation: 'grandparent'),
  FamilyPrompt(id: 65, category: '추억', question: '가족 사진첩에서 가장 좋아하는 사진은 무엇인가요?'),
  FamilyPrompt(id: 66, category: '추억', question: '가족과 함께한 가장 웃긴 에피소드는 무엇인가요?'),
  FamilyPrompt(id: 67, category: '추억', question: '부모님이 자주 들려주시던 옛날이야기가 있나요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 68, category: '추억', question: '가장 소중한 가족 물건이 있다면 무엇인가요?'),
  FamilyPrompt(id: 69, category: '추억', question: '가족이 함께 극복한 어려운 시기가 있나요?'),
  FamilyPrompt(id: 70, category: '추억', question: '할아버지에게 들은 가장 인상 깊은 말씀은 무엇인가요?', relatedRelation: 'grandparent'),
  FamilyPrompt(id: 71, category: '추억', question: '가족 중 누군가가 크게 아팠을 때의 기억이 있나요?'),
  FamilyPrompt(id: 72, category: '추억', question: '어릴 때 부모님과 함께 놀았던 추억이 있나요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 73, category: '추억', question: '가족끼리 깜짝 파티를 한 적이 있나요?'),
  FamilyPrompt(id: 74, category: '추억', question: '세대를 넘어 전해지는 가족 일화가 있나요?'),
  FamilyPrompt(id: 75, category: '추억', question: '가족과 떨어져 있을 때 가장 그리웠던 순간은 언제인가요?'),

  // ── 꿈 (12개) ────────────────────────────────────────────────────────────
  FamilyPrompt(id: 76, category: '꿈', question: '아버지가 원래 되고 싶었던 직업은 무엇인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 77, category: '꿈', question: '어머니의 젊은 시절 꿈은 무엇이었나요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 78, category: '꿈', question: '할아버지가 이루지 못한 꿈이 있으셨나요?', relatedRelation: 'grandparent'),
  FamilyPrompt(id: 79, category: '꿈', question: '가족 중 자기 꿈을 이룬 분이 있나요?'),
  FamilyPrompt(id: 80, category: '꿈', question: '부모님이 나에게 바라시는 미래는 어떤 모습인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 81, category: '꿈', question: '가족이 함께 이루고 싶은 목표가 있나요?'),
  FamilyPrompt(id: 82, category: '꿈', question: '은퇴 후 부모님이 하고 싶은 일은 무엇인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 83, category: '꿈', question: '가족 중 가장 모험적인 분은 누구인가요?'),
  FamilyPrompt(id: 84, category: '꿈', question: '온 가족이 함께 가보고 싶은 여행지는 어디인가요?'),
  FamilyPrompt(id: 85, category: '꿈', question: '할머니의 젊은 시절 포부를 들어본 적이 있나요?', relatedRelation: 'grandparent'),
  FamilyPrompt(id: 86, category: '꿈', question: '부모님이 다시 젊어진다면 무엇을 하고 싶으시대요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 87, category: '꿈', question: '가족의 미래에 대해 어떤 희망을 품고 있나요?'),

  // ── 가치관 (12개) ────────────────────────────────────────────────────────
  FamilyPrompt(id: 88, category: '가치관', question: '부모님이 가장 중요하게 여기시는 가치는 무엇인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 89, category: '가치관', question: '할아버지의 인생 좌우명은 무엇이었나요?', relatedRelation: 'grandparent'),
  FamilyPrompt(id: 90, category: '가치관', question: '가족에게 전해 내려오는 교훈이 있나요?'),
  FamilyPrompt(id: 91, category: '가치관', question: '부모님에게 가장 큰 감사를 느끼는 순간은 언제인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 92, category: '가치관', question: '가족이 함께 지키는 규칙이나 약속이 있나요?'),
  FamilyPrompt(id: 93, category: '가치관', question: '어머니가 자주 하시는 조언은 무엇인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 94, category: '가치관', question: '아버지에게 배운 가장 중요한 것은 무엇인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 95, category: '가치관', question: '가족 간의 갈등을 해결하는 방법이 있나요?'),
  FamilyPrompt(id: 96, category: '가치관', question: '할머니가 손주들에게 꼭 하시던 말씀이 있나요?', relatedRelation: 'grandparent'),
  FamilyPrompt(id: 97, category: '가치관', question: '가족의 전통 중 꼭 이어가고 싶은 것은 무엇인가요?'),
  FamilyPrompt(id: 98, category: '가치관', question: '부모님 세대와 나의 가치관이 다른 부분은 무엇인가요?', relatedRelation: 'parent'),
  FamilyPrompt(id: 99, category: '가치관', question: '우리 가족을 한 단어로 표현한다면 무엇인가요?'),
];
