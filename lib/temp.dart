// import 'package:flutter/gestures.dart';
//
// import 'package:flutter/material.dart';
//
// import 'package:portfolio/firebase_options.dart';
//
// import 'dart:ui';
//
// import 'package:url_launcher/url_launcher.dart';
//
// import 'package:flutter_animate/flutter_animate.dart';
//
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
//
// import 'package:firebase_core/firebase_core.dart';
//
// import 'package:firebase_remote_config/firebase_remote_config.dart';
//
// // --- Remote Config Service ---
//
// class RemoteConfigService {
//   final FirebaseRemoteConfig _remoteConfig;
//
//   RemoteConfigService._(this._remoteConfig);
//
//   static Future<RemoteConfigService> init() async {
//     final remoteConfig = FirebaseRemoteConfig.instance;
//
//     await remoteConfig.setConfigSettings(RemoteConfigSettings(
//       fetchTimeout: const Duration(minutes: 1),
//       minimumFetchInterval: const Duration(hours: 1),
//     ));
//
//     await remoteConfig.setDefaults(const {
//       "talksy_apk_url": "https://example.com/default_talksy.apk",
//
//       "cv_url":
//       "https://drive.google.com/file/d/1vRqnKnodWb43oHJ8ykKVcmRdgpJ1gFbK/view?usp=sharing",
//
//       "main_photo_url": "https://via.placeholder.com/160", // Fallback URL
//
//       "workshop_photo_url": "https://via.placeholder.com/400", // Fallback URL
//     });
//
//     try {
//       await remoteConfig.fetchAndActivate();
//     } catch (e) {
//       print('Remote Config fetch failed: $e');
//     }
//
//     return RemoteConfigService._(remoteConfig);
//   }
//
//   String getString(String key) => _remoteConfig.getString(key);
// }
//
// late final RemoteConfigService remoteConfigService;
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   remoteConfigService = await RemoteConfigService.init();
//
//   runApp(const PortfolioApp());
// }
//
// void _launchURL(String url) async {
//   final Uri uri = Uri.parse(url);
//
//   if (!await launchUrl(uri)) {
//     throw 'Could not launch $url';
//   }
// }
//
// class PortfolioApp extends StatelessWidget {
//   const PortfolioApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Mostafa Hashem',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         brightness: Brightness.dark,
//         primaryColor: const Color(0xFF00F5D4),
//         scaffoldBackgroundColor: const Color(0xFF0A0A14),
//         colorScheme: const ColorScheme.dark(
//           primary: Color(0xFF00F5D4),
//           secondary: Color(0xFF9B59B6),
//           surface: Color(0xFF1A1A24),
//           onPrimary: Colors.black,
//           onSecondary: Colors.white,
//           onSurface: Colors.white,
//         ),
//         textTheme: TextTheme(
//           displayLarge: TextStyle(
//               fontSize: 52.0,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               fontFamily: 'Ubuntu',
//               letterSpacing: 1.5),
//           headlineMedium: TextStyle(
//               fontSize: 28.0,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//               fontFamily: 'Ubuntu'),
//           titleLarge: TextStyle(
//               fontSize: 22.0,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               fontFamily: 'Ubuntu'),
//           bodyLarge: TextStyle(
//               fontSize: 16.0,
//               color: Colors.white,
//               height: 1.5,
//               fontFamily: 'Ubuntu'),
//           bodyMedium: TextStyle(
//               fontSize: 14.0,
//               color: Colors.white.withValues(alpha: 180),
//               fontFamily: 'Ubuntu'),
//         ),
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const HomePage(),
//     );
//   }
// }
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
//   late AnimationController _bgAnimationController;
//
//   late Animation<double> _bgAnimation;
//
//   final ItemScrollController _itemScrollController = ItemScrollController();
//
//   final ItemPositionsListener _itemPositionsListener =
//   ItemPositionsListener.create();
//
//   int _currentSectionIndex = 0;
//
//   final List<Widget> sections = [
//     HeaderSection(),
//     AboutSection(),
//     ProjectsSection(),
//     ResumeSection(),
//     ContactSection(),
//     ProblemSolvingSection(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//
//     _bgAnimationController = AnimationController(
//       duration: const Duration(seconds: 15),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _bgAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(CurvedAnimation(
//       parent: _bgAnimationController,
//       curve: Curves.easeInOutSine,
//     ));
//
//     _itemPositionsListener.itemPositions.addListener(() {
//       final positions = _itemPositionsListener.itemPositions.value;
//
//       if (positions.isNotEmpty) {
//         final firstVisibleIndex = positions
//             .where((position) => position.itemLeadingEdge < 0.5)
//             .reduce((max, position) =>
//         position.itemLeadingEdge > max.itemLeadingEdge ? position : max)
//             .index;
//
//         if (_currentSectionIndex != firstVisibleIndex) {
//           setState(() {
//             _currentSectionIndex = firstVisibleIndex;
//           });
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _bgAnimationController.dispose();
//
//     super.dispose();
//   }
//
//   void scrollToSection(int index) {
//     _itemScrollController.scrollTo(
//       index: index,
//       duration: const Duration(milliseconds: 1200),
//       curve: Curves.easeInOutCubic,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isDesktop = constraints.maxWidth > 950;
//
//         return Scaffold(
//           extendBodyBehindAppBar: true,
//           appBar: CustomAppBar(
//             isDesktop: isDesktop,
//             currentSectionIndex: _currentSectionIndex,
//             onHomeTap: () => scrollToSection(0),
//             onAboutTap: () => scrollToSection(1),
//             onProjectsTap: () => scrollToSection(2),
//             onResumeTap: () => scrollToSection(3),
//             onContactTap: () => scrollToSection(4),
//           ),
//           endDrawer: isDesktop
//               ? null
//               : Drawer(
//             backgroundColor: const Color(0xFF0A0A14),
//             child: ListView(
//               children: [
//                 _drawerItem(context, "Home", () => scrollToSection(0)),
//                 _drawerItem(context, "About", () => scrollToSection(1)),
//                 _drawerItem(
//                     context, "Projects", () => scrollToSection(2)),
//                 _drawerItem(context, "Resume", () => scrollToSection(3)),
//                 _drawerItem(context, "Contact", () => scrollToSection(4)),
//               ],
//             ),
//           ),
//           body: Stack(
//             children: [
//               AnimatedBuilder(
//                 animation: _bgAnimation,
//                 builder: (context, child) {
//                   return Container(
//                     decoration: BoxDecoration(
//                       gradient: RadialGradient(
//                         colors: [
//                           Theme.of(context)
//                               .colorScheme
//                               .secondary
//                               .withValues(alpha: 70),
//                           Theme.of(context).scaffoldBackgroundColor,
//                         ],
//                         center: Alignment.center,
//                         radius: _bgAnimation.value * 2,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               ScrollConfiguration(
//                 behavior:
//                 ScrollConfiguration.of(context).copyWith(dragDevices: {
//                   PointerDeviceKind.touch,
//                   PointerDeviceKind.mouse,
//                 }),
//                 child: ScrollablePositionedList.builder(
//                   itemScrollController: _itemScrollController,
//                   itemPositionsListener: _itemPositionsListener,
//                   itemCount: sections.length,
//                   itemBuilder: (context, index) {
//                     return SectionWrapper(child: sections[index]);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _drawerItem(BuildContext context, String title, VoidCallback onTap) {
//     return ListTile(
//       title: Text(title,
//           style: const TextStyle(
//               fontSize: 18, color: Colors.white, fontFamily: 'Ubuntu')),
//       onTap: () {
//         onTap();
//
//         Navigator.pop(context);
//       },
//     );
//   }
// }
//
// class _NavButton extends StatefulWidget {
//   final String text;
//
//   final IconData icon;
//
//   final VoidCallback onPressed;
//
//   final bool isActive;
//
//   const _NavButton({
//     required this.text,
//     required this.icon,
//     required this.onPressed,
//     required this.isActive,
//   });
//
//   @override
//   _NavButtonState createState() => _NavButtonState();
// }
//
// class _NavButtonState extends State<_NavButton> with TickerProviderStateMixin {
//   bool _isHovered = false;
//
//   late AnimationController _tapController;
//
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _tapController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 100),
//       reverseDuration: const Duration(milliseconds: 200),
//     );
//
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
//         CurvedAnimation(parent: _tapController, curve: Curves.easeOut));
//   }
//
//   @override
//   void dispose() {
//     _tapController.dispose();
//
//     super.dispose();
//   }
//
//   void _onTapDown(TapDownDetails details) {
//     _tapController.forward();
//   }
//
//   void _onTapUp(TapUpDetails details) {
//     _tapController.reverse().then((_) => widget.onPressed());
//   }
//
//   void _onTapCancel() {
//     _tapController.reverse();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = Theme.of(context).colorScheme.primary;
//
//     final iconColor = widget.isActive ? primaryColor : Colors.white;
//
//     final isGlow = _isHovered || widget.isActive;
//
//     return MouseRegion(
//       onEnter: (event) => setState(() => _isHovered = true),
//       onExit: (event) => setState(() => _isHovered = false),
//       child: GestureDetector(
//         onTapDown: _onTapDown,
//         onTapUp: _onTapUp,
//         onTapCancel: _onTapCancel,
//         child: Tooltip(
//           message: widget.text,
//           child: ScaleTransition(
//             scale: _scaleAnimation,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeOut,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               decoration: BoxDecoration(
//                 color: widget.isActive
//                     ? primaryColor.withValues(alpha: 100)
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: isGlow
//                     ? [
//                   BoxShadow(
//                     color: primaryColor.withValues(alpha: 80),
//                     blurRadius: 5,
//                     spreadRadius: 0,
//                   ),
//                 ]
//                     : [],
//               ),
//               child: Icon(widget.icon, color: iconColor, size: 24),
//             ),
//           ),
//         ),
//       ),
//     ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
//   }
// }
//
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final bool isDesktop;
//
//   final int currentSectionIndex;
//
//   final VoidCallback onHomeTap;
//
//   final VoidCallback onAboutTap;
//
//   final VoidCallback onProjectsTap;
//
//   final VoidCallback onResumeTap;
//
//   final VoidCallback onContactTap;
//
//   const CustomAppBar(
//       {super.key,
//         required this.isDesktop,
//         required this.currentSectionIndex,
//         required this.onHomeTap,
//         required this.onAboutTap,
//         required this.onProjectsTap,
//         required this.onResumeTap,
//         required this.onContactTap});
//
//   @override
//   Widget build(BuildContext context) {
//     final double appBarAlpha = currentSectionIndex > 0 ? 150.0 : 0.0;
//
//     final double blurSigma = currentSectionIndex > 0 ? 8.0 : 0.0;
//
//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 400),
//           curve: Curves.easeOut,
//           color: Theme.of(context)
//               .scaffoldBackgroundColor
//               .withAlpha(appBarAlpha.toInt()),
//           child: AppBar(
//             automaticallyImplyLeading: false,
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             title: isDesktop
//                 ? null
//                 : Text(
//               'Mostafa Hashem',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Ubuntu',
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             ),
//             centerTitle: false,
//             actions: isDesktop
//                 ? [
//               const Spacer(),
//               _NavButton(
//                 text: 'Home',
//                 icon: Icons.home_rounded,
//                 onPressed: onHomeTap,
//                 isActive: currentSectionIndex == 0,
//               ),
//               _NavButton(
//                 text: 'About',
//                 icon: Icons.person_rounded,
//                 onPressed: onAboutTap,
//                 isActive: currentSectionIndex == 1,
//               ),
//               _NavButton(
//                 text: 'Projects',
//                 icon: Icons.code_rounded,
//                 onPressed: onProjectsTap,
//                 isActive: currentSectionIndex == 2,
//               ),
//               _NavButton(
//                 text: 'Resume',
//                 icon: Icons.article_rounded,
//                 onPressed: onResumeTap,
//                 isActive: currentSectionIndex == 3,
//               ),
//               _NavButton(
//                 text: 'Contact',
//                 icon: Icons.email_rounded,
//                 onPressed: onContactTap,
//                 isActive:
//                 currentSectionIndex == 4 || currentSectionIndex == 5,
//               ),
//               const Spacer(),
//             ]
//                 : [
//               Builder(builder: (context) {
//                 return IconButton(
//                   icon: const Icon(Icons.menu),
//                   onPressed: () => Scaffold.of(context).openEndDrawer(),
//                 );
//               })
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
//
// class SectionWrapper extends StatelessWidget {
//   final Widget child;
//
//   const SectionWrapper({super.key, required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 40.0),
//       child: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 1100),
//           child: child
//               .animate(onInit: (controller) => controller.forward())
//               .fadeIn(duration: 800.ms)
//               .slideY(
//               begin: 0.3, duration: 800.ms, curve: Curves.easeInOutCubic),
//         ),
//       ),
//     );
//   }
// }
//
// class HeaderSection extends StatelessWidget {
//   const HeaderSection({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final cvUrl = remoteConfigService.getString('cv_url');
//
//     final mainPhotoUrl = remoteConfigService.getString('main_photo_url');
//
//     return Padding(
//       padding: const EdgeInsets.only(top: 80.0),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 80,
//
//             backgroundColor:
//             Theme.of(context).colorScheme.primary.withValues(alpha: 50),
//
// // Use NetworkImage to load from a URL
//
//             backgroundImage: NetworkImage(mainPhotoUrl),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'Mostafa Hashem',
//             style: Theme.of(context)
//                 .textTheme
//                 .displayLarge
//                 ?.copyWith(fontSize: 48),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Flutter Developer | Tech Enthusiast',
//             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//               fontSize: 22,
//               color: Theme.of(context).colorScheme.primary,
//               fontWeight: FontWeight.w400,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () => _launchURL(cvUrl),
//             style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.black,
//                 backgroundColor: Theme.of(context).colorScheme.primary,
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 textStyle: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Ubuntu',
//                 )),
//             child: const Text('View CV'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class AboutSection extends StatefulWidget {
//   const AboutSection({super.key});
//
//   @override
//   State<AboutSection> createState() => _AboutSectionState();
// }
//
// class _AboutSectionState extends State<AboutSection> {
//   bool _isHovered = false;
//
//   final List<String> techSkills = [
//     "Flutter",
//     "Dart",
//     "Java",
//     "C++",
//     "Firebase",
//     "RESTful APIs",
//     "Provider",
//     "Cubit",
//     "Git"
//   ];
//
//   final List<String> softSkills = [
//     "Fast Learner",
//     "Teamwork",
//     "Problem Solving"
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOut,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: _isHovered
//               ? [
//             BoxShadow(
//               color: Theme.of(context)
//                   .colorScheme
//                   .primary
//                   .withValues(alpha: 100),
//               blurRadius: 20,
//               spreadRadius: 2,
//             ),
//             BoxShadow(
//               color: Theme.of(context)
//                   .colorScheme
//                   .secondary
//                   .withValues(alpha: 50),
//               blurRadius: 30,
//               spreadRadius: -5,
//             ),
//           ]
//               : [],
//         ),
//         child: GlassmorphicContainer(
//           child: Padding(
//             padding: const EdgeInsets.all(40.0),
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 bool isDesktop = constraints.maxWidth > 800;
//
//                 return isDesktop
//                     ? _buildDesktopLayout(context)
//                     : _buildMobileLayout(context);
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDesktopLayout(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 3,
//           child: _buildTextContent(context),
//         ),
//         const SizedBox(width: 40),
//         Expanded(
//           flex: 2,
//           child: _buildImageContent(context),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMobileLayout(BuildContext context) {
//     return Column(
//       children: [
//         _buildTextContent(context),
//         const SizedBox(height: 40),
//         _buildImageContent(context),
//       ],
//     );
//   }
//
//   Widget _buildImageContent(BuildContext context) {
//     final workshopPhotoUrl =
//     remoteConfigService.getString('workshop_photo_url');
//
//     return Center(
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Image.network(
//           workshopPhotoUrl,
//
//           fit: BoxFit.cover,
//
//           loadingBuilder: (context, child, loadingProgress) {
//             if (loadingProgress == null) return child;
//
//             return Center(
//               child: CircularProgressIndicator(
//                 value: loadingProgress.expectedTotalBytes != null
//                     ? loadingProgress.cumulativeBytesLoaded /
//                     loadingProgress.expectedTotalBytes!
//                     : null,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             );
//           },
//
// // Show an error icon if the image fails to load
//
//           errorBuilder: (context, error, stackTrace) {
//             return const Icon(
//               Icons.error_outline,
//               color: Colors.redAccent,
//               size: 48,
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextContent(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('About Me.', style: Theme.of(context).textTheme.displayLarge),
//         const SizedBox(height: 24),
//         Text(
//           "Freelance Flutter Developer with 1.5 years of experience in creating cross-platform mobile apps. Currently a second-year student pursuing a Bachelor's in Computer and Information Technology. Passionate about clean code, fluid user interfaces, and solving real-world problems with technology. Eager to learn and contribute to innovative projects.",
//           style: Theme.of(context).textTheme.bodyLarge,
//         ),
//         const SizedBox(height: 32),
//         _buildSkillsSection(context, 'Technical Skills', techSkills),
//         const SizedBox(height: 24),
//         _buildSkillsSection(context, 'Soft Skills', softSkills),
//       ],
//     );
//   }
//
//   Widget _buildSkillsSection(
//       BuildContext context, String title, List<String> skills) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: Theme.of(context).textTheme.headlineMedium),
//         const SizedBox(height: 16),
//         Wrap(
//           spacing: 12,
//           runSpacing: 12,
//           children: skills
//               .map((skill) => Chip(
//             label: Text(skill),
//             backgroundColor: Theme.of(context).colorScheme.surface,
//             labelStyle: TextStyle(
//                 color: Theme.of(context).colorScheme.primary,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Ubuntu'),
//             padding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//               side: BorderSide(
//                 color: Theme.of(context)
//                     .colorScheme
//                     .primary
//                     .withValues(alpha: 200),
//               ),
//             ),
//           ))
//               .toList(),
//         ),
//       ],
//     );
//   }
// }
//
// class Project {
//   final String title;
//
//   final String description;
//
//   final List<String> technologies;
//
//   final String? githubUrl;
//
//   final String? apkUrlKey;
//
//   final String? fallbackApkUrl;
//
//   Project({
//     required this.title,
//     required this.description,
//     required this.technologies,
//     this.githubUrl,
//     this.apkUrlKey,
//     this.fallbackApkUrl,
//   });
// }
//
// class ProjectsSection extends StatelessWidget {
//   ProjectsSection({super.key});
//
//   final List<Project> projects = [
//     Project(
//       title: 'Talksy',
//       description:
//       'A real-time cross-platform chat application with user authentication and a clean, responsive UI.',
//       technologies: ['Flutter', 'Firebase Auth', 'Firestore', 'Cubit'],
//       apkUrlKey: 'talksy_apk_url',
//       fallbackApkUrl: 'https://example.com/talksy.apk',
//     ),
//     Project(
//       title: 'Movie App',
//       description:
//       'A movie discovery app to browse popular titles, view details, and search, using a public movie API.',
//       technologies: ['Flutter', 'RESTful APIs', 'Provider'],
//       githubUrl: 'https://github.com/mostafa-hashem/Movies-App',
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('My Work.', style: Theme.of(context).textTheme.displayLarge),
//           const SizedBox(height: 40),
//           LayoutBuilder(
//             builder: (context, constraints) {
//               return Wrap(
//                 spacing: 20,
//                 runSpacing: 20,
//                 alignment: WrapAlignment.center,
//                 children: projects
//                     .map((project) => ProjectCard(project: project))
//                     .toList(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ProjectCard extends StatefulWidget {
//   final Project project;
//
//   const ProjectCard({super.key, required this.project});
//
//   @override
//   State<ProjectCard> createState() => _ProjectCardState();
// }
//
// class _ProjectCardState extends State<ProjectCard> {
//   bool _isHovered = false;
//
//   String? _dynamicApkUrl;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _fetchDynamicUrl();
//   }
//
//   void _fetchDynamicUrl() {
//     if (widget.project.apkUrlKey != null) {
//       final url = remoteConfigService.getString(widget.project.apkUrlKey!);
//
//       if (url.isNotEmpty) {
//         setState(() {
//           _dynamicApkUrl = url;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final String? finalApkUrl = _dynamicApkUrl ?? widget.project.fallbackApkUrl;
//
//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOut,
//         width: 350,
//         transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: _isHovered
//               ? [
//             BoxShadow(
//               color: Theme.of(context)
//                   .colorScheme
//                   .primary
//                   .withValues(alpha: 100),
//               blurRadius: 20,
//               spreadRadius: 2,
//             ),
//             BoxShadow(
//               color: Theme.of(context)
//                   .colorScheme
//                   .secondary
//                   .withValues(alpha: 50),
//               blurRadius: 30,
//               spreadRadius: -5,
//             ),
//           ]
//               : [],
//         ),
//         child: GlassmorphicContainer(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.project.title,
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                         color: Theme.of(context).colorScheme.primary)),
//                 const SizedBox(height: 12),
//                 Text(widget.project.description,
//                     style: Theme.of(context).textTheme.bodyMedium),
//                 const SizedBox(height: 20),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: widget.project.technologies
//                       .map((tech) => Chip(
//                     label: Text(tech),
//                     backgroundColor: Colors.transparent,
//                     labelStyle: TextStyle(
//                       color: Theme.of(context).colorScheme.primary,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Ubuntu',
//                     ),
//                     shape: StadiumBorder(
//                       side: BorderSide(
//                         color: Theme.of(context)
//                             .colorScheme
//                             .primary
//                             .withValues(alpha: 180),
//                         width: 1.5,
//                       ),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 5),
//                   ))
//                       .toList(),
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     if (widget.project.githubUrl != null)
//                       IconButton(
//                         icon: const Icon(Icons.code),
//                         color: Theme.of(context).colorScheme.primary,
//                         tooltip: 'View Source Code',
//                         onPressed: () => _launchURL(widget.project.githubUrl!),
//                       ),
//                     if (finalApkUrl != null)
//                       IconButton(
//                         icon: const Icon(Icons.download_for_offline),
//                         color: Theme.of(context).colorScheme.primary,
//                         tooltip: 'Download APK',
//                         onPressed: () => _launchURL(finalApkUrl),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class ResumeItem {
//   final String title;
//
//   final String organization;
//
//   final String period;
//
//   final IconData icon;
//
//   final String? certificateUrl;
//
//   ResumeItem({
//     required this.title,
//     required this.organization,
//     required this.period,
//     required this.icon,
//     this.certificateUrl,
//   });
// }
//
// class ResumeSection extends StatefulWidget {
//   const ResumeSection({super.key});
//
//   @override
//   State<ResumeSection> createState() => _ResumeSectionState();
// }
//
// class _ResumeSectionState extends State<ResumeSection> {
//   bool _isHovered = false;
//
//   final List<ResumeItem> experience = [
//     ResumeItem(
//       title: 'Freelance Flutter Developer',
//       organization: 'Self-Employed',
//       period: 'July 2023 - Present',
//       icon: Icons.work_history,
//     ),
//     ResumeItem(
//       title: 'Vice of Flutter Team',
//       organization: 'GDSC Sohag',
//       period: 'Started Sep 2024',
//       icon: Icons.groups,
//     ),
//   ];
//
//   final List<ResumeItem> education = [
//     ResumeItem(
//       title: 'Bachelor of Computer and Information Technology',
//       organization: 'EELU University, Sohag',
//       period: 'Sep 2023 - Present',
//       icon: Icons.school,
//     ),
//     ResumeItem(
//       title: 'Flutter Development Diploma',
//       organization: 'Route Academy',
//       period: 'July 2023',
//       icon: Icons.military_tech,
//       certificateUrl:
//       'https://placehold.co/800x600/0A0A14/00F5D4?text=Flutter+Diploma',
//     ),
//     ResumeItem(
//       title: 'Programming and Fundamental Diploma',
//       organization: 'Route Academy',
//       period: 'November 2023',
//       icon: Icons.military_tech,
//       certificateUrl:
//       'https://placehold.co/800x600/0A0A14/00F5D4?text=Programming+Diploma',
//     ),
//     ResumeItem(
//       title: 'Trainer of Trainers (TOT) Certificate',
//       organization: 'Syndicate of Human Development Trainers',
//       period: 'October 2024',
//       icon: Icons.military_tech,
//       certificateUrl:
//       'https://placehold.co/800x600/0A0A14/00F5D4?text=TOT+Certificate',
//     ),
//     ResumeItem(
//       title: 'Mentor Certificate - Atomica Team',
//       organization: 'Atomica Team',
//       period: 'November 2023',
//       icon: Icons.military_tech,
//       certificateUrl:
//       'https://placehold.co/800x600/0A0A14/00F5D4?text=Mentor+Certificate',
//     ),
//     ResumeItem(
//       title: 'Flutter Instructor Certificate',
//       organization: 'Yes Course Team & Extra Media Team',
//       period: '2024',
//       icon: Icons.military_tech,
//       certificateUrl:
//       'https://placehold.co/800x600/0A0A14/00F5D4?text=Instructor+Certificate',
//     ),
//     ResumeItem(
//       title: 'GDSC Certificates',
//       organization: 'Academic Member (Hurghada) & Vice (Sohag)',
//       period: '2024',
//       icon: Icons.military_tech,
//       certificateUrl:
//       'https://placehold.co/800x600/0A0A14/00F5D4?text=GDSC+Certificate',
//     ),
//   ];
//
//   final List<ResumeItem> volunteering = [
//     ResumeItem(
//       title: 'Mentor at Atomica Team',
//       organization: 'Mentored participants in a Flutter workshop.',
//       period: 'November 2023',
//       icon: Icons.volunteer_activism,
//     ),
//     ResumeItem(
//       title: 'Flutter Instructor',
//       organization: 'Yes Course Team & Extra Media Team',
//       period: '2024',
//       icon: Icons.volunteer_activism,
//     ),
//     ResumeItem(
//       title: 'GDSC Contributor',
//       organization: 'Academic Member at Hurghada & Vice at Sohag',
//       period: '2024',
//       icon: Icons.volunteer_activism,
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOut,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: _isHovered
//               ? [
//             BoxShadow(
//               color: Theme.of(context)
//                   .colorScheme
//                   .primary
//                   .withValues(alpha: 100),
//               blurRadius: 20,
//               spreadRadius: 2,
//             ),
//             BoxShadow(
//               color: Theme.of(context)
//                   .colorScheme
//                   .secondary
//                   .withValues(alpha: 50),
//               blurRadius: 30,
//               spreadRadius: -5,
//             ),
//           ]
//               : [],
//         ),
//         child: GlassmorphicContainer(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('My Journey.',
//                     style: Theme.of(context).textTheme.displayLarge),
//                 const SizedBox(height: 40),
//                 _buildTimeline(context, 'Experience', experience),
//                 const SizedBox(height: 40),
//                 _buildTimeline(
//                     context, 'Education & Certifications', education),
//                 const SizedBox(height: 40),
//                 _buildTimeline(
//                     context, 'Activities & Volunteering', volunteering),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTimeline(
//       BuildContext context, String title, List<ResumeItem> items) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title,
//             style: Theme.of(context)
//                 .textTheme
//                 .headlineMedium
//                 ?.copyWith(color: Colors.white)),
//         const SizedBox(height: 24),
//         ...items.map((item) => TimelineCard(item: item)).toList(),
//       ],
//     );
//   }
// }
//
// class TimelineCard extends StatelessWidget {
//   final ResumeItem item;
//
//   const TimelineCard({super.key, required this.item});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 24.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(item.icon,
//               color: Theme.of(context).colorScheme.primary, size: 28),
//           const SizedBox(width: 20),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(item.title, style: Theme.of(context).textTheme.titleLarge),
//                 const SizedBox(height: 4),
//                 Text(
//                   item.organization,
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyLarge
//                       ?.copyWith(color: Colors.white.withValues(alpha: 235)),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   item.period,
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyMedium
//                       ?.copyWith(color: Theme.of(context).colorScheme.primary),
//                 ),
//               ],
//             ),
//           ),
//           if (item.certificateUrl != null)
//             Tooltip(
//               message: 'View Certificate',
//               child: IconButton(
//                 icon: Icon(Icons.open_in_new,
//                     color: Theme.of(context)
//                         .colorScheme
//                         .primary
//                         .withValues(alpha: 180)),
//                 onPressed: () => _launchURL(item.certificateUrl!),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
// class ContactSection extends StatefulWidget {
//   const ContactSection({super.key});
//
//   @override
//   _ContactSectionState createState() => _ContactSectionState();
// }
//
// class _ContactSectionState extends State<ContactSection> {
//   bool _isHovered = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOut,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: _isHovered
//               ? [
//             BoxShadow(
//               color: Theme.of(context)
//                   .colorScheme
//                   .primary
//                   .withValues(alpha: 100),
//               blurRadius: 20,
//               spreadRadius: 2,
//             ),
//             BoxShadow(
//               color: Theme.of(context)
//                   .colorScheme
//                   .secondary
//                   .withValues(alpha: 50),
//               blurRadius: 30,
//               spreadRadius: -5,
//             ),
//           ]
//               : [],
//         ),
//         child: GlassmorphicContainer(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Get In Touch.',
//                     style: Theme.of(context).textTheme.displayLarge),
//                 const SizedBox(height: 40),
//                 Text(
//                   "I'm currently available for freelance work and open to discussing new projects. Feel free to reach out!",
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyLarge
//                       ?.copyWith(color: Colors.white),
//                 ),
//                 const SizedBox(height: 40),
//                 InkWell(
//                   onTap: () => _launchURL('mailto:mostafahashem319@gmail.com'),
//                   borderRadius: BorderRadius.circular(8),
//                   child: Padding(
//                     padding: const EdgeInsets.all(4.0),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.email_outlined,
//                             color: Theme.of(context).colorScheme.primary,
//                             size: 24),
//                         const SizedBox(width: 16),
//                         Text("mostafahashem319@gmail.com",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyLarge
//                                 ?.copyWith(color: Colors.white)),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   children: [
//                     Icon(Icons.phone_outlined,
//                         color: Theme.of(context).colorScheme.primary, size: 24),
//                     const SizedBox(width: 16),
//                     Text("+20-106-311-8640",
//                         style: Theme.of(context)
//                             .textTheme
//                             .bodyLarge
//                             ?.copyWith(color: Colors.white)),
//                   ],
//                 ),
//                 const SizedBox(height: 40),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildSocialIcon(Icons.code_sharp,
//                         "https://github.com/Mostafa-Hashem-22", "GitHub"),
//                     const SizedBox(width: 24),
//                     _buildSocialIcon(Icons.people_alt_outlined,
//                         "https://www.linkedin.com/", "LinkedIn"),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSocialIcon(IconData icon, String url, String tooltip) {
//     return Tooltip(
//       message: tooltip,
//       child: IconButton(
//         icon: Icon(icon, size: 32),
//         color: Colors.white,
//         splashColor: Colors.transparent,
//         highlightColor: Colors.transparent,
//         onPressed: () => _launchURL(url),
//       ),
//     );
//   }
// }
//
// class ProblemSolvingSection extends StatefulWidget {
//   const ProblemSolvingSection({super.key});
//
//   @override
//   _ProblemSolvingSectionState createState() => _ProblemSolvingSectionState();
// }
//
// class _ProblemSolvingSectionState extends State<ProblemSolvingSection> {
//   bool _isHovered = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOut,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: _isHovered
//               ? [
//             BoxShadow(
//               color: Theme.of(context)
//                   .colorScheme
//                   .primary
//                   .withValues(alpha: 100),
//               blurRadius: 20,
//               spreadRadius: 2,
//             ),
//             BoxShadow(
//               color: Theme.of(context)
//                   .colorScheme
//                   .secondary
//                   .withValues(alpha: 50),
//               blurRadius: 30,
//               spreadRadius: -5,
//             ),
//           ]
//               : [],
//         ),
//         child: GlassmorphicContainer(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Problem Solving.',
//                     style: Theme.of(context).textTheme.displayLarge),
//                 const SizedBox(height: 40),
//                 Text(
//                   "Actively practicing problem-solving skills on VJudge to improve algorithmic thinking and coding efficiency.",
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//                 const SizedBox(height: 32),
//                 InkWell(
//                   onTap: () =>
//                       _launchURL("https://vjudge.net/user/Mostafa_Hashem"),
//                   borderRadius: BorderRadius.circular(8),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           'VJudge Profile: Mostafa_Hashem',
//                           style: Theme.of(context)
//                               .textTheme
//                               .titleLarge
//                               ?.copyWith(
//                               color: Theme.of(context).colorScheme.primary,
//                               fontSize: 18),
//                         ),
//                         const SizedBox(width: 8),
//                         Icon(Icons.open_in_new,
//                             color: Theme.of(context).colorScheme.primary)
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class GlassmorphicContainer extends StatelessWidget {
//   final Widget child;
//
//   const GlassmorphicContainer({super.key, required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Theme.of(context).colorScheme.surface.withValues(alpha: 150),
//                 Theme.of(context).colorScheme.surface.withValues(alpha: 80),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: Colors.white.withValues(alpha: 20),
//               width: 1.0,
//             ),
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }
// }
