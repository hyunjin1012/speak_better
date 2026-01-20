import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/local_store.dart';
import 'features/auth/login_screen.dart';
import 'features/topics/topic_list_screen.dart';
import 'features/history/history_screen.dart';
import 'features/achievements/achievements_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/settings/notification_settings_screen.dart';
import 'features/flashcards/flashcards_screen.dart';
import 'services/notification_service.dart';
import 'state/auth_provider.dart';
import 'state/stats_provider.dart';
import 'state/achievements_provider.dart';
import 'state/flashcards_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStore.init();

  // Initialize Firebase with the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notification service
  await NotificationService().initialize();

  runApp(const ProviderScope(child: SpeakBetterApp()));
}

class SpeakBetterApp extends StatelessWidget {
  const SpeakBetterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speak Better',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const LanguageSelectionScreen();
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(authStateProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.language,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your interface language',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLanguageButton(
                          'ko', '한국어', const Color(0xFFEF4444)),
                      const SizedBox(width: 16),
                      _buildLanguageButton(
                          'en', 'English', const Color(0xFF3B82F6)),
                    ],
                  ),
                  if (_selectedLanguage != null) ...[
                    const SizedBox(height: 48),
                    Text(
                      'I am learning...',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Stack vertically on small screens, horizontally on larger screens
                        if (constraints.maxWidth < 400) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLearnerModeButton(
                                'korean_learner',
                                _selectedLanguage == 'ko'
                                    ? '한국어 학습자'
                                    : 'Korean Learner',
                                const Color(0xFF10B981),
                              ),
                              const SizedBox(height: 12),
                              _buildLearnerModeButton(
                                'english_learner',
                                _selectedLanguage == 'ko'
                                    ? '영어 학습자'
                                    : 'English Learner',
                                const Color(0xFF6366F1),
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: _buildLearnerModeButton(
                                  'korean_learner',
                                  _selectedLanguage == 'ko'
                                      ? '한국어 학습자'
                                      : 'Korean Learner',
                                  const Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: _buildLearnerModeButton(
                                  'english_learner',
                                  _selectedLanguage == 'ko'
                                      ? '영어 학습자'
                                      : 'English Learner',
                                  const Color(0xFF6366F1),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                  if (_selectedLanguage != null &&
                      _selectedLearnerMode != null) ...[
                    const SizedBox(height: 48),
                    ElevatedButton.icon(
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
                      icon: const Icon(Icons.arrow_forward),
                      label:
                          const Text('Start', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 18),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String lang, String label, Color color) {
    final isSelected = _selectedLanguage == lang;
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedLanguage = lang;
              _selectedLearnerMode = null;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              color: isSelected ? null : colorScheme.surfaceContainerHighest,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLearnerModeButton(String mode, String label, Color color) {
    final isSelected = _selectedLearnerMode == mode;
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedLearnerMode = mode;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              color: isSelected ? null : colorScheme.surfaceContainerHighest,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
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

    return Consumer(
      builder: (context, ref, _) {
        final authService = ref.read(authServiceProvider);
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(isKorean ? 'Speak Better' : 'Speak Better'),
              actions: [
                // Settings button
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: isKorean ? '설정' : 'Settings',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NotificationSettingsScreen(language: language),
                      ),
                    );
                  },
                ),
                // Progress button
                IconButton(
                  icon: const Icon(Icons.bar_chart),
                  tooltip: isKorean ? '진행 상황' : 'Progress',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProgressScreen(language: language),
                      ),
                    );
                  },
                ),
                // Flashcards button
                Consumer(
                  builder: (context, ref, _) {
                    final dueCount = ref
                        .read(flashcardsProvider.notifier)
                        .getDueCards(language)
                        .length;
                    return IconButton(
                      icon: Stack(
                        children: [
                          const Icon(Icons.auto_stories),
                          if (dueCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$dueCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      tooltip: isKorean ? '단어 카드' : 'Flashcards',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FlashcardsScreen(language: language),
                          ),
                        );
                      },
                    );
                  },
                ),
                // Achievements button
                Consumer(
                  builder: (context, ref, _) {
                    final achievements = ref.watch(achievementsProvider);
                    final unlockedCount =
                        achievements.where((a) => a.isUnlocked).length;
                    return IconButton(
                      icon: Stack(
                        children: [
                          const Icon(Icons.emoji_events),
                          if (unlockedCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$unlockedCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      tooltip: isKorean ? '업적' : 'Achievements',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AchievementsScreen(language: language),
                          ),
                        );
                      },
                    );
                  },
                ),
                // Streak display
                Consumer(
                  builder: (context, ref, _) {
                    final stats = ref.watch(statsProvider);
                    if (stats.currentStreak > 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Center(
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${stats.currentStreak}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
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
      },
    );
  }
}
