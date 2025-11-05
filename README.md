# 🎀 Hello Kitty Water Reminder

<div align="center">

![Hello Kitty Water Reminder](assets/icons/kitty.png)

*Um aplicativo fofo temático da Hello Kitty para lembrar você de beber água* 💧

[![Flutter](https://img.shields.io/badge/Flutter-3.35.7-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.5.0-blue.svg)](https://dart.dev/)
[![Android](https://img.shields.io/badge/Android-API%2021+-green.svg)](https://developer.android.com/)
[![License](https://img.shields.io/badge/License-MIT-pink.svg)](LICENSE)

</div>

## ✨ Funcionalidades

- 🎀 **Interface Hello Kitty** - Design rosa fofo e kawaii
- 💧 **Contador de Água** - Registre seus copos de água facilmente
- ⏰ **Lembretes Inteligentes** - Notificações personalizáveis em segundo plano
- 📊 **Estatísticas Semanais** - Acompanhe seu progresso de hidratação
- 🎯 **Metas Personalizadas** - Configure objetivos diários
- 🔄 **Countdown Persistente** - Timer que continua entre navegações
- 🔋 **Execução em Segundo Plano** - Funciona mesmo com o app fechado
- 🌙 **Modo Noturno** - Interface adaptável para diferentes horários

## 📱 Screenshots

| Tela Principal | Configurações | Estatísticas |
|----------------|---------------|--------------|
| *Em breve* | *Em breve* | *Em breve* |

## 🚀 Download

### APK Releases

Baixe a versão mais recente para Android:

- **ARM64 (Recomendado)** - 20.8 MB
  - Para dispositivos Android modernos (2018+)
  
- **Universal** - 51.8 MB  
  - Compatível com todos os dispositivos Android

*[📥 Downloads disponíveis nas Releases](https://github.com/MrRafha/Hello-Kitty-Drink-Wather/releases)*

## 🛠️ Tecnologias

- **Framework:** Flutter 3.35.7
- **Linguagem:** Dart 3.5.0
- **Notificações:** flutter_local_notifications
- **Gráficos:** fl_chart
- **Armazenamento:** SharedPreferences
- **Permissões:** permission_handler
- **Fuso Horário:** timezone

## 📋 Requisitos

### Para Usuário
- Android 5.0+ (API 21)
- 25MB de espaço livre
- Permissões de notificação

### Para Desenvolvedor
- Flutter 3.24.0+
- Dart SDK 3.5.0+
- Android SDK (API 21+)
- Git

## 🔧 Instalação para Desenvolvimento

```bash
# Clone o repositório
git clone https://github.com/MrRafha/Hello-Kitty-Drink-Wather.git
cd Hello-Kitty-Drink-Wather

# Instale as dependências
flutter pub get

# Execute no emulador/dispositivo
flutter run
```

### Build para Produção

```bash
# APK Universal
flutter build apk --release

# APK por arquitetura (menor tamanho)
flutter build apk --release --split-per-abi

# Bundle para Google Play Store
flutter build appbundle --release
```

## 🎨 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada
├── main_screen.dart          # Navegação principal
├── models/                   # Modelos de dados
│   └── water_models.dart
├── screens/                  # Telas do aplicativo
│   ├── home_screen.dart
│   ├── settings_screen.dart
│   └── stats_screen.dart
├── services/                 # Serviços e lógica de negócio
│   ├── background_service.dart
│   ├── countdown_service.dart
│   ├── notification_service.dart
│   └── storage_service.dart
├── theme/                    # Temas e estilos
│   └── hello_kitty_theme.dart
└── widgets/                  # Componentes reutilizáveis
    ├── progress_indicator_widget.dart
    ├── water_counter_widget.dart
    └── water_reminder_countdown.dart
```

## 🤝 Contribuição

Contribuições são bem-vindas! Por favor:

1. Faça um Fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**MrRafha**
- GitHub: [@MrRafha](https://github.com/MrRafha)

## 🙏 Agradecimentos

- Hello Kitty & Sanrio por inspirar o design
- Comunidade Flutter pelo framework incrível
- Todos que contribuíram com feedback e sugestões

---

<div align="center">
Feito com 💖 e muita ☕ por MrRafha
</div>
