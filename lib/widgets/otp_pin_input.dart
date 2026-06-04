import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Saisie OTP : 6 cases individuelles + collage / saisie continue.
class OtpPinInput extends StatefulWidget {
  const OtpPinInput({
    super.key,
    required this.length,
    required this.onChanged,
    this.onCompleted,
    this.autofocus = true,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final VoidCallback? onCompleted;
  final bool autofocus;

  @override
  State<OtpPinInput> createState() => OtpPinInputState();
}

class OtpPinInputState extends State<OtpPinInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  final _hiddenCtrl = TextEditingController();
  final _hiddenFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNodes.first.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _hiddenCtrl.dispose();
    _hiddenFocus.dispose();
    super.dispose();
  }

  String get value =>
      _controllers.map((c) => c.text).join().replaceAll(RegExp(r'\D'), '');

  /// Remplit les 6 cases (push FCM, devOtp, presse-papiers).
  void setCode(String code) {
    final digits = code.replaceAll(RegExp(r'\D'), '');
    if (digits.length != widget.length) return;
    for (var i = 0; i < widget.length; i++) {
      _controllers[i].text = digits[i];
    }
    _notify();
  }

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _hiddenCtrl.clear();
    _notify();
    _focusNodes.first.requestFocus();
  }

  void _notify() {
    widget.onChanged(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call();
    }
  }

  void _onDigitChanged(int index, String raw) {
    final digit = raw.replaceAll(RegExp(r'\D'), '');
    if (digit.length > 1) {
      _fillFromPaste(digit, startIndex: index);
      return;
    }
    _controllers[index].text = digit.length == 1 ? digit : '';
    if (digit.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _notify();
  }

  void _fillFromPaste(String digits, {int startIndex = 0}) {
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return;
    for (var i = 0; i < widget.length; i++) {
      final src = i - startIndex;
      _controllers[i].text =
          src >= 0 && src < clean.length ? clean[src] : _controllers[i].text;
    }
    if (clean.length >= widget.length) {
      _focusNodes.last.requestFocus();
    } else {
      final next = (startIndex + clean.length).clamp(0, widget.length - 1);
      _focusNodes[next].requestFocus();
    }
    _notify();
  }

  void _onHiddenChanged(String text) {
    final clean = text.replaceAll(RegExp(r'\D'), '');
    if (clean.length >= widget.length) {
      setCode(clean.substring(0, widget.length));
      _hiddenCtrl.clear();
    }
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Opacity(
          opacity: 0.01,
          child: SizedBox(
            height: 1,
            child: TextField(
              controller: _hiddenCtrl,
              focusNode: _hiddenFocus,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              onChanged: _onHiddenChanged,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (i) {
            return Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 0 : 6,
                right: i == widget.length - 1 ? 0 : 6,
              ),
              child: SizedBox(
                width: 44,
                height: 52,
                child: Focus(
                  onKeyEvent: (node, event) => _onKey(i, event),
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFF8BF13),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (v) => _onDigitChanged(i, v),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
