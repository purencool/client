/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

// import 'package:flutter/material.dart';
// //import 'package:webview_cef/webview_cef.dart' as webview;
// //import 'package:webview_cef/src/webview_inject_user_script.dart';

// // Custom
// import '../../../registry/app.dart';

// class Browser extends StatefulWidget {
//   const Browser({super.key});

//   @override
//   State<Browser> createState() => _BrowserState();
// }

// class _BrowserState extends State<Browser> {
//  // webview.WebViewController? _controller;
//   final _urlController = TextEditingController();
//   String _title = "Browser";
//   bool _hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     print("[Browser] initState: Initializing webview.");
//     _initWebview();
//   }

//   void _initWebview() {
//     try {
//       print("[Browser] _initWebview: Creating webview controller.");
//    //   final userScripts = InjectUserScripts();
//      // final controller = webview.WebviewManager().createWebView(
//     //    loading: const Center(child: CircularProgressIndicator()),
//         // The correct parameter is `userScripts`, which expects a List.
//    //     injectUserScripts: userScripts,
//     //  );
//   //    setState(() {
//  //       _controller = controller;
//   //    });
//       print("[Browser] _initWebview: Webview controller created. Initializing...");
//    //   _initializeWebView(controller);
//     } catch (e, s) {
//       print(
//           "[Browser] _initWebview: CRITICAL - Failed to create webview controller.");
//       print("           Error: $e");
//       print("           Stack: $s");
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//         });
//       }
//     }
//   }

//   void _initializeWebView(webview.WebViewController controller) async {
//     print("[Browser] _initializeWebView: Setting up webview listeners.");
//     controller.setWebviewListener(
//       webview.WebviewEventsListener(
//         onTitleChanged: (title) {
//           print("[Browser] onTitleChanged: New title is '$title'");
//           if (mounted) {
//             setState(() {
//               _title = title;
//             });
//           }
//         },
//         onUrlChanged: (url) {
//           print("[Browser] onUrlChanged: New URL is '$url'");
//           if (mounted) {
//             _urlController.text = url;
//           }
//         },
//         // Corrected signature: The first parameter is the controller, the second is the URL.
//         onLoadStart: (controller, url) {
//           print("[Browser] onLoadStart: Loading started for '$url'");
//         },
//         // Corrected signature: The first parameter is the controller, the second is the URL.
//         onLoadEnd: (controller, url) {
//           print("[Browser] onLoadEnd: Loading finished for '$url'");
//         },
//       ),
//     );

//     const initialUrl = "https://flutter.dev";
//     _urlController.text = initialUrl;
//     print("[Browser] _initializeWebView: Initializing with URL: $initialUrl");
//     try {
//       await controller.initialize(initialUrl);
//       print("[Browser] _initializeWebView: Initialization successful.");
//     } catch (e, s) {
//       print(
//           "[Browser] _initializeWebView: CRITICAL - An error occurred during webview initialization.");
//       print("           Error: $e");
//       print("           Stack: $s");
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     print("[Browser] dispose: Disposing of browser resources.");
//     _urlController.dispose();
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("[Browser] build: Building browser widget.");
//     // Permission check
//     if (!context.isAllowed('browser')) {
//       print("[Browser] build: Access denied.");
//       return const AccessDenied();
//     }

//     // Handle case where controller failed to initialize
//     if (_hasError || _controller == null) {
//       print(
//           "[Browser] build: Controller is null or an error occurred. Showing error message.");
//       return Scaffold(
//         appBar: AppBar(title: const Text("Browser Error")),
//         drawer: const AppMenu(),
//         body: const Center(
//           child: Text(
//             "Failed to initialize the browser.\nCheck logs for details.",
//             textAlign: TextAlign.center,
//           ),
//         ),
//       );
//     }

//     final controller = _controller!;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_title, overflow: TextOverflow.ellipsis),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(kToolbarHeight),
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 12.0),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.arrow_back),
//                   onPressed: controller.goBack,
//                   tooltip: 'Go Back',
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.arrow_forward),
//                   onPressed: controller.goForward,
//                   tooltip: 'Go Forward',
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.refresh),
//                   onPressed: controller.reload,
//                   tooltip: 'Reload',
//                 ),
//                 Expanded(
//                   child: SizedBox(
//                     height: 40,
//                     child: TextField(
//                       controller: _urlController,
//                       onSubmitted: (url) {
//                         controller.loadUrl(url);
//                       },
//                       decoration: InputDecoration(
//                         hintText: "Enter URL",
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16.0,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(24.0),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Theme.of(
//                           context,
//                         ).colorScheme.onSurface.withOpacity(0.05),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.developer_mode),
//                   onPressed: controller.openDevTools,
//                   tooltip: 'Open DevTools',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       drawer: const AppMenu(),
//       body: ValueListenableBuilder<bool>(
//         valueListenable: controller,
//         builder: (context, isInitialized, child) {
//           print(
//               "[Browser] ValueListenableBuilder: isInitialized is $isInitialized.");
//           if (isInitialized) {
//             print("[Browser] ValueListenableBuilder: Showing webview widget.");
//             return controller.webviewWidget;
//           }
//           print("[Browser] ValueListenableBuilder: Showing loading widget.");
//           return controller.loadingWidget;
//         },
//       ),
//     );
//   }
// }
