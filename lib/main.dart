import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/firebase_options.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:simple_animations/simple_animations.dart';
import 'dart:math' as math;

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService._(this._remoteConfig);

  static Future<RemoteConfigService> init() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await remoteConfig.setDefaults(const {
      "github_url": "https://github.com/Mostafa-Hashem-22",
      "linkedin_url": "https://www.linkedin.com/in/mostafa-hashem-186b51268/",
      "vjudge_url": "https://vjudge.net/user/Mostafa_Hashem",
      "cv_url":
          "https://drive.google.com/file/d/1vRqnKnodWb43oHJ8ykKVcmRdgpJ1gFbK/view?usp=sharing",
      "main_photo_url":
          "https://i.ibb.co/6Psm2Wc/392386383-1002364024376378-2938164624325997621-n.jpg",
      "workshop_photo_url": "https://i.ibb.co/gdhfB0x/image.png",
      "project_talksy_apk_url": "https://example.com/default_talksy.apk",
      "project_movies_github_url":
          "https://github.com/mostafa-hashem/Movies-App",
      "contact_email": "mostafahashem319@gmail.com",
      "contact_phone": "+20-106-311-8640",
    });

    try {
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config fetch failed: $e');
    }

    return RemoteConfigService._(remoteConfig);
  }

  String getString(String key) => _remoteConfig.getString(key);
}

late final RemoteConfigService remoteConfigService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  remoteConfigService = await RemoteConfigService.init();

  runApp(const PortfolioApp());
}

void _launchURL(String url) async {
  final Uri uri = Uri.parse(url);

  if (!await launchUrl(uri)) {
    throw 'Could not launch $url';
  }
}

extension ColorAlpha on Color {
  Color withValues({int? alpha}) {
    return withAlpha(alpha ?? a as int);
  }
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00E5FF);
    const secondaryColor = Color(0xFF1E90FF);
    const backgroundColor = Color(0xFF020417);
    const surfaceColor = Color(0xFF0A0F2D);

    return MaterialApp(
      title: 'Mostafa Hashem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: 'Ubuntu',
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: surfaceColor,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
              fontFamily: 'NovaFlat',
              fontSize: 52.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white,
              shadows: [
                Shadow(color: primaryColor, blurRadius: 20),
                Shadow(color: primaryColor, blurRadius: 30),
              ]),
          headlineMedium: const TextStyle(
            fontFamily: 'NovaFlat',
            fontSize: 36.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          titleLarge: const TextStyle(
            fontFamily: 'Ubuntu',
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: const TextStyle(
            fontFamily: 'Ubuntu',
            fontSize: 17.0,
            height: 1.6,
            color: Color(0xFFE0E0E0),
          ),
          bodyMedium: const TextStyle(
            fontFamily: 'Ubuntu',
            fontSize: 14.0,
            color: Color(0xFFBDBDBD),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  int _currentSectionIndex = 0;

  final List<Widget> sections = [
    HeaderSection(),
    AboutSection(),
    ProjectsSection(),
    ResumeSection(),
    ProblemSolvingSection(),
    ContactSection(),
  ];

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(() {
      final positions = _itemPositionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        final firstVisibleIndex = positions
            .where((position) => position.itemLeadingEdge < 0.5)
            .fold<ItemPosition?>(null, (max, position) {
          if (max == null) return position;
          return position.itemLeadingEdge > max.itemLeadingEdge
              ? position
              : max;
        })?.index;

        if (firstVisibleIndex != null &&
            _currentSectionIndex != firstVisibleIndex) {
          setState(() {
            _currentSectionIndex = firstVisibleIndex;
          });
        }
      }
    });
  }

  void scrollToSection(int index) {
    _itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 950;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: isDesktop
              ? PulsingNavBar(
                  currentSectionIndex: _currentSectionIndex,
                  onNavTap: scrollToSection,
                )
              : AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(
                      color: Theme.of(context).colorScheme.primary),
                ),
          endDrawer: isDesktop
              ? null
              : Drawer(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _drawerItem(context, "Home", 0),
                      _drawerItem(context, "About", 1),
                      _drawerItem(context, "Projects", 2),
                      _drawerItem(context, "Resume", 3),
                      _drawerItem(context, "Problem Solving", 4),
                      _drawerItem(context, "Contact", 5),
                    ],
                  ),
                ),
          body: Stack(
            children: [
              const DynamicGridBackground(),
              const AuroraBackground(),
              ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                }),
                child: ValueListenableBuilder<Iterable<ItemPosition>>(
                  valueListenable: _itemPositionsListener.itemPositions,
                  builder: (context, positions, child) {
                    return ScrollablePositionedList.builder(
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener,
                      itemCount: sections.length,
                      itemBuilder: (context, index) {
                        ItemPosition? itemPosition;
                        try {
                          itemPosition =
                              positions.firstWhere((p) => p.index == index);
                        } catch (e) {
                          itemPosition = null;
                        }
                        return SectionWrapper(
                          itemPosition: itemPosition,
                          child: sections[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _drawerItem(BuildContext context, String title, int index) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: _currentSectionIndex == index
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        scrollToSection(index);
        Navigator.pop(context);
      },
    );
  }
}

class DynamicGridBackground extends StatefulWidget {
  const DynamicGridBackground({super.key});

  @override
  State<DynamicGridBackground> createState() => _DynamicGridBackgroundState();
}

class _DynamicGridBackgroundState extends State<DynamicGridBackground>
    with TickerProviderStateMixin {
  Offset _mousePosition = Offset.zero;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => setState(() => _mousePosition = event.localPosition),
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: GridPainter(
                time: _controller.value,
                mousePosition: _mousePosition,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final double time;
  final Offset mousePosition;
  final Color color;

  GridPainter({
    required this.time,
    required this.mousePosition,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const gridSpacing = 50.0;
    const perspective = 0.5;
    final vanishingPoint = Offset(size.width / 2, size.height * 0.4);

    final wave = (math.sin(time * 2 * math.pi) + 1) / 2;
    final scrollOffset = wave * gridSpacing;

    for (double i = -size.height * 2; i < size.height * 2; i += gridSpacing) {
      final y = vanishingPoint.dy + i + scrollOffset;
      final p = y / (size.height * 1.5);
      if (p < 0) continue;

      final fade = (1 - p).clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: (fade * 50));

      final x1 = vanishingPoint.dx - (size.width / 2) / (p * perspective + 1);
      final y1 = y;
      final x2 = vanishingPoint.dx + (size.width / 2) / (p * perspective + 1);
      final y2 = y;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    for (double i = 0; i < size.width; i += gridSpacing) {
      final x = i;
      final fade =
          (1 - (x - size.width / 2).abs() / (size.width / 2)).clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: (fade * 30));
      canvas.drawLine(Offset(x, 0), vanishingPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.mousePosition != mousePosition;
  }
}

class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground> {
  Offset _mousePosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
    ];

    return MouseRegion(
      onHover: (event) => setState(() => _mousePosition = event.localPosition),
      child: Stack(
        children: [
          ...colors.asMap().entries.map((entry) {
            final index = entry.key;
            final color = entry.value;
            return Positioned.fill(
              child: AnimatedPlasma(
                mousePosition: _mousePosition,
                color: color,
                index: index,
              ),
            );
          }),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                color: Colors.black.withValues(alpha: 60),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedPlasma extends StatelessWidget {
  const AnimatedPlasma({
    super.key,
    required this.mousePosition,
    required this.color,
    required this.index,
  });

  final Offset mousePosition;
  final Color color;
  final int index;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final alignmentX = -1.0 + (mousePosition.dx / size.width) * 2;
    final alignmentY = -1.0 + (mousePosition.dy / size.height) * 2;

    return LoopAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 15000 + (index * 5000)),
      builder: (context, value, child) {
        final transform = Matrix4.identity()
          ..translate(size.width / 2, size.height / 2)
          ..rotateZ(value * 2 * math.pi)
          ..translate(-size.width / 2, -size.height / 2);

        return Transform(
          transform: transform,
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            alignment: Alignment(alignmentX, alignmentY),
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              width: size.width * (0.8 + (index * 0.1)),
              height: size.height * (0.8 + (index * 0.1)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 100),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PulsingNavBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentSectionIndex;
  final Function(int) onNavTap;

  const PulsingNavBar({
    super.key,
    required this.currentSectionIndex,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'icon': Icons.home_rounded, 'text': 'Home', 'index': 0},
      {'icon': Icons.person_rounded, 'text': 'About', 'index': 1},
      {'icon': Icons.code_rounded, 'text': 'Projects', 'index': 2},
      {'icon': Icons.article_rounded, 'text': 'Resume', 'index': 3},
      {'icon': Icons.radar_rounded, 'text': 'Problem Solving', 'index': 4},
      {'icon': Icons.email_rounded, 'text': 'Contact', 'index': 5},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 180),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.white.withValues(alpha: 20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: navItems
                      .map((item) => PulsingNavButton(
                            icon: item['icon'] as IconData,
                            text: item['text'] as String,
                            isActive:
                                currentSectionIndex == item['index'] as int,
                            onPressed: () => onNavTap(item['index'] as int),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms, curve: Curves.easeOut)
        .slideY(begin: -2, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class PulsingNavButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const PulsingNavButton({
    super.key,
    required this.icon,
    required this.text,
    required this.isActive,
    required this.onPressed,
  });

  @override
  State<PulsingNavButton> createState() => _PulsingNavButtonState();
}

class _PulsingNavButtonState extends State<PulsingNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Tooltip(
          message: widget.text,
          child: LoopAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              final sineValue = (math.sin(value * 2 * math.pi) + 1) / 2;
              final pulseAmount =
                  _isHovered ? 15.0 : (widget.isActive ? 8.0 : 0.0);
              final pulseValue = sineValue * pulseAmount;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isActive ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    if (_isHovered || widget.isActive)
                      BoxShadow(
                        color: primaryColor,
                        blurRadius: pulseValue + 5,
                        spreadRadius: pulseValue / 3,
                      )
                  ],
                ),
                child: child,
              );
            },
            child: AnimatedScale(
              scale: _isHovered ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.icon,
                color: widget.isActive ? onPrimaryColor : Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionWrapper extends StatelessWidget {
  final Widget child;
  final ItemPosition? itemPosition;

  const SectionWrapper({
    super.key,
    required this.child,
    this.itemPosition,
  });

  @override
  Widget build(BuildContext context) {
    final double alignmentY = (itemPosition?.itemLeadingEdge ?? 0.5) * 0.4;

    final bool isVisible = itemPosition != null &&
        itemPosition!.itemLeadingEdge < 0.9 &&
        itemPosition!.itemTrailingEdge > 0.1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
      alignment: Alignment(0, alignmentY),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: child,
        ),
      ),
    )
        .animate(target: isVisible ? 1 : 0)
        .fadeIn(duration: 800.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.15, duration: 800.ms, curve: Curves.easeOutCubic);
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cvUrl = remoteConfigService.getString('cv_url');
    final mainPhotoUrl = remoteConfigService.getString('main_photo_url');
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.only(top: 80.0, bottom: 40.0),
      constraints:
          BoxConstraints(minHeight: MediaQuery.of(context).size.height - 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlayAnimationBuilder<double>(
            tween: Tween(begin: 5.0, end: 15.0),
            duration: const Duration(seconds: 4),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor,
                      blurRadius: 20 + value,
                      spreadRadius: 5 + (value / 3),
                    ),
                    BoxShadow(
                      color: theme.colorScheme.secondary,
                      blurRadius: 30 + value,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(mainPhotoUrl),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)),
          const SizedBox(height: 32),
          Text(
            'Mostafa Hashem',
            style: theme.textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Flutter Developer | Tech Enthusiast',
            style: theme.textTheme.titleLarge?.copyWith(
              color: primaryColor,
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _launchURL(cvUrl),
            icon: const Icon(Icons.download_rounded),
            label: const Text('View My CV'),
            style: ElevatedButton.styleFrom(
              foregroundColor: theme.colorScheme.onPrimary,
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Ubuntu',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  final List<String> techSkills = const [
    "Flutter",
    "Dart",
    "Java",
    "C++",
    "Firebase",
    "RESTful APIs",
    "Provider",
    "Cubit",
    "Git"
  ];
  final List<String> softSkills = const [
    "Fast Learner",
    "Teamwork",
    "Problem Solving"
  ];

  @override
  Widget build(BuildContext context) {
    return HolographicCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          return isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildTextContent(context)),
                    const SizedBox(width: 40),
                    Expanded(flex: 2, child: _buildImageContent(context)),
                  ],
                )
              : Column(
                  children: [
                    _buildTextContent(context),
                    const SizedBox(height: 40),
                    _buildImageContent(context),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    final workshopPhotoUrl =
        remoteConfigService.getString('workshop_photo_url');
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          workshopPhotoUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: 48,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).saturate();
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About Me.', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        Text(
          "Freelance Flutter Developer with 1.5 years of experience in creating cross-platform mobile apps. Currently a second-year student pursuing a Bachelor's in Computer and Information Technology. Passionate about clean code, fluid user interfaces, and solving real-world problems with technology. Eager to learn and contribute to innovative projects.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        _buildSkillsSection(context, 'Technical Skills', techSkills),
        const SizedBox(height: 24),
        _buildSkillsSection(context, 'Soft Skills', softSkills),
      ],
    );
  }

  Widget _buildSkillsSection(
      BuildContext context, String title, List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: skills.map((skill) => SkillChip(skill: skill)).toList(),
        ),
      ],
    );
  }
}

class Project {
  final String title;
  final String description;
  final List<String> technologies;
  final String? githubUrlKey;
  final String? apkUrlKey;

  Project({
    required this.title,
    required this.description,
    required this.technologies,
    this.githubUrlKey,
    this.apkUrlKey,
  });
}

class ProjectsSection extends StatelessWidget {
  ProjectsSection({super.key});

  final List<Project> projects = [
    Project(
      title: 'Talksy',
      description:
          'A real-time cross-platform chat application with user authentication and a clean, responsive UI.',
      technologies: ['Flutter', 'Firebase Auth', 'Firestore', 'Cubit'],
      apkUrlKey: 'talksy_apk_url',
    ),
    Project(
      title: 'Movie App',
      description:
          'A movie discovery app to browse popular titles, view details, and search, using a public movie API.',
      technologies: ['Flutter', 'RESTful APIs', 'Provider'],
      githubUrlKey: 'project_movies_github_url',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('My Work.', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 40),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 30,
              runSpacing: 30,
              alignment: WrapAlignment.center,
              children: projects
                  .map((project) => ProjectCard(project: project))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final String? githubUrl = project.githubUrlKey != null
        ? remoteConfigService.getString(project.githubUrlKey!)
        : null;

    final String? apkUrl = project.apkUrlKey != null
        ? remoteConfigService.getString(project.apkUrlKey!)
        : null;

    return SizedBox(
      width: 360,
      child: HolographicCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              project.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: project.technologies
                  .map((tech) => SkillChip(skill: tech))
                  .toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (githubUrl != null && githubUrl.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.code),
                    color: primaryColor,
                    tooltip: 'View Source Code',
                    onPressed: () => _launchURL(githubUrl),
                  ),
                if (apkUrl != null && apkUrl.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.download_for_offline),
                    color: primaryColor,
                    tooltip: 'Download APK',
                    onPressed: () => _launchURL(apkUrl),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ResumeItem {
  final String title;
  final String organization;
  final String period;
  final IconData icon;
  final String? certificateUrl;

  ResumeItem({
    required this.title,
    required this.organization,
    required this.period,
    required this.icon,
    this.certificateUrl,
  });
}

class ResumeSection extends StatelessWidget {
  ResumeSection({super.key});

  final List<ResumeItem> experience = [
    ResumeItem(
      title: 'Freelance Flutter Developer',
      organization: 'Self-Employed',
      period: 'July 2023 - Present',
      icon: Icons.work_history,
    ),
    ResumeItem(
      title: 'Vice of Flutter Team',
      organization: 'GDSC Sohag',
      period: 'Started Sep 2024',
      icon: Icons.groups,
    ),
  ];

  final List<ResumeItem> education = [
    ResumeItem(
      title: 'Bachelor of Computer and Information Technology',
      organization: 'EELU University, Sohag',
      period: 'Sep 2023 - Present',
      icon: Icons.school,
    ),
    ResumeItem(
      title: 'Flutter Development Diploma',
      organization: 'Route Academy',
      period: 'July 2023',
      icon: Icons.military_tech,
      certificateUrl:
          'https://placehold.co/800x600/0A0A14/00F5D4?text=Flutter+Diploma',
    ),
    ResumeItem(
      title: 'Programming and Fundamental Diploma',
      organization: 'Route Academy',
      period: 'November 2023',
      icon: Icons.military_tech,
      certificateUrl:
          'https://placehold.co/800x600/0A0A14/00F5D4?text=Programming+Diploma',
    ),
    ResumeItem(
      title: 'Trainer of Trainers (TOT) Certificate',
      organization: 'Syndicate of Human Development Trainers',
      period: 'October 2024',
      icon: Icons.military_tech,
      certificateUrl: '',
    ),
    ResumeItem(
      title: 'Mentor Certificate - Atomica Team',
      organization: 'Atomica Team',
      period: 'November 2023',
      icon: Icons.military_tech,
      certificateUrl:
          'https://drive.google.com/file/d/17wvQFjBw5UhTlnBxOvH5ohKBx7z7A9XJ/view?usp=sharing',
    ),
    ResumeItem(
      title: 'Flutter Instructor Certificate',
      organization: 'Extra Media Team',
      period: '2024',
      icon: Icons.military_tech,
      certificateUrl:
          'https://drive.google.com/file/d/1GhFH6chsa_naNx2bGYbJvYJp5iJQVDLk/view?usp=sharing',
    ),
    ResumeItem(
      title: 'Flutter Instructor Certificate',
      organization: 'Yes Course Team ',
      period: '2024',
      icon: Icons.military_tech,
      certificateUrl:
          'https://drive.google.com/file/d/1GXJD8odXRElFHTEuzo1NoNEo1U1HC36z/view?usp=sharing',
    ),
    ResumeItem(
      title: 'GDSC Sohag Certificates',
      organization: 'Vice of Flutter section',
      period: '2024',
      icon: Icons.military_tech,
      certificateUrl:
          'https://drive.google.com/file/d/1GqdCu-aIKkoTJh6Z17ijRl9cUjTqoxr_/view?usp=sharing',
    ),
    ResumeItem(
      title: 'GDSC Hurghada Certificates',
      organization: 'Academic Member',
      period: '2024',
      icon: Icons.military_tech,
      certificateUrl:
          'https://drive.google.com/file/d/1GjGEHeauYOr-3NoWZFTPFWKUhG-HbPYS/view?usp=sharing',
    ),
  ];

  final List<ResumeItem> volunteering = [
    ResumeItem(
      title: 'Mentor at Atomica Team',
      organization: 'Mentored participants in a Flutter workshop.',
      period: 'November 2023',
      icon: Icons.volunteer_activism,
    ),
    ResumeItem(
      title: 'Flutter Instructor',
      organization: 'Yes Course Team & Extra Media Team',
      period: '2024',
      icon: Icons.volunteer_activism,
    ),
    ResumeItem(
      title: 'GDSC Contributor',
      organization: 'Academic Member at Hurghada & Vice at Sohag',
      period: '2024',
      icon: Icons.volunteer_activism,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return HolographicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Journey.',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 40),
          _buildTimeline(context, 'Experience', experience),
          const SizedBox(height: 40),
          _buildTimeline(context, 'Education & Certifications', education),
          const SizedBox(height: 40),
          _buildTimeline(context, 'Activities & Volunteering', volunteering),
        ],
      ),
    );
  }

  Widget _buildTimeline(
      BuildContext context, String title, List<ResumeItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        ...items.map((item) => TimelineCard(item: item)),
      ],
    );
  }
}

class TimelineCard extends StatelessWidget {
  final ResumeItem item;

  const TimelineCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: primaryColor, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  item.organization,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  item.period,
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: primaryColor),
                ),
              ],
            ),
          ),
          if (item.certificateUrl != null &&
              item.certificateUrl!.isNotEmpty &&
              item.certificateUrl != '#')
            Tooltip(
              message: 'View Certificate',
              child: IconButton(
                icon: Icon(Icons.open_in_new, color: primaryColor),
                onPressed: () => _launchURL(item.certificateUrl!),
              ),
            ),
        ],
      ),
    );
  }
}

class ProblemSolvingSection extends StatelessWidget {
  const ProblemSolvingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vjudgeUrl = remoteConfigService.getString('vjudge_url');
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return HolographicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Problem Solving.', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 24),
          Text(
            "Actively practicing problem-solving skills on VJudge to improve algorithmic thinking and coding efficiency.",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          InkWell(
            onTap: () => _launchURL(vjudgeUrl),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'VJudge Profile: Mostafa_Hashem',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: primaryColor,
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                      decorationColor: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.open_in_new, color: primaryColor)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final githubUrl = remoteConfigService.getString('github_url');
    final linkedinUrl = remoteConfigService.getString('linkedin_url');
    final email = remoteConfigService.getString('contact_email');
    final phone = remoteConfigService.getString('contact_phone');

    return HolographicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Get In Touch.', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 24),
          Text(
            "I'm currently available for freelance work and open to discussing new projects. Feel free to reach out!",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 40),
          _buildContactInfo(
            context,
            icon: Icons.email_outlined,
            text: email,
            onTap: () => _launchURL('mailto:$email'),
          ),
          const SizedBox(height: 20),
          _buildContactInfo(
            context,
            icon: Icons.phone_outlined,
            text: phone,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(
                  Icons.code_sharp, () => _launchURL(githubUrl), "GitHub"),
              const SizedBox(width: 24),
              _buildSocialIcon(
                  const IconData(0xf08c, fontFamily: 'MaterialIcons'),
                  () => _launchURL(linkedinUrl),
                  "LinkedIn"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context,
      {required IconData icon, required String text, VoidCallback? onTap}) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                decoration: onTap != null ? TextDecoration.underline : null,
                decorationColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(
      IconData icon, VoidCallback onPressed, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 32, color: Colors.white),
        ),
      ),
    ).animate().scale();
  }
}

class HolographicCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const HolographicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  State<HolographicCard> createState() => _HolographicCardState();
}

class _HolographicCardState extends State<HolographicCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 77),
              blurRadius: _isHovered ? 35 : 20,
              spreadRadius: _isHovered ? 0 : -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.surface.withAlpha(210),
                  theme.colorScheme.surface.withAlpha(190),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: primaryColor.withAlpha(_isHovered ? 250 : 150),
                width: _isHovered ? 2 : 1.5,
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class SkillChip extends StatefulWidget {
  final String skill;

  const SkillChip({super.key, required this.skill});

  @override
  State<SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<SkillChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isHovered
              ? primaryColor.withValues(alpha: 25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor,
          ),
        ),
        child: Text(
          widget.skill,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ).animate(target: _isHovered ? 1 : 0).scaleXY(end: 1.05);
  }
}
