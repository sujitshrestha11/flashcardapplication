import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => TrainerState()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Korean Word Speaking Trainer',
            theme: _buildTheme(brightness: Brightness.light),
            darkTheme: _buildTheme(brightness: Brightness.dark),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const TrainerScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: isDark ? const Color(0xFF004D40) : Colors.deepPurple,
      brightness: brightness,
      primary: isDark ? const Color(0xFF00796B) : Colors.deepPurple,
      secondary: isDark ? const Color(0xFF26A69A) : Colors.deepPurpleAccent,
      background: isDark ? const Color(0xFF121212) : const Color(0xFFF0F0F0),
      surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: isDark ? Colors.white : Colors.black87,
      onSurface: isDark ? Colors.white : Colors.black87,
    );

    final textTheme =
        GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: brightness).textTheme,
        ).apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 6,
        color: colorScheme.surface.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.primary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        thumbColor: colorScheme.primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(colorScheme.primary),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colorScheme.primary.withOpacity(0.5)
              : null;
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface.withOpacity(0.8),
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class TrainerScreen extends StatelessWidget {
  const TrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1a2a2a), const Color(0xFF121212)]
              : [Colors.deepPurple.shade100, Colors.white],
        ),
      ),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('Korean Vocabulary Trainer'),
              floating: true,
              pinned: true,
              snap: false,
              actions: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return IconButton(
                      icon: Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: () => themeProvider.toggleTheme(),
                      tooltip: 'Toggle Theme',
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 80.0,
                ), // Space for bottom nav
                child: Column(
                  children: [
                    const VocabularyInputCard(),
                    const SettingsCard(),
                    const PronunciationQueue(),
                    const StatusAndControls(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Queue'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: 0,
        ),
      ),
    );
  }
}

class VocabularyInputCard extends StatelessWidget {
  const VocabularyInputCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TrainerState>(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vocabulary List',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              enabled: !state.isPlaying,
              maxLines: 6,
              controller: TextEditingController(text: state.vocabularyText),
              onChanged: (value) => state.vocabularyText = value,
              decoration: const InputDecoration(
                hintText: '사과 ; apple\n학교 ; school',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TrainerState>(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Playback Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context,
              'Repetitions',
              state.repetitions.toString(),
              (v) => state.repetitions = int.tryParse(v) ?? 1,
              !state.isPlaying,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              context,
              'Shuffle Reps',
              state.shuffleReps.toString(),
              (v) => state.shuffleReps = int.tryParse(v) ?? 1,
              !state.isPlaying,
            ),
            const SizedBox(height: 16),
            _buildSlider(
              context,
              'Speed',
              state.speed,
              state.isPlaying ? null : (v) => state.speed = v,
            ),
            const SizedBox(height: 8),
            _buildSwitch(
              context,
              'Speak English',
              state.speakEnglish,
              state.isPlaying ? null : (v) => state.speakEnglish = v,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    String value,
    Function(String) onChanged,
    bool enabled,
  ) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            enabled: enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: value),
            onChanged: onChanged,
            decoration: const InputDecoration(isDense: true),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(
    BuildContext context,
    String label,
    double value,
    void Function(double)? onChanged,
  ) {
    final state = Provider.of<TrainerState>(context, listen: false);
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Expanded(
          child: Slider(
            value: value,
            onChanged: (newValue) {
              onChanged?.call(newValue);
              state.notifyListeners();
            },
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSwitch(
    BuildContext context,
    String label,
    bool value,
    void Function(bool)? onChanged,
  ) {
    final state = Provider.of<TrainerState>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Switch(
          value: value,
          onChanged: (newValue) {
            onChanged?.call(newValue);
            state.notifyListeners();
          },
        ),
      ],
    );
  }
}

class PronunciationQueue extends StatelessWidget {
  const PronunciationQueue({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TrainerState>(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pronunciation Queue',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: state.wordPairs.isEmpty
                  ? Center(
                      child: Text(
                        'Your vocabulary list is empty.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      controller: state.scrollController,
                      itemCount: state.wordPairs.length,
                      itemBuilder: (context, index) {
                        final pair = state.wordPairs[index];
                        final isCurrent = index == state.currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              pair.korean,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              pair.english,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusAndControls extends StatelessWidget {
  const StatusAndControls({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TrainerState>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        children: [
          Text(
            state.status,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildControlButton(
                context,
                icon: Icons.play_arrow,
                label: 'Start',
                onPressed: state.isPlaying ? null : state.startPlayback,
              ),
              _buildControlButton(
                context,
                icon: Icons.shuffle,
                label: 'Shuffle',
                onPressed: state.isPlaying ? null : state.shufflePlayback,
              ),
              _buildControlButton(
                context,
                icon: Icons.stop,
                label: 'Stop',
                onPressed: state.isPlaying ? state.stopPlayback : null,
                color: state.isPlaying ? Colors.redAccent : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) return null;
          return color; // Use provided color or theme default
        }),
      ),
    );
  }
}
