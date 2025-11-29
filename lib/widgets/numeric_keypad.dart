import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class KeypadWidget extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onBackspacePressed;

  const KeypadWidget({
    super.key,
    required this.onKeyPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        ...List.generate(9, (index) {
          final number = (index + 1).toString();
          return _buildKey(number);
        }),
        const SizedBox.shrink(), // Placeholder for alignment
        _buildKey('0'),
        _buildBackspaceKey(),
      ],
    );
  }

  Widget _buildKey(String value) {
    return InkWell(
      onTap: () => onKeyPressed(value),
      borderRadius: BorderRadius.circular(100),
      child: Center(
        child: Text(
          value,
          style: TextStyle(color: AppColors.text, fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return InkWell(
      onTap: onBackspacePressed,
      borderRadius: BorderRadius.circular(100),
      child: const Center(
        child: Icon(Icons.backspace_outlined, color: AppColors.text),
      ),
    );
  }
}
