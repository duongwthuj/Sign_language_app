import 'package:flutter/material.dart';
import '../../../../../constants/systems_design.dart';

class ListeningIndicator extends StatefulWidget {
  final bool isListening;
  final double height;

  const ListeningIndicator({
    Key? key,
    this.isListening = false,
    this.height = 60,
  }) : super(key: key);

  @override
  State<ListeningIndicator> createState() => _ListeningIndicatorState();
}

class _ListeningIndicatorState extends State<ListeningIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    if (widget.isListening) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ListeningIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final baseDelay = index * 0.1;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    baseDelay,
                    baseDelay + 0.6,
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
              child: Container(
                width: 6,
                height: widget.height * 0.6,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
