/// 개인정보 처리방침 화면
library;

import 'package:flutter/material.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_radius.dart';
import '../../../design/tokens/app_spacing.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '개인정보 처리방침',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: _PrivacyContent(),
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 프라이버시 약속 배너 ──
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          decoration: BoxDecoration(
            color: const Color(0xFF6EC6CA).withAlpha(20),
            borderRadius: AppRadius.radiusMd,
            border: Border.all(
                color: const Color(0xFF6EC6CA).withAlpha(50)),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined,
                  color: const Color(0xFF6EC6CA), size: 28),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Re-Link는 당신의 가족 데이터를 팔지 않습니다.\n'
                  '광고 타겟팅·AI 학습에 사용하지 않습니다.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        _Heading('Re-Link 개인정보 처리방침'),
        _Body('최종 수정일: 2026년 1월 1일'),
        SizedBox(height: AppSpacing.lg),

        _SubHeading('1. 수집하는 정보'),
        _Body(
          'Re-Link는 외부 서버 또는 클라우드 서버를 운영하지 않습니다. '
          '앱 내에서 입력하는 모든 데이터(이름, 사진, 음성, 메모 등)는 '
          '오직 사용자의 기기(로컬 SQLite DB 및 파일 시스템)에만 저장됩니다. '
          'Re-Link 개발자는 해당 데이터에 접근하거나 수집하지 않습니다.',
        ),
        SizedBox(height: AppSpacing.md),

        _SubHeading('2. 클라우드 백업'),
        _Body(
          'iOS에서 iCloud Drive 백업, Android에서 Google Drive 백업 기능을 선택적으로 사용할 수 있습니다. '
          '백업 파일(.rlink)은 사용자 본인의 Apple ID 또는 Google 계정 저장 공간에 저장되며, '
          'Re-Link 개발자는 해당 파일에 접근할 수 없습니다. '
          '각 서비스의 개인정보 처리방침은 Apple 및 Google 정책을 따릅니다.',
        ),
        SizedBox(height: AppSpacing.md),

        _SubHeading('3. 광고'),
        _Body(
          'Free 및 Basic 플랜에서는 Google AdMob 광고가 표시됩니다. '
          'AdMob은 광고 최적화를 위해 기기 식별자를 사용할 수 있습니다. '
          'AdMob의 데이터 수집에 대한 자세한 내용은 Google의 개인정보 처리방침을 참조하세요. '
          'Premium 플랜에서는 광고가 표시되지 않습니다.',
        ),
        SizedBox(height: AppSpacing.md),

        _SubHeading('4. 앱 내 구매'),
        _Body(
          '인앱 구매는 Apple App Store 및 Google Play Store를 통해 처리됩니다. '
          '결제 정보는 Re-Link 앱에 저장되지 않으며, 각 플랫폼의 결제 시스템이 처리합니다.',
        ),
        SizedBox(height: AppSpacing.md),

        _SubHeading('5. 접근 권한'),
        _Body(
          'Re-Link는 다음 권한을 요청할 수 있습니다:\n'
          '• 마이크: 음성 메모 녹음 (명시적 허용 시에만)\n'
          '• 사진 라이브러리: 사진 첨부 (명시적 허용 시에만)\n'
          '• 카메라: 직접 촬영 (명시적 허용 시에만)\n\n'
          '모든 권한은 해당 기능 사용 시에만 요청하며, '
          '수집된 미디어는 기기 내에만 저장됩니다.',
        ),
        SizedBox(height: AppSpacing.md),

        _SubHeading('6. 데이터 삭제'),
        _Body(
          '앱을 삭제하면 기기에 저장된 모든 Re-Link 데이터가 함께 삭제됩니다. '
          'iCloud 또는 Google Drive에 백업된 .rlink 파일은 각 플랫폼의 '
          '저장 관리 메뉴에서 직접 삭제할 수 있습니다.',
        ),
        SizedBox(height: AppSpacing.md),

        _SubHeading('7. 미성년자 보호'),
        _Body(
          'Re-Link는 13세 미만 아동으로부터 의도적으로 개인정보를 수집하지 않습니다. '
          '앱은 가족 구성원 정보를 보호자가 대신 입력하는 방식으로 운영됩니다.',
        ),
        SizedBox(height: AppSpacing.md),

        _SubHeading('8. 문의'),
        _Body(
          '개인정보 처리방침에 대한 문의 사항이 있으시면 아래로 연락해 주세요.\n'
          '이메일: relink.app@gmail.com',
        ),
        SizedBox(height: AppSpacing.xl),

        _Body(
          '© 2026 Re-Link. 모든 권리 보유.',
          color: AppColors.textTertiary,
        ),
        SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _SubHeading extends StatelessWidget {
  const _SubHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.text, {this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.65,
        color: color ?? AppColors.textSecondary,
      ),
    );
  }
}
