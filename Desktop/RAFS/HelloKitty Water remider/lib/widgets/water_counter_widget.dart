import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class WaterCounterWidget extends StatefulWidget {
  final int currentGlasses;
  final Function({int glasses}) onAddWater;

  const WaterCounterWidget({
    super.key,
    required this.currentGlasses,
    required this.onAddWater,
  });

  @override
  State<WaterCounterWidget> createState() => _WaterCounterWidgetState();
}

class _WaterCounterWidgetState extends State<WaterCounterWidget>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _scaleController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    
    // Animação de escala
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    // Animação de ripple
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
    
    widget.onAddWater(glasses: 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Counter Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_drink,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.currentGlasses} copos hoje',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        
        // Main Water Button
        GestureDetector(
          onTap: _onTap,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.8),
                        theme.colorScheme.primary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ripple Effect
                      AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 160 * _rippleAnimation.value * 1.5,
                            height: 160 * _rippleAnimation.value * 1.5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.5 * (1 - _rippleAnimation.value),
                                ),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Water Drop Icon and Text
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.water_drop,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'BEBER',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'ÁGUA',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        
        // Tap instruction
        Text(
          'Toque para adicionar 1 copo 💧',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// Water Glass Animation Widget
class WaterGlassWidget extends StatefulWidget {
  final double fillPercentage;
  final double size;

  const WaterGlassWidget({
    super.key,
    required this.fillPercentage,
    this.size = 100,
  });

  @override
  State<WaterGlassWidget> createState() => _WaterGlassWidgetState();
}

class _WaterGlassWidgetState extends State<WaterGlassWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(_waveController);

    _waveController.repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glass outline
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 3,
              ),
            ),
          ),
          
          // Water fill with wave effect
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return ClipOval(
                child: SizedBox(
                  width: widget.size - 6,
                  height: widget.size - 6,
                  child: CustomPaint(
                    painter: WaterWavePainter(
                      fillPercentage: widget.fillPercentage,
                      wavePhase: _waveAnimation.value,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class WaterWavePainter extends CustomPainter {
  final double fillPercentage;
  final double wavePhase;
  final Color color;

  WaterWavePainter({
    required this.fillPercentage,
    required this.wavePhase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fillPercentage <= 0) return;

    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * 0.02;
    final waterLevel = size.height * (1 - fillPercentage);

    // Start from left
    path.moveTo(0, size.height);

    // Create wave effect
    for (double x = 0; x <= size.width; x += 1) {
      final waveY = waterLevel + 
          waveHeight * 
          (math.sin((x / size.width * 2 * math.pi * 2) + wavePhase) +
           math.sin((x / size.width * 2 * math.pi * 3) + wavePhase * 0.7) * 0.5);
      
      if (x == 0) {
        path.lineTo(x, waveY);
      } else {
        path.lineTo(x, waveY);
      }
    }

    // Close the path
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}