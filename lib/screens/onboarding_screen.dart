import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/music_provider.dart';

// ─────────────────────────────────────────────────────────────
// Entry point: decides whether to show onboarding or go home
// ─────────────────────────────────────────────────────────────

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    if (!mounted) return;
    if (done) {
      Navigator.pushReplacementNamed(context, '/home');
    }
    // else: stay on this widget which renders LandingScreen
  }

  @override
  Widget build(BuildContext context) {
    // Show a blank scaffold while checking; transitions are fast enough
    return const LandingScreen();
  }
}

// ─────────────────────────────────────────────────────────────
// Step 1: Landing
// ─────────────────────────────────────────────────────────────

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.music_note_rounded,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'muse',
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 52),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '1.0.0',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.35),
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const _PermissionsScreen()),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Text(
                  'Get started',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 2: Permissions
// ─────────────────────────────────────────────────────────────

class _PermissionsScreen extends StatelessWidget {
  const _PermissionsScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security_rounded,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Permissions',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Audio permission card
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.audio_file_rounded,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        title: const Text(
                          'Audio',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'muse needs it to play your wonderful music',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.55),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FilledButton(
                onPressed: () async {
                  await context.read<MusicProvider>().requestPermission();
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const _MusicScanScreen(),
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Text(
                  'Grant permission',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 3: Music Scan settings
// ─────────────────────────────────────────────────────────────

class _MusicScanScreen extends StatefulWidget {
  const _MusicScanScreen();

  @override
  State<_MusicScanScreen> createState() => _MusicScanScreenState();
}

class _MusicScanScreenState extends State<_MusicScanScreen> {
  bool _ignoreShort = true;
  bool _includeMusicFolder = true;
  bool _refreshOnLaunch = true;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 100),
              children: [
                // Icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.radar_rounded,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Music scan',
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 36),
                  ),
                ),
                const SizedBox(height: 32),

                // Settings card
                _ScanCard(children: [
                  _ScanSwitch(
                    icon: Icons.filter_alt_outlined,
                    title: 'Ignore short tracks',
                    subtitle: 'Do not show tracks shorter than 30 seconds',
                    value: _ignoreShort,
                    onChanged: (v) => setState(() => _ignoreShort = v),
                  ),
                  _ScanSwitch(
                    icon: Icons.folder_special_rounded,
                    title: 'Include Music folder',
                    subtitle: 'Show music from default Music folder',
                    value: _includeMusicFolder,
                    onChanged: (v) => setState(() => _includeMusicFolder = v),
                  ),
                ]),
                const SizedBox(height: 12),
                _ScanCard(children: [
                  _ScanSwitch(
                    icon: Icons.refresh_rounded,
                    title: 'Refresh on app launch',
                    subtitle: 'Refresh data in MediaStore on launch',
                    value: _refreshOnLaunch,
                    onChanged: (v) => setState(() => _refreshOnLaunch = v),
                  ),
                ]),
              ],
            ),

            // Next button
            Positioned(
              bottom: 24,
              right: 24,
              child: FilledButton(
                onPressed: _finish,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────

class _ScanCard extends StatelessWidget {
  final List<Widget> children;
  const _ScanCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children.asMap().entries.map((e) {
          final isLast = e.key == children.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast) Divider(height: 1, color: theme.dividerColor, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ScanSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ScanSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SwitchListTile(
      secondary: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}