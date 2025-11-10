import 'package:flutter/material.dart';
import '../models/water_models.dart';
import '../theme/hello_kitty_theme.dart';

class StreakWidget extends StatelessWidget {
  final HydrationStreak streak;
  final VoidCallback? onTap;

  const StreakWidget({
    super.key,
    required this.streak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              HelloKittyTheme.primaryPink.withOpacity(0.9),
              HelloKittyTheme.lightPink.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: HelloKittyTheme.primaryPink.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone de streak com animação
            _buildStreakIcon(),
            const SizedBox(width: 8),
            // Número do streak
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${streak.currentStreak}🔥',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  streak.currentStreak == 1 ? 'dia' : 'dias',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakIcon() {
    // Diferentes ícones baseados no streak
    IconData iconData;
    Color iconColor = Colors.white;
    
    if (streak.currentStreak == 0) {
      iconData = Icons.water_drop_outlined;
    } else if (streak.currentStreak < 3) {
      iconData = Icons.water_drop;
    } else if (streak.currentStreak < 7) {
      iconData = Icons.local_fire_department;
      iconColor = Colors.orange.shade100;
    } else if (streak.currentStreak < 14) {
      iconData = Icons.whatshot;
      iconColor = Colors.amber.shade100;
    } else {
      iconData = Icons.emoji_events; // Troféu para streaks longos
      iconColor = Colors.yellow.shade100;
    }
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }
}

class StreakTooltip extends StatelessWidget {
  final HydrationStreak streak;
  final Widget child;

  const StreakTooltip({
    super.key,
    required this.streak,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _getTooltipMessage(),
      decoration: BoxDecoration(
        color: HelloKittyTheme.primaryPink,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.black,
        fontSize: 12,
      ),
      child: child,
    );
  }

  String _getTooltipMessage() {
    if (streak.currentStreak == 0) {
      if (streak.longestStreak > 0) {
        return 'Sua melhor sequência: ${streak.longestStreak} dias\nAtinja sua meta hoje para começar uma nova!';
      }
      return 'Atinja sua meta diária para começar sua sequência!';
    }
    
    String message = 'Sequência atual: ${streak.currentStreak} ';
    message += streak.currentStreak == 1 ? 'dia' : 'dias';
    
    if (streak.longestStreak > streak.currentStreak) {
      message += '\nSua melhor: ${streak.longestStreak} dias';
    }
    
    if (streak.currentStreak >= 7) {
      message += '\n🔥 Você está pegando fogo!';
    } else if (streak.currentStreak >= 3) {
      message += '\n💪 Continue assim!';
    }
    
    return message;
  }
}

class StreakCelebrationDialog extends StatelessWidget {
  final int newStreak;
  final int longestStreak;
  final bool isNewRecord;

  const StreakCelebrationDialog({
    super.key,
    required this.newStreak,
    required this.longestStreak,
    required this.isNewRecord,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              HelloKittyTheme.primaryPink.withOpacity(0.1),
              HelloKittyTheme.lightPink.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone de celebração
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HelloKittyTheme.primaryPink.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNewRecord ? Icons.emoji_events : Icons.local_fire_department,
                  size: 40,
                  color: HelloKittyTheme.primaryPink,
                ),
              ),            const SizedBox(height: 16),
            
            // Título
              Text(
                isNewRecord ? '🎉 Novo Recorde!' : '🔥 Sequência Incrível!',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: HelloKittyTheme.primaryPink,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),            const SizedBox(height: 12),
            
            // Descrição
            Text(
              isNewRecord 
                ? 'Você bateu seu recorde anterior!\n${newStreak} dias consecutivos bebendo água!'
                : '${newStreak} dias consecutivos!\nA Hello Kitty está muito orgulhosa! 💖',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            // Botão
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: HelloKittyTheme.primaryPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Continue assim! 💪',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}