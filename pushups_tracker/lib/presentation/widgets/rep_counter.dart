import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Single-tap max-rep counter shared by the initial, exhaustion and final tests.
class RepCounter extends StatefulWidget {
  final String title;
  final String instruction;
  final String finishLabel;
  final ValueChanged<int> onFinish;
  final bool enabled;

  const RepCounter({
    super.key,
    required this.title,
    required this.instruction,
    required this.onFinish,
    this.finishLabel = 'FINISH TEST',
    this.enabled = true,
  });

  @override
  State<RepCounter> createState() => _RepCounterState();
}

class _RepCounterState extends State<RepCounter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(widget.title, style: theme.textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(widget.instruction, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
        const Spacer(),
        Text('$_count', style: theme.textTheme.displayLarge?.copyWith(fontSize: 160)),
        const Text('pushups'),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 100,
          child: GestureDetector(
            onTap: widget.enabled
                ? () {
                    HapticFeedback.lightImpact();
                    setState(() => _count++);
                  }
                : null,
            child: Card(
              color: theme.colorScheme.primary,
              child: const Center(
                child: Text('TAP TO COUNT', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.enabled && _count > 0 ? () => setState(() => _count--) : null,
                child: const Text('UNDO'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: widget.enabled ? () => widget.onFinish(_count) : null,
                child: Text(widget.finishLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
