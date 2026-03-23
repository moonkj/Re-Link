import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design/tokens/app_colors.dart';
import '../../design/tokens/app_radius.dart';
import '../../design/tokens/app_spacing.dart';

/// PIN 다이얼로그 모드
enum PinDialogMode {
  /// 최초 등록 (입력 + 확인)
  register,

  /// 검증 (입력만)
  verify,
}

/// PIN 다이얼로그 결과
class PinDialogResult {
  const PinDialogResult({required this.success, this.pin});

  /// 성공 여부
  final bool success;

  /// 등록/검증된 PIN (성공 시)
  final String? pin;
}

/// 4자리 PIN 입력 다이얼로그
///
/// [mode]가 [PinDialogMode.register]이면 입력 후 확인 단계를 거침.
/// [mode]가 [PinDialogMode.verify]이면 저장된 PIN과 비교.
/// [onForgotPin]이 제공되면 verify 모드에서 "PIN 잊으셨나요?" 링크를 표시.
///
/// 반환: [PinDialogResult] — 성공 시 success=true + pin, 취소 시 null.
Future<PinDialogResult?> showPinDialog({
  required BuildContext context,
  required PinDialogMode mode,
  String? savedPin,
  VoidCallback? onForgotPin,
}) {
  return showDialog<PinDialogResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PinDialogWidget(
      mode: mode,
      savedPin: savedPin,
      onForgotPin: onForgotPin,
    ),
  );
}

class _PinDialogWidget extends StatefulWidget {
  const _PinDialogWidget({
    required this.mode,
    this.savedPin,
    this.onForgotPin,
  });

  final PinDialogMode mode;
  final String? savedPin;
  final VoidCallback? onForgotPin;

  @override
  State<_PinDialogWidget> createState() => _PinDialogWidgetState();
}

class _PinDialogWidgetState extends State<_PinDialogWidget>
    with SingleTickerProviderStateMixin {
  String _input = '';
  String? _firstPin; // register 모드: 첫 번째 입력 저장
  bool _isConfirmStep = false;
  String? _errorMessage;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  String get _title {
    if (widget.mode == PinDialogMode.register) {
      return _isConfirmStep ? 'PIN 확인' : 'PIN 등록';
    }
    return 'PIN 입력';
  }

  String get _subtitle {
    if (widget.mode == PinDialogMode.register) {
      return _isConfirmStep ? '한 번 더 입력해주세요' : '4자리 숫자를 입력해주세요';
    }
    return '"나" 변경을 위해 PIN을 입력해주세요';
  }

  void _onDigit(int digit) {
    if (_input.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() {
      _input += digit.toString();
      _errorMessage = null;
    });
    if (_input.length == 4) {
      _onComplete();
    }
  }

  void _onDelete() {
    if (_input.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _input = _input.substring(0, _input.length - 1);
      _errorMessage = null;
    });
  }

  void _onComplete() {
    if (widget.mode == PinDialogMode.register) {
      _handleRegister();
    } else {
      _handleVerify();
    }
  }

  void _handleRegister() {
    if (!_isConfirmStep) {
      // 첫 번째 입력 완료 -> 확인 단계로
      setState(() {
        _firstPin = _input;
        _input = '';
        _isConfirmStep = true;
      });
    } else {
      // 확인 단계: 일치 여부 확인
      if (_input == _firstPin) {
        Navigator.of(context).pop(PinDialogResult(success: true, pin: _input));
      } else {
        _shake();
        setState(() {
          _input = '';
          _errorMessage = 'PIN이 일치하지 않습니다';
          _isConfirmStep = false;
          _firstPin = null;
        });
      }
    }
  }

  void _handleVerify() {
    if (_input == widget.savedPin) {
      Navigator.of(context).pop(PinDialogResult(success: true, pin: _input));
    } else {
      _shake();
      setState(() {
        _input = '';
        _errorMessage = 'PIN이 올바르지 않습니다';
      });
    }
  }

  void _shake() {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final bgColor = isLight
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF1E2040);

    final borderColor = isLight
        ? const Color(0x1A000000)
        : const Color(0x33FFFFFF);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.dialog,
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.xxl),

            // ── Title ──
            Text(
              _title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Subtitle ──
            Text(
              _subtitle,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── PIN Dots ──
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                final shake = _shakeAnimation.value;
                final offset = shake * 12 * _shakeOffset(shake);
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _input.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? AppColors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: filled
                              ? AppColors.primary
                              : AppColors.textDisabled,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Error Message ──
            SizedBox(
              height: 32,
              child: _errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Numpad ──
            _buildNumpad(isLight),

            const SizedBox(height: AppSpacing.lg),

            // ── Forgot PIN (verify 모드에서만 표시) ──
            if (widget.mode == PinDialogMode.verify &&
                widget.onForgotPin != null)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // 현재 다이얼로그 닫기
                  widget.onForgotPin!();
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    'PIN 잊으셨나요?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary,
                    ),
                  ),
                ),
              ),

            // ── Cancel Button ──
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  '취소',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad(bool isLight) {
    final buttonColor = isLight
        ? const Color(0xFFF1F5F9)
        : const Color(0xFF2C2D52);

    final pressedColor = isLight
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF363660);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        children: [
          // Row 1: 1 2 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NumButton(digit: 1, onTap: _onDigit, bgColor: buttonColor, pressedColor: pressedColor),
              _NumButton(digit: 2, onTap: _onDigit, bgColor: buttonColor, pressedColor: pressedColor),
              _NumButton(digit: 3, onTap: _onDigit, bgColor: buttonColor, pressedColor: pressedColor),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Row 2: 4 5 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NumButton(digit: 4, onTap: _onDigit, bgColor: buttonColor, pressedColor: pressedColor),
              _NumButton(digit: 5, onTap: _onDigit, bgColor: buttonColor, pressedColor: pressedColor),
              _NumButton(digit: 6, onTap: _onDigit, bgColor: buttonColor, pressedColor: pressedColor),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Row 3: 7 8 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NumButton(digit: 7, onTap: _onDigit, bgColor: buttonColor, pressedColor: pressedColor),
              _NumButton(digit: 8, onTap: _onDigit, bgColor: buttonColor, pressedColor: pressedColor),
              _NumButton(digit: 9, onTap: _onDigit, bgColor: buttonColor, pressedColor: pressedColor),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Row 4: (empty) 0 (delete)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 64, height: 52), // spacer
              _NumButton(digit: 0, onTap: _onDigit, bgColor: buttonColor, pressedColor: pressedColor),
              _DeleteButton(onTap: _onDelete),
            ],
          ),
        ],
      ),
    );
  }

  /// 흔들림 오프셋 계산 (좌우 진동)
  double _shakeOffset(double t) {
    // sin 기반 감쇠 진동
    return (t < 0.25)
        ? -1.0
        : (t < 0.5)
            ? 1.0
            : (t < 0.75)
                ? -0.5
                : 0.5;
  }
}

/// 숫자 버튼
class _NumButton extends StatefulWidget {
  const _NumButton({
    required this.digit,
    required this.onTap,
    required this.bgColor,
    required this.pressedColor,
  });

  final int digit;
  final void Function(int) onTap;
  final Color bgColor;
  final Color pressedColor;

  @override
  State<_NumButton> createState() => _NumButtonState();
}

class _NumButtonState extends State<_NumButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap(widget.digit);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 64,
        height: 52,
        decoration: BoxDecoration(
          color: _pressed ? widget.pressedColor : widget.bgColor,
          borderRadius: AppRadius.radiusMd,
        ),
        alignment: Alignment.center,
        child: Text(
          '${widget.digit}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// 삭제 버튼
class _DeleteButton extends StatefulWidget {
  const _DeleteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 64,
        height: 52,
        decoration: BoxDecoration(
          color: _pressed
              ? AppColors.textDisabled.withAlpha(30)
              : Colors.transparent,
          borderRadius: AppRadius.radiusMd,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.backspace_outlined,
          color: AppColors.textSecondary,
          size: 22,
        ),
      ),
    );
  }
}
