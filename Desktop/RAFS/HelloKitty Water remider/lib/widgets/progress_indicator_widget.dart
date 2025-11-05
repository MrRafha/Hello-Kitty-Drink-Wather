import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProgressIndicatorWidget extends StatefulWidget {
  final int current;
  final int goal;
  final double progress;

  const ProgressIndicatorWidget({
    super.key,
    required this.current,
    required this.goal,
    required this.progress,
  });

  @override
  State<ProgressIndicatorWidget> createState() => _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _sparkleController;
  late Animation<double> _progressAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutBack,
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_sparkleController);

    _progressController.forward();
    
    if (widget.progress >= 1.0) {
      _sparkleController.repeat();
    }
  }

  @override
  void didUpdateWidget(ProgressIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress.clamp(0.0, 1.0),
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutBack,
      ));
      
      _progressController.reset();
      _progressController.forward();
      
      if (widget.progress >= 1.0 && oldWidget.progress < 1.0) {
        _sparkleController.repeat();
      } else if (widget.progress < 1.0) {
        _sparkleController.stop();
        _sparkleController.reset();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress Circle
          Stack(
            alignment: Alignment.center,
            children: [
              // Sparkles for completed goal
              if (widget.progress >= 1.0)
                AnimatedBuilder(
                  animation: _sparkleAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(200, 200),
                      painter: SparklePainter(
                        animation: _sparkleAnimation.value,
                        color: theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
              
              // Progress Circle
              SizedBox(
                width: 180,
                height: 180,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ProgressCirclePainter(
                        progress: _progressAnimation.value,
                        backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                        progressColor: _getProgressColor(),
                        strokeWidth: 12,
                      ),
                    );
                  },
                ),
              ),
              
              // Center Content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.current}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(),
                    ),
                  ),
                  Text(
                    'de ${widget.goal}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'copos',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress Text and Emoji
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getProgressEmoji(),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                _getProgressText(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getProgressColor(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Linear Progress Bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getProgressColor().withOpacity(0.7),
                          _getProgressColor(),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor() {
    final theme = Theme.of(context);
    final progress = widget.progress;
    
    if (progress >= 1.0) {
      return Colors.green[500]!;
    } else if (progress >= 0.75) {
      return Colors.orange[500]!;
    } else if (progress >= 0.5) {
      return Colors.blue[500]!;
    } else {
      return theme.colorScheme.primary;
    }
  }

  String _getProgressEmoji() {
    final progress = widget.progress;
    
    if (progress >= 1.0) {
      return '🎉';
    } else if (progress >= 0.75) {
      return '🌟';
    } else if (progress >= 0.5) {
      return '💪';
    } else if (progress >= 0.25) {
      return '🌸';
    } else {
      return '🌈';
    }
  }

  String _getProgressText() {
    final progress = widget.progress;
    final percentage = (progress * 100).round();
    
    if (progress >= 1.0) {
      return 'Meta Atingida! 🎀';
    } else {
      return '$percentage% da meta';
    }
  }
}

class ProgressCirclePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  ProgressCirclePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            progressColor.withOpacity(0.7),
            progressColor,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class SparklePainter extends CustomPainter {
  final double animation;
  final Color color;

  SparklePainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create sparkles around the circle
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi / 8) + (animation * 2 * math.pi);
      final sparkleRadius = radius + 20 + (math.sin(animation * 4 * math.pi) * 10);
      
      final sparkleCenter = Offset(
        center.dx + math.cos(angle) * sparkleRadius,
        center.dy + math.sin(angle) * sparkleRadius,
      );
      
      final sparkleSize = 3 + (math.sin(animation * 6 * math.pi + i) * 2);
      
      // Draw sparkle
      _drawStar(canvas, sparkleCenter, sparkleSize, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final x = center.dx + math.cos(angle) * size;
      final y = center.dy + math.sin(angle) * size;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}