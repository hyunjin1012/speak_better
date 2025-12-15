import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/local_store.dart';
import 'features/auth/login_screen.dart';
import 'features/topics/topic_list_screen.dart';
import 'features/history/history_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStore.init();
  
  // Initialize Firebase with the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: SpeakBetterApp()));
}

class SpeakBetterApp extends StatelessWidget {
  const SpeakBetterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speak Better',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is signed in, show main app
        if (snapshot.hasData && snapshot.data != null) {
          return const LanguageSelectionScreen();
        }

        // If no user, show login screen
        return const LoginScreen();
      },
    );
  }
}

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;
  String? _selectedLearnerMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speak Better'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLanguageButton('ko', '한국어', Colors.red),
                  const SizedBox(width: 16),
                  _buildLanguageButton('en', 'English', Colors.blue),
                ],
              ),
              if (_selectedLanguage != null) ...[
                const SizedBox(height: 48),
                const Text(
                  'I am learning...',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLearnerModeButton(
                      'korean_learner',
                      _selectedLanguage == 'ko' ? '한국어 학습자' : 'Korean Learner',
                    ),
                    const SizedBox(width: 16),
                    _buildLearnerModeButton(
                      'english_learner',
                      _selectedLanguage == 'ko' ? '영어 학습자' : 'English Learner',
                    ),
                  ],
                ),
              ],
              if (_selectedLanguage != null &&
                  _selectedLearnerMode != null) ...[
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(
                          language: _selectedLanguage!,
                          learnerMode: _selectedLearnerMode!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Start', style: TextStyle(fontSize: 18)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String lang, String label, Color color) {
    final isSelected = _selectedLanguage == lang;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedLanguage = lang;
          _selectedLearnerMode = null;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildLearnerModeButton(String mode, String label) {
    final isSelected = _selectedLearnerMode == mode;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedLearnerMode = mode;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}

class MainScreen extends StatelessWidget {
  final String language;
  final String learnerMode;

  const MainScreen({
    super.key,
    required this.language,
    required this.learnerMode,
  });

  @override
  Widget build(BuildContext context) {
    final isKorean = language == 'ko';
    final authService = AuthService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isKorean ? 'Speak Better' : 'Speak Better'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: isKorean ? '로그아웃' : 'Sign Out',
              onPressed: () async {
                await authService.signOut();
                // Navigation handled by auth state listener
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: isKorean ? '주제' : 'Topics'),
              Tab(text: isKorean ? '기록' : 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TopicListScreen(
              language: language,
              learnerMode: learnerMode,
            ),
            HistoryScreen(language: language),
          ],
        ),
      ),
    );
  }
}
