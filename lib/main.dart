/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:window_manager/window_manager.dart';
//import 'package:webview_cef/webview_cef.dart' as webview;

// Your Registries
import 'registry/app.dart'; 
import 'init.dart';
import 'registry/routes.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        GlobalResources().logStackTraceError(details.exception, details.stack);
      };

      keybindings.defaultConfig();
      await Init.init();
      runApp(
        ActiveConfiguration.provide(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<SwatBloc>(
                // Use your world-class registry here
                create: (context) => SwatRegistry.create(),
              ),
            ],
            child: const MyApp(),
          ),
        ),
      );

    },
    (error, stack) {
      GlobalResources().logStackTraceError(error, stack);
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAiChatPinnedOpen = false;
  bool _isAiDialogShown = false;
  bool _isAiLoading = false;
  // State for the global AI chat is hoisted to the top-level app state
  // to ensure it persists across layout changes (dialog vs. pinned).
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    //  windowManager.addListener(this);
    // Pre-populate with a welcome message.
    _addMessage("Hello! How can I assist you today?", isUser: false);
    // We're listening to onWindowClose, so we should explicitly prevent the
    // window from closing by default. We will then handle the shutdown
    // process ourselves in the onWindowClose() method.
    // windowManager.setPreventClose(true);
  }

  @override
  void dispose() {
    // windowManager.removeListener(this);
    keybindings.dispose();
    super.dispose();
  }

  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: isUser));
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _isAiLoading) return;
    _addMessage(text, isUser: true);

    // Check for AI commands
    final commandResponse = aiCommands.run(text.trim());
    if (commandResponse != null) {
      // If it's a command, we use the command's output as the prompt for the AI
      text = commandResponse;
    }

    setState(() {
      _isAiLoading = true;
    });

    try {
      final aiResponse = await aiRequests.getResponse(text);
      _addMessage(aiResponse, isUser: false);
    } catch (e) {
      _addMessage("Sorry, an error occurred: $e", isUser: false);
    } finally {
      if (mounted) {
        setState(() {
          _isAiLoading = false;
        });
      }
    }
  }

  // @override
  // Future<void> onWindowClose() async {
  // This is the recommended place to safely close down the webview_cef
  // subprocess, as noted in the comments within `apps/browser/app/browser.dart`.
  //try {
  ///  await webview.WebviewManager().quit();
  // } catch (e) {
  //   GlobalResources().logError('Failed to quit webview manager: $e', null);
  // }
  //await windowManager.destroy();
  // }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: themeNotifier,
      builder: (context, theme, _) {
        return MaterialApp(
          navigatorKey: aiKey,
          title: context.labels['title_window'] ?? "App",
          debugShowCheckedModeBanner: false,
          theme: theme.copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: NoTransitionsBuilder(),
                TargetPlatform.iOS: NoTransitionsBuilder(),
                TargetPlatform.macOS: NoTransitionsBuilder(),
                TargetPlatform.windows: NoTransitionsBuilder(),
                TargetPlatform.linux: NoTransitionsBuilder(),
                TargetPlatform.fuchsia: NoTransitionsBuilder(),
              },
            ),
          ),
          initialRoute: '/',
          routes: {...appRoutes},
          builder: (context, child) {
            final width = MediaQuery.of(context).size.width;
            final isLargeScreen = width > 800;

            final mainContent = Material(
              child: child ?? const SizedBox.shrink(),
            );

            final bool showSidebar = isLargeScreen && _isAiChatPinnedOpen;
            final bool showFab =
                !showSidebar && !_isAiDialogShown && context.isAllowed('ai');

            return Stack(
              children: [
                // Main Content with dynamic margin
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  left: 0,
                  right: showSidebar ? 400 : 0,
                  top: 0,
                  bottom: 0,
                  child: mainContent,
                ),

                // Sidebar (Pinned Chat)
                if (showSidebar)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 400,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: HeroControllerScope(
                        controller: MaterialApp.createMaterialHeroController(),
                        // A nested Navigator is crucial here. It provides the Overlay needed
                        // by the TextField within the chat. Without this, the TextField
                        // would crash.
                        child: Navigator(
                          onPopPage: (route, result) =>
                              false, // We manage closing via state
                          pages: [
                            MaterialPage(
                              child: Material(
                                elevation: 4,
                                child: AiChatDialog(
                                  isPinned: true,
                                  isLoading: _isAiLoading,
                                  messages: _messages,
                                  onSubmitted: _handleSubmitted,
                                  onClose: () {
                                    setState(() {
                                      _isAiChatPinnedOpen = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // FAB (Floating Chat Button)
                if (showFab)
                  Positioned(
                    right: 16.0,
                    bottom: 16.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        if (isLargeScreen) {
                          setState(() {
                            _isAiChatPinnedOpen = true;
                          });
                        } else {
                          // On smaller screens, just update state to show the dialog
                          setState(() {
                            _isAiDialogShown = true;
                          });
                        }
                      },
                      child: const Icon(Icons.smart_toy_outlined),
                    ),
                  ),

                // Floating Dialog on small screens
                if (!isLargeScreen && _isAiDialogShown)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                      child: Center(
                        child: SizedBox(
                          height: (MediaQuery.of(context).size.height * 0.7)
                              .clamp(0.0, 700.0),
                          width: (MediaQuery.of(context).size.width * 0.9)
                              .clamp(0.0, 500.0),
                          child: HeroControllerScope(
                            controller:
                                MaterialApp.createMaterialHeroController(),
                            child: Navigator(
                              onPopPage: (route, result) => false,
                              pages: [
                                TransparentPage(
                                  child: Theme(
                                    data: theme,
                                    child: Material(
                                      elevation: 8.0,
                                      clipBehavior: Clip.antiAlias,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          16.0,
                                        ),
                                        side: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: AiChatDialog(
                                        isPinned: false,
                                        isLoading: _isAiLoading,
                                        messages: _messages,
                                        onSubmitted: _handleSubmitted,
                                        onClose: () {
                                          setState(
                                            () => _isAiDialogShown = false,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

/// A page that creates a non-opaque route.
/// This is used to show a dialog-like window on top of other content
/// without completely obscuring it, allowing a semi-transparent background
/// to be visible.
class TransparentPage<T> extends Page<T> {
  const TransparentPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      opaque: false, // The key to making the background visible.
      pageBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) => child,
    );
  }
}

/// A page transitions builder that disables all animations.
class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
