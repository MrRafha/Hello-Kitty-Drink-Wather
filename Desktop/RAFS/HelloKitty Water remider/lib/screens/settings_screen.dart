import 'package:flutter/material.dart';
import '../models/water_models.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/countdown_service.dart';
import '../services/background_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  final CountdownService _countdownService = CountdownService();
  final BackgroundService _backgroundService = BackgroundService();

  final _nameController = TextEditingController();
  final _dailyGoalController = TextEditingController();

  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _notificationsEnabled = false;
  int _frequency = 60;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dailyGoalController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final profile = await _storageService.getUserProfile() ?? 
          _storageService.getDefaultProfile();

      _nameController.text = profile.name;
      _dailyGoalController.text = profile.dailyGoal.glasses.toString();

      final startTimeParts = profile.notificationSettings.startTime.split(':');
      final endTimeParts = profile.notificationSettings.endTime.split(':');

      setState(() {
        _userProfile = profile;
        _notificationsEnabled = profile.notificationSettings.enabled;
        _frequency = profile.notificationSettings.frequency;
        _startTime = TimeOfDay(
          hour: int.parse(startTimeParts[0]),
          minute: int.parse(startTimeParts[1]),
        );
        _endTime = TimeOfDay(
          hour: int.parse(endTimeParts[0]),
          minute: int.parse(endTimeParts[1]),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erro ao carregar configurações: $e');
    }
  }

  Future<void> _saveSettings() async {
    if (_userProfile == null) return;

    try {
      final updatedProfile = _userProfile!.copyWith(
        name: _nameController.text.trim().isEmpty 
            ? 'Usuário' 
            : _nameController.text.trim(),
        dailyGoal: DailyGoal(
          glasses: int.tryParse(_dailyGoalController.text) ?? 8,
          lastUpdated: DateTime.now(),
        ),
        notificationSettings: NotificationSettings(
          enabled: _notificationsEnabled,
          frequency: _frequency,
          startTime: '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
          endTime: '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
          customMessages: _userProfile!.notificationSettings.customMessages,
        ),
      );

      await _storageService.saveUserProfile(updatedProfile);
      
      // Atualizar notificações
      if (_notificationsEnabled) {
        await _notificationService.scheduleWaterReminders();
      } else {
        await _notificationService.cancelAllNotifications();
      }
      
      // Atualizar countdown service
      await _countdownService.updateSettings();

      setState(() {
        _userProfile = updatedProfile;
      });

      _showSuccessSnackBar('Configurações salvas com sucesso!');
    } catch (e) {
      _showErrorSnackBar('Erro ao salvar configurações: $e');
    }
  }

  Future<void> _testNotifications() async {
    try {
      await _notificationService.testNotifications();
      _showSuccessSnackBar('Teste de notificação enviado! Verifique suas notificações.');
    } catch (e) {
      _showErrorSnackBar('Erro no teste: $e');
    }
  }

  Future<void> _optimizeBackgroundExecution() async {
    try {
      await _backgroundService.ensureBackgroundExecution();
      _showSuccessSnackBar('Configurações otimizadas! O app funcionará melhor em segundo plano.');
    } catch (e) {
      _showErrorSnackBar('Erro ao otimizar: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
              background: Colors.white,
              onBackground: Colors.black87,
            ),
            textTheme: Theme.of(context).textTheme.copyWith(
              headlineLarge: const TextStyle(color: Colors.black87, fontSize: 56),
              headlineMedium: const TextStyle(color: Colors.black87, fontSize: 24),
              bodyLarge: const TextStyle(color: Colors.black87, fontSize: 16),
              bodyMedium: const TextStyle(color: Colors.black87, fontSize: 14),
              labelLarge: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Dados'),
        content: const Text(
          'Tem certeza que deseja apagar todos os dados? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.clearAllData();
        await _notificationService.cancelAllNotifications();
        _showSuccessSnackBar('Todos os dados foram removidos!');
        _loadSettings(); // Recarregar com dados padrão
      } catch (e) {
        _showErrorSnackBar('Erro ao limpar dados: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 30),
                
                // Profile Section
                _buildProfileSection(),
                const SizedBox(height: 30),
                
                // Goals Section
                _buildGoalsSection(),
                const SizedBox(height: 30),
                
                // Notifications Section
                _buildNotificationsSection(),
                const SizedBox(height: 30),
                
                // Data Section
                _buildDataSection(),
                const SizedBox(height: 30),
                
                // Save Button
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.settings,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configurações',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Personalize seu app',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return _buildSection(
      title: 'Perfil',
      icon: Icons.person,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Nome',
          hint: 'Digite seu nome',
          icon: Icons.person_outline,
        ),
      ],
    );
  }

  Widget _buildGoalsSection() {
    return _buildSection(
      title: 'Metas',
      icon: Icons.flag,
      children: [
        _buildTextField(
          controller: _dailyGoalController,
          label: 'Meta diária (copos)',
          hint: '8',
          icon: Icons.local_drink,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    final theme = Theme.of(context);
    
    return _buildSection(
      title: 'Notificações',
      icon: Icons.notifications,
      children: [
        // Enable/Disable
        _buildSwitchTile(
          title: 'Lembretes',
          subtitle: 'Receber notificações para beber água',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
          },
        ),
        
        if (_notificationsEnabled) ...[
          const SizedBox(height: 16),
          
          // Frequency
          Text(
            'Frequência dos lembretes',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<int>(
              value: _frequency,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 30, child: Text('A cada 30 minutos')),
                DropdownMenuItem(value: 60, child: Text('A cada 1 hora')),
                DropdownMenuItem(value: 90, child: Text('A cada 1h30')),
                DropdownMenuItem(value: 120, child: Text('A cada 2 horas')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _frequency = value);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Time Range
          Row(
            children: [
              Expanded(
                child: _buildTimeTile(
                  title: 'Início',
                  time: _startTime,
                  onTap: () => _selectTime(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeTile(
                  title: 'Fim',
                  time: _endTime,
                  onTap: () => _selectTime(false),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSection(
      title: 'Dados',
      icon: Icons.storage,
      children: [
        _buildActionTile(
          title: 'Limpar todos os dados',
          subtitle: 'Remove todo o histórico e configurações',
          icon: Icons.delete_forever,
          iconColor: Colors.red,
          onTap: _clearAllData,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: Colors.black54,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildTimeTile({
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: theme.colorScheme.onSurface.withOpacity(0.4),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSaveButton() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Botão de teste (se notificações habilitadas)
        if (_notificationsEnabled) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _testNotifications,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_active, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Testar Notificações',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Botão de otimização de segundo plano
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _optimizeBackgroundExecution,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange[700],
                side: BorderSide(color: Colors.orange[700]!),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.battery_saver, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Otimizar Segundo Plano',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Botão principal de salvar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.save, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Salvar Configurações',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}