import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/audio/audio_manager.dart';
import '../app/widgets/banner_ad_footer.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';
import 'lobby_matchmaking_screen.dart';
import 'privacy_policy_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  int _soloHighScore = 0;
  int _teamHighScore = 0;
  int _selectedColorIndex = 0;

  late AnimationController _waveController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  final List<Map<String, dynamic>> _colorPalette = [
    {'name': 'Azul / Rosa', 'primary': const Color(0xFF00E5FF), 'secondary': const Color(0xFFFF007F)},
    {'name': 'Rosa / Branco', 'primary': const Color(0xFFFF007F), 'secondary': Colors.white},
    {'name': 'Preto / Azul', 'primary': Colors.black, 'secondary': const Color(0xFF00E5FF)},
    {'name': 'Vermelho / Preto', 'primary': Colors.red, 'secondary': Colors.black},
    {'name': 'Amarelo / Verde', 'primary': Colors.yellow, 'secondary': Colors.green},
    {'name': 'Verde / Branco', 'primary': Colors.green, 'secondary': Colors.white},
    {'name': 'Preto / Branco', 'primary': Colors.black, 'secondary': Colors.white},
    {'name': 'Branco / Vermelho', 'primary': Colors.white, 'secondary': Colors.red},
    {'name': 'Azul / Verde', 'primary': Colors.blue, 'secondary': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _loadSavedData().then((_) => AudioManager().playMenuBgm());
  }

  @override
  void dispose() {
    AudioManager().stopMenuBgm();
    _waveController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final name = await StorageService.getNickname();
    final solo = await StorageService.getSoloHighScore();
    final team = await StorageService.getTeamHighScore();
    final colorIdx = await StorageService.getSnakeColorIndex();

    if (!mounted) return;
    setState(() {
      _nameController.text = name.isEmpty ? 'Jogador' : name;
      _soloHighScore = solo;
      _teamHighScore = team;
      _selectedColorIndex = colorIdx.clamp(0, _colorPalette.length - 1);
    });
  }

  List<Color> get _selectedSkinColors {
    final item = _colorPalette[_selectedColorIndex];
    return [item['primary'] as Color, item['secondary'] as Color];
  }

  Future<void> _startGame(bool isTeamMode) async {
    final nickname = _nameController.text.trim();
    if (nickname.isEmpty) return;

    if (isTeamMode) {
      final micGranted = await PermissionService.requestMicrophoneForTeamMode();
      if (!mounted) return;
      if (!micGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microfone negado — chat de voz da equipe ficará indisponível.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    await StorageService.saveNickname(nickname);
    await StorageService.saveSnakeColorIndex(_selectedColorIndex);

    if (!mounted) return;
    await AudioManager().pauseMenuBgm();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LobbyMatchmakingScreen(
          playerNickname: nickname,
          playerSkinColors: _selectedSkinColors,
          isTeamMode: isTeamMode,
        ),
      ),
    );
    if (mounted) {
      await _loadSavedData();
      await AudioManager().resumeMenuBgm();
    }
  }

  Widget _buildScoreBadge(String label, int score, Color accent, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent.withValues(alpha: 0.25), Colors.black.withValues(alpha: 0.5)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.6)),
          boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.2), blurRadius: 12)],
        ),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(
                    '$score pts',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWavyTitle() {
    const title = 'RASTROS SNAKE';
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(title.length, (i) {
            final phase = (_waveController.value * math.pi * 2) - (i * 0.55);
            return Transform.translate(
              offset: Offset(0, math.sin(phase) * 6),
              child: Text(
                title[i],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE0115F),
                  shadows: [
                    Shadow(color: Colors.amber, blurRadius: 16),
                    Shadow(color: Colors.cyanAccent, blurRadius: 24),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPlayButton({
    required String label,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.02),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: gradient),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              height: 52,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.black87),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _colorPalette[_selectedColorIndex];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B1026), Color(0xFF1A0B2E), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ...List.generate(14, (i) {
            final rnd = math.Random(i * 13);
            return Positioned(
              left: rnd.nextDouble() * 900,
              top: rnd.nextDouble() * 500,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, _) {
                  return Opacity(
                    opacity: 0.3 + _glowController.value * 0.4,
                    child: Container(
                      width: 6 + rnd.nextDouble() * 10,
                      height: 6 + rnd.nextDouble() * 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: [Colors.cyanAccent, Colors.amberAccent, Colors.pinkAccent][i % 3],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildScoreBadge('RECORDE SOLO', _soloHighScore, const Color(0xFF00E5FF), Icons.person),
                            const SizedBox(width: 12),
                            _buildScoreBadge('RECORDE EQUIPE', _teamHighScore, const Color(0xFFFFD700), Icons.groups),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _buildWavyTitle(),
                        const SizedBox(height: 6),
                        const Text(
                          'Trace seu caminho. Domine a arena cósmica.',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 22),
                        TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          onEditingComplete: () {
                            final nickname = _nameController.text.trim();
                            if (nickname.isNotEmpty) StorageService.saveNickname(nickname);
                          },
                          decoration: InputDecoration(
                            hintText: 'Digite seu Nickname',
                            hintStyle: const TextStyle(color: Colors.white38),
                            prefixIcon: const Icon(Icons.edit, color: Color(0xFF00E5FF)),
                            filled: true,
                            fillColor: Colors.black.withValues(alpha: 0.45),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.amberAccent, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'SKIN DA COBRA — 9 combinações',
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selected['name'] as String,
                          style: TextStyle(
                            color: (selected['primary'] as Color).withValues(alpha: 0.9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 72,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _colorPalette.length,
                            itemBuilder: (context, index) {
                              final item = _colorPalette[index];
                              final isSelected = index == _selectedColorIndex;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedColorIndex = index);
                                  StorageService.saveSnakeColorIndex(index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 96,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: LinearGradient(
                                      colors: [item['primary'] as Color, item['secondary'] as Color],
                                    ),
                                    border: Border.all(
                                      color: isSelected ? Colors.white : Colors.white24,
                                      width: isSelected ? 3 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: (item['primary'] as Color).withValues(alpha: 0.5),
                                              blurRadius: 14,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (isSelected) const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                      const Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Text(
                                          item['name'] as String,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 22),
                        _buildPlayButton(
                          label: 'JOGAR',
                          icon: Icons.play_arrow_rounded,
                          gradient: const [Color(0xFF00E5FF), Color(0xFF0891B2)],
                          onTap: () => _startGame(false),
                        ),
                        const SizedBox(height: 12),
                        _buildPlayButton(
                          label: 'JOGAR EQUIPE',
                          icon: Icons.groups_rounded,
                          gradient: const [Color(0xFFFFD700), Color(0xFFF59E0B)],
                          onTap: () => _startGame(true),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                            );
                          },
                          icon: const Icon(Icons.privacy_tip_outlined, color: Colors.white54, size: 16),
                          label: const Text(
                            'Política de Privacidade',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ),
                        const Text(
                          'Fábrica Thalli',
                          style: TextStyle(
                            color: Colors.white30,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Center(child: BannerAdFooter()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
