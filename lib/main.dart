import 'package:cbdcprovider/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/theme_provider.dart';
import 'themes/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  //APK DOWNLOAD LINK
  static const String apkDownloadUrl = 'YOUR_APK_DOWNLOAD_LINK_HERE';

  Future<void> _downloadAPK() async {
    final Uri url = Uri.parse(apkDownloadUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              return MaterialApp(
                title: 'CBDC App',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                debugShowCheckedModeBanner: false,
                builder: (context, child) {
                  if (isMobile) return child!;

                  // Desktop/Web Layout - Fixed, no scrolling
                  return Scaffold(
                    body: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0F0F1E),
                            Color(0xFF1A1A2E),
                            Color(0xFF16213E),
                            Color(0xFF0F0F1E),
                          ],
                          stops: [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                      child: Stack(
                        children: [
                          _AnimatedBackgroundOrbs(),

                          Row(
                            children: [
                              //Download APK Button
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: _DownloadButton(
                                    onPressed: () => _downloadAPK(),
                                  ),
                                ),
                              ),

                              // Center - Phone mockup
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: _PhoneMockup(child: child!),
                                ),
                              ),

                              //Info message
                              Expanded(
                                flex: 1,
                                child: Center(child: _InfoMessage()),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                home: LoginScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

// Download button widget
class _DownloadButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _DownloadButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF667EEA),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: _isHovered ? 12 : 8,
            shadowColor: Color(0xFF667EEA).withOpacity(0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_rounded, size: 48),
              SizedBox(height: 12),
              Text(
                'Download APK',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Info message widget
class _InfoMessage extends StatelessWidget {
  const _InfoMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF667EEA), size: 48),
          SizedBox(height: 16),
          Text(
            'Zoom out your browser',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'All features may not work properly on the web version.',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Phone mockup widget with FIXED large dimensions
class _PhoneMockup extends StatelessWidget {
  final Widget child;

  const _PhoneMockup({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const frameWidth = 440.0;
    const frameHeight = 920.0;

    return SizedBox(
      width: frameWidth,
      height: frameHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF667EEA).withOpacity(0.3),
              blurRadius: 40.0,
              spreadRadius: 0,
              offset: Offset(-10, 10),
            ),
            BoxShadow(
              color: Color(0xFF764BA2).withOpacity(0.3),
              blurRadius: 40.0,
              spreadRadius: 0,
              offset: Offset(10, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Phone bezel/frame
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2C2C3E),
                    Color(0xFF1C1C2E),
                    Color(0xFF0F0F1E),
                  ],
                ),
                border: Border.all(width: 12.0, color: Color(0xFF1A1A2E)),
              ),
              child: Container(
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(42.0),
                  border: Border.all(
                    width: 2.0,
                    color: Color(0xFF3A3A4E).withOpacity(0.5),
                  ),
                ),
              ),
            ),

            // Screen content area - FIXED LARGE SIZE
            Center(
              child: Container(
                margin: EdgeInsets.all(20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38.0),
                  child: SizedBox(width: 400.0, height: 880.0, child: child),
                ),
              ),
            ),

            // Power button
            Positioned(
              right: 0,
              top: 200.0,
              child: Container(
                width: 4.0,
                height: 80.0,
                decoration: BoxDecoration(
                  color: Color(0xFF2C2C3E),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(2.0),
                    bottomRight: Radius.circular(2.0),
                  ),
                ),
              ),
            ),

            // Volume buttons
            Positioned(
              left: 0,
              top: 180.0,
              child: Column(
                children: [
                  Container(
                    width: 4.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      color: Color(0xFF2C2C3E),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2.0),
                        bottomLeft: Radius.circular(2.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Container(
                    width: 4.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      color: Color(0xFF2C2C3E),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2.0),
                        bottomLeft: Radius.circular(2.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animated background orbs
class _AnimatedBackgroundOrbs extends StatefulWidget {
  const _AnimatedBackgroundOrbs({Key? key}) : super(key: key);

  @override
  State<_AnimatedBackgroundOrbs> createState() =>
      _AnimatedBackgroundOrbsState();
}

class _AnimatedBackgroundOrbsState extends State<_AnimatedBackgroundOrbs>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _controller2 = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _controller3 = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Orb 1
        AnimatedBuilder(
          animation: _controller1,
          builder: (context, child) {
            return Positioned(
              left: 100 + (200 * _controller1.value),
              top: 100 + (300 * _controller1.value),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF667EEA).withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Orb 2
        AnimatedBuilder(
          animation: _controller2,
          builder: (context, child) {
            return Positioned(
              right: 50 + (150 * _controller2.value),
              top: 200 + (200 * (1 - _controller2.value)),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF764BA2).withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Orb 3
        AnimatedBuilder(
          animation: _controller3,
          builder: (context, child) {
            return Positioned(
              left: 300 + (100 * (1 - _controller3.value)),
              bottom: 50 + (250 * _controller3.value),
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF667EEA).withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
