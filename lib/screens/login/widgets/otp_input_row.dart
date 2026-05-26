import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';

class OTPInputRow extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  const OTPInputRow({super.key, required this.onCompleted});

  @override
  State<OTPInputRow> createState() => _OTPInputRowState();
}

class _OTPInputRowState extends State<OTPInputRow> {
  static const int _length = 6;

  final List<TextEditingController> _controllers =
      List.generate(_length, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(_length, (_) => FocusNode());

  // Convert Arabic/Persian digits → Latin
  String _normalizeDigit(String value) {
    if (value.isEmpty) return value;
    final code = value.codeUnitAt(0);

    // Arabic ٠-٩
    if (code >= 0x0660 && code <= 0x0669) {
      return String.fromCharCode(0x30 + (code - 0x0660));
    }

    // Persian ۰-۹
    if (code >= 0x06F0 && code <= 0x06F9) {
      return String.fromCharCode(0x30 + (code - 0x06F0));
    }

    return value;
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _handleChanged(int index, String value) {
    // Handle paste of full OTP
    if (value.length > 1) {
      final chars = value.split('');
      for (int i = 0; i < _length; i++) {
        if (i < chars.length) {
          _controllers[i].text = _normalizeDigit(chars[i]);
        }
      }
      _focusNodes.last.requestFocus();
    } else {
      if (value.isNotEmpty) {
        final normalized = _normalizeDigit(value);
        _controllers[index].text = normalized;

        if (index < _length - 1) {
          _focusNodes[index + 1].requestFocus();
        }
      } else {
        if (index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      }
    }

    final otp = _controllers.map((e) => e.text).join();
    if (otp.length == _length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final width =
            (constraints.maxWidth - spacing * 5) / _length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            _length,
            (i) => _OTPBox(
              width: width.clamp(42, 52),
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              onChanged: (v) => _handleChanged(i, v),
            ),
          ),
        );
      },
    );
  }
}

/* ---------------------------------------------------------- */

class _OTPBox extends StatefulWidget {
  final double width;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OTPBox({
    required this.width,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  State<_OTPBox> createState() => _OTPBoxState();
}

class _OTPBoxState extends State<_OTPBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _scale = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOut),
    );

    widget.focusNode.addListener(() {
      widget.focusNode.hasFocus
          ? _anim.forward()
          : _anim.reverse();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: SizedBox(
        width: widget.width,
        height: widget.width * 1.2,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textAlign: TextAlign.center,
          maxLength: 1,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'[0-9\u0660-\u0669\u06F0-\u06F9]'),
            ),
          ],
          onChanged: widget.onChanged,

          // 🔑 IMPORTANT FIX
          style: const TextStyle(
            fontFamily: 'Roboto',   // Ensures digits exist
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),

          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}