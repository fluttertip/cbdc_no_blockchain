import 'package:cbdcprovider/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/theme_provider.dart';
import 'themes/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);



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

                  // Desktop/Web Layout - Clean and simple
                  return Scaffold(
                    body: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
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
                      child: Row(
                        children: [
                          // LEFT: zoom out message
                          Expanded(
                            child: Center(
                              child: Text(
                                "zoom out browser to 67% for better view",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // CENTER: phone mockup
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: _PhoneMockup(child: child!),
                            ),
                          ),

                          // RIGHT: Made by text
                          Expanded(
                            child: Center(
                              child: Text(
                                "Made by Niranjan Dahal",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
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

