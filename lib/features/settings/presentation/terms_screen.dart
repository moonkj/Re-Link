/// 이용약관 화면
library;

import 'package:flutter/material.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          '이용약관',
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
        child: _TermsContent(),
      ),
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading('Re-Link 이용약관'),
        _Body('최종 수정일: 2026년 1월 1일'),
        SizedBox(height: AppSpacing.lg),

        // 제1조
        _Heading('제1조 (목적)'),
        _Body(
          '이 약관은 Re-Link(이하 "앱")가 제공하는 가족 기억 저장 서비스의 이용 조건 및 절차에 관한 사항을 규정함을 목적으로 합니다.',
        ),
        SizedBox(height: AppSpacing.md),

        // 제2조
        _Heading('제2조 (서비스 정의)'),
        _Body(
          '본 앱은 노드 기반 가족 트리를 통해 사진, 음성, 메모를 기기에 저장하고 관리할 수 있는 로컬 퍼스트 서비스입니다. 모든 데이터는 사용자의 기기에 저장되며, 개발자의 서버로 전송되지 않습니다.',
        ),
        SizedBox(height: AppSpacing.md),

        // 제3조
        _Heading('제3조 (서비스 이용)'),
        _Body('① 본 앱은 iOS 및 Android 기기에서 이용할 수 있습니다.\n'
            '② 일부 기능은 유료 플랜(플러스, 패밀리, 패밀리플러스) 구매/구독 후 이용 가능합니다.\n'
            '③ 서비스 이용을 위해 회원가입이나 계정 생성은 불필요합니다.'),
        SizedBox(height: AppSpacing.md),

        // 제4조
        _Heading('제4조 (요금제 및 결제)'),
        _Body('① 요금제는 1회성 구매(플러스) 및 구독(패밀리, 패밀리플러스) 방식입니다.\n'
            '② 무료 플랜: ₩0, 플러스: ₩4,900(1회), 패밀리: ₩3,900/월(₩37,900/년), 패밀리플러스: ₩6,900/월(₩61,900/년)\n'
            '③ 구독은 자동 갱신되며, 해지 시 다음 결제일부터 무료 플랜으로 전환됩니다.\n'
            '④ 결제는 각 플랫폼(App Store / Google Play)의 인앱 결제를 통해 이루어집니다.\n'
            '⑤ 환불은 각 플랫폼의 환불 정책에 따릅니다.'),
        SizedBox(height: AppSpacing.md),

        // 제5조
        _Heading('제5조 (데이터 및 백업)'),
        _Body('① 모든 데이터는 사용자의 기기에 로컬 저장됩니다.\n'
            '② 앱 삭제 시 기기 내 데이터가 삭제될 수 있으므로, 정기적인 백업을 권장합니다.\n'
            '③ iCloud(iOS) 또는 Google Drive(Android)를 통한 클라우드 백업 기능을 제공합니다.\n'
            '④ 클라우드 백업 데이터는 사용자의 클라우드 계정에 저장되며, 개발자는 접근할 수 없습니다.'),
        SizedBox(height: AppSpacing.md),

        // 제6조
        _Heading('제6조 (금지 행위)'),
        _Body('사용자는 다음 행위를 해서는 안 됩니다.\n'
            '① 타인의 개인정보를 무단으로 수집·저장하는 행위\n'
            '② 앱을 역공학(리버스 엔지니어링)하거나 소스 코드를 추출하는 행위\n'
            '③ 관련 법령을 위반하는 콘텐츠를 저장하는 행위'),
        SizedBox(height: AppSpacing.md),

        // 제7조
        _Heading('제7조 (서비스 변경 및 중단)'),
        _Body('① 개발자는 서비스 내용을 변경하거나 종료할 수 있습니다.\n'
            '② 서비스 종료 시 사용자에게 사전 고지하며, 기기 내 데이터는 사용자가 계속 보유합니다.'),
        SizedBox(height: AppSpacing.md),

        // 제8조
        _Heading('제8조 (면책 조항)'),
        _Body('① 개발자는 사용자의 귀책으로 인한 데이터 손실에 대해 책임을 지지 않습니다.\n'
            '② 기기 고장, 앱 삭제, 백업 미실시로 인한 데이터 손실은 사용자 책임입니다.\n'
            '③ 앱은 가족 기억 보존을 위한 도구이며, 법적 문서로서의 효력은 없습니다.'),
        SizedBox(height: AppSpacing.md),

        // 제9조
        _Heading('제9조 (준거법 및 관할)'),
        _Body('본 약관은 대한민국 법률에 따라 해석되며, 분쟁 발생 시 대한민국 법원을 관할 법원으로 합니다.'),
        SizedBox(height: AppSpacing.md),

        // 제10조
        _Heading('제10조 (문의)'),
        _Body('서비스 이용 관련 문의사항은 앱 내 피드백 기능 또는 공개 채널을 통해 문의하시기 바랍니다.'),
        SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    );
  }
}
