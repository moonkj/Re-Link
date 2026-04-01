import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_radius.dart';
import '../../../design/tokens/app_spacing.dart';
import '../services/invite_service.dart';

/// 초대 코드 입력 화면 — 받는 쪽 사용자가 가족 트리에 합류
class JoinFamilyScreen extends ConsumerStatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  ConsumerState<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends ConsumerState<JoinFamilyScreen> {
  // 6자리 코드 입력용 컨트롤러 & 포커스노드
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeFocusNodes =
      List.generate(6, (_) => FocusNode());
  // 이전 값 추적 (모바일 백스페이스 감지용)
  final List<String> _previousValues = List.generate(6, (_) => '');

  String? _selectedFilePath;
  String? _selectedFileName;
  String? _error;
  bool _isValidating = false;

  String get _enteredCode =>
      _codeControllers.map((c) => c.text.toUpperCase()).join();

  bool get _isCodeComplete => _enteredCode.length == 6;
  bool get _hasFile => _selectedFilePath != null;
  bool get _canSubmit => _isCodeComplete && _hasFile && !_isValidating;

  @override
  void initState() {
    super.initState();
    // 첫 필드에 자동 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codeFocusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _codeFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ── 파일 선택 ───────────────────────────────────────────────────────────────

  Future<void> _pickRlinkFile() async {
    HapticService.light();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['rlink'],
      );
      if (result == null || result.files.isEmpty) return;

      final path = result.files.first.path;
      if (path == null) return;

      setState(() {
        _selectedFilePath = path;
        _selectedFileName = result.files.first.name;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = '파일을 선택할 수 없습니다: $e';
      });
    }
  }

  // ── 검증 및 합류 ─────────────────────────────────────────────────────────────

  Future<void> _validateAndJoin() async {
    if (!_canSubmit) return;
    HapticService.medium();

    setState(() {
      _isValidating = true;
      _error = null;
    });

    try {
      final file = File(_selectedFilePath!);
      if (!await file.exists()) {
        setState(() {
          _error = '선택한 파일을 찾을 수 없습니다.';
          _isValidating = false;
        });
        return;
      }

      // .rlink ZIP 내 manifest.json 읽기
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // manifest.json 찾기
      final manifestFile = archive.findFile('manifest.json');

      if (manifestFile == null) {
        setState(() {
          _error = '유효하지 않은 .rlink 파일입니다.\n(manifest.json을 찾을 수 없습니다)';
          _isValidating = false;
        });
        return;
      }

      // manifest 파싱
      final manifestContent = utf8.decode(manifestFile.content as List<int>);
      final manifestJson =
          jsonDecode(manifestContent) as Map<String, dynamic>;

      // invite_code 필드 확인
      final inviteCode = manifestJson['invite_code'] as String?;

      if (inviteCode != null) {
        // 코드가 있으면 검증
        final normalizedInput = _enteredCode.toUpperCase().trim();
        final normalizedCode = inviteCode.toUpperCase().trim();

        if (normalizedInput != normalizedCode) {
          HapticService.heavy();
          setState(() {
            _error = '초대 코드가 일치하지 않습니다.\n코드를 다시 확인해주세요.';
            _isValidating = false;
          });
          return;
        }
      }
      // invite_code가 없는 경우 (이전 버전 백업) — 코드 검증 건너뜀

      if (!mounted) return;

      // 검증 성공 → merge preview 화면으로 이동
      HapticService.celebration();
      context.push(
        '${AppRoutes.mergePreview}?path=${Uri.encodeComponent(_selectedFilePath!)}',
      );
    } catch (e) {
      HapticService.heavy();
      setState(() {
        _error = '파일 검증에 실패했습니다.\n올바른 .rlink 파일인지 확인해주세요.';
      });
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  // ── 코드 입력 핸들러 ────────────────────────────────────────────────────────

  void _onCodeChanged(int index, String value) {
    if (value.length > 1) {
      // 붙여넣기 처리
      _handlePaste(value);
      _previousValues[index] = _codeControllers[index].text;
      return;
    }

    // 백스페이스 감지 (이전 값이 있었는데 비어짐 → 이전 필드로 이동)
    if (value.isEmpty && _previousValues[index].isNotEmpty) {
      _previousValues[index] = '';
      if (index > 0) {
        _codeFocusNodes[index - 1].requestFocus();
      }
      setState(() => _error = null);
      return;
    }

    // 빈 필드에서 백스페이스 (모바일에서는 onChanged가 호출되지 않을 수 있음)
    if (value.isEmpty && _previousValues[index].isEmpty && index > 0) {
      _handleBackspace(index);
      setState(() => _error = null);
      return;
    }

    // 대문자 변환
    if (value.isNotEmpty) {
      _codeControllers[index].text = value.toUpperCase();
      _codeControllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: _codeControllers[index].text.length),
      );
    }

    _previousValues[index] = _codeControllers[index].text;

    setState(() {
      _error = null;
    });

    // 다음 필드로 자동 이동
    if (value.isNotEmpty && index < 5) {
      _codeFocusNodes[index + 1].requestFocus();
    }
  }

  /// 백스페이스 감지 (빈 필드에서 이전 필드로 이동)
  void _handleBackspace(int index) {
    if (index > 0) {
      _codeControllers[index - 1].clear();
      _previousValues[index - 1] = '';
      _codeFocusNodes[index - 1].requestFocus();
    }
  }

  void _handlePaste(String value) {
    // 하이픈 제거 후 영숫자만 추출
    final cleaned =
        value.replaceAll('-', '').replaceAll(' ', '').toUpperCase().trim();
    final chars = cleaned.characters.take(6).toList();

    for (var i = 0; i < 6; i++) {
      if (i < chars.length) {
        _codeControllers[i].text = chars[i];
      } else {
        _codeControllers[i].clear();
      }
    }

    // 포커스를 마지막 입력 다음 필드 또는 마지막 필드로
    final nextIndex = chars.length.clamp(0, 5);
    _codeFocusNodes[nextIndex].requestFocus();

    setState(() {
      _error = null;
    });
  }

  // ── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '가족 합류',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            // ── 헤더 설명 ─────────────────────────────────────────────────
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryMint, AppColors.primaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      Icons.group_add_rounded,
                      color: AppColors.onPrimary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '가족 트리에 합류하세요',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '가족이 공유한 초대 코드와\n.rlink 파일로 같은 가계도에 합류합니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Step 1: 초대 코드 입력 ────────────────────────────────────
            _StepHeader(
              number: '1',
              title: '초대 코드 입력',
              isCompleted: _isCodeComplete,
            ),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Text(
                    '가족에게 전달받은 6자리 코드를 입력하세요',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildCodeInputRow(),
                  const SizedBox(height: AppSpacing.md),
                  if (_isCodeComplete)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            color: AppColors.success, size: 16),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          InviteService.formatCode(_enteredCode),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Step 2: .rlink 파일 선택 ──────────────────────────────────
            _StepHeader(
              number: '2',
              title: '.rlink 파일 선택',
              isCompleted: _hasFile,
            ),
            const SizedBox(height: AppSpacing.md),
            if (_hasFile)
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success.withAlpha(25),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: AppColors.success,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFileName ?? '파일 선택됨',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '파일 준비 완료',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickRlinkFile,
                      child: Text(
                        '변경',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  onPressed: _pickRlinkFile,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_rounded,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '파일 선택',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),

            // ── 에러 메시지 ──────────────────────────────────────────────
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.error,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── 합류 버튼 ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: PrimaryGlassButton(
                label: '가족 트리 합류',
                icon: Icon(Icons.group_add_rounded,
                    color: AppColors.onPrimary, size: 20),
                isLoading: _isValidating,
                onPressed: _canSubmit ? _validateAndJoin : null,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── 안내 사항 ────────────────────────────────────────────────
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: AppColors.info),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '합류 방법',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _InstructionRow(
                    number: '1',
                    text: '가족이 보내준 6자리 초대 코드를 입력하세요',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InstructionRow(
                    number: '2',
                    text: '공유받은 .rlink 파일을 선택하세요',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InstructionRow(
                    number: '3',
                    text: '코드가 확인되면 가족 트리 미리보기가 표시됩니다',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InstructionRow(
                    number: '4',
                    text: '병합을 확인하면 가족 트리에 합류됩니다',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  // ── 6자리 코드 입력 행 ──────────────────────────────────────────────────────

  Widget _buildCodeInputRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        final isDash = i == 3; // 3번째 이후에 대시 표시

        return Row(
          children: [
            if (isDash)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  '-',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            SizedBox(
              width: 44,
              height: 56,
              child: TextField(
                controller: _codeControllers[i],
                focusNode: _codeFocusNodes[i],
                textAlign: TextAlign.center,
                maxLength: 1,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[A-Za-z0-9]'),
                  ),
                ],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.bgElevated,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMd,
                    borderSide: BorderSide(
                      color: AppColors.glassBorder,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMd,
                    borderSide: BorderSide(
                      color: AppColors.glassBorder,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMd,
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2.0,
                    ),
                  ),
                ),
                onChanged: (value) => _onCodeChanged(i, value),
                onTap: () {
                  // 탭 시 기존 텍스트 선택하여 덮어쓰기 용이하게
                  _codeControllers[i].selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _codeControllers[i].text.length,
                  );
                },
              ),
            ),
            if (!isDash && i < 5 && i != 2)
              const SizedBox(width: AppSpacing.sm),
          ],
        );
      }),
    );
  }
}

// ── 단계 헤더 ─────────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.number,
    required this.title,
    required this.isCompleted,
  });

  final String number;
  final String title;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppColors.success : AppColors.primary,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: AppColors.onPrimary, size: 16)
                : Text(
                    number,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimary,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── 안내 행 ───────────────────────────────────────────────────────────────────

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({
    required this.number,
    required this.text,
  });

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withAlpha(25),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
