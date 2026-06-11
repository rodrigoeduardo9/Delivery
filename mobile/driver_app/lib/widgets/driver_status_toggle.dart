import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import '../config/theme.dart';

class DriverStatusToggle extends StatefulWidget {
  final bool isAvailable;
  final ValueChanged<bool> onToggle;

  const DriverStatusToggle({
    super.key,
    required this.isAvailable,
    required this.onToggle,
  });

  @override
  State<DriverStatusToggle> createState() => _DriverStatusToggleState();
}

class _DriverStatusToggleState extends State<DriverStatusToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _colorAnimation = ColorTween(
      begin: AppTheme.textHint,
      end: AppTheme.success,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isAvailable) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(DriverStatusToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAvailable != oldWidget.isAvailable) {
      if (widget.isAvailable) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (_, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: widget.isAvailable
                  ? [const Color(0xFF2E7D32), const Color(0xFF43A047)]
                  : [const Color(0xFF616161), const Color(0xFF757575)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.isAvailable ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isAvailable ? 'ON DUTY' : 'OFF DUTY',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isAvailable
                          ? 'You are accepting orders'
                          : 'Orders are paused',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onToggle(!widget.isAvailable);
                  if (!widget.isAvailable) {
                    _showOnlineFlushbar();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 64,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment: widget.isAvailable
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOnlineFlushbar() {
    Flushbar(
      message: 'You are now online and receiving orders',
      icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
      backgroundColor: AppTheme.success,
      duration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.all(16),
    ).show(context);
  }
}
