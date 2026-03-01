import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/chat_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const AiChatApp());
}

class AiChatApp extends StatelessWidget {
  const AiChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: MaterialApp(
        title: 'Orion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
