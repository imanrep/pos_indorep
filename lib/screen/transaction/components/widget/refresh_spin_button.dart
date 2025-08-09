import 'package:flutter/material.dart';

class RefreshSpinButton extends StatefulWidget {
  const RefreshSpinButton({
    super.key,
    required this.onPressed, // do your async work here
    this.icon = Icons.refresh,
    this.size = 24,
    this.duration = const Duration(milliseconds: 800),
    this.tooltip = 'Refresh',
    this.color,
  });

  final Future<void> Function() onPressed;
  final IconData icon;
  final double size;
  final Duration duration;
  final String tooltip;
  final Color? color;

  @override
  State<RefreshSpinButton> createState() => _RefreshSpinButtonState();
}

class _RefreshSpinButtonState extends State<RefreshSpinButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (_busy) return;
    setState(() => _busy = true);
    _spin.repeat();
    try {
      await widget.onPressed();
    } finally {
      _spin.stop();
      _spin.reset();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _spin,
      child: IconButton(
        tooltip: widget.tooltip,
        onPressed: _busy ? null : _handlePress,
        icon: Icon(widget.icon, size: widget.size, color: widget.color),
      ),
    );
  }
}
