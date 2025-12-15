import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/helpers/loading/loading_screen_controller.dart';

class LoadingScreen {
  static final LoadingScreen _instance =
      LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();
  factory LoadingScreen() => _instance;

  LoadingScreenController? _controller;

  void show({
    required BuildContext context,
    required String message,
  }) {
    if (_controller == null) {
      _controller = showOverlay(
        context: context,
        message: message,
      );
    } else {
      _controller!.update(message);
    }
  }

  void hide() {
    _controller?.close();
    _controller = null;
  }

  LoadingScreenController showOverlay({
    required BuildContext context,
    required String message,
  }) {
    final _text = StreamController<String>();
    _text.add(message);

    OverlayState? overlayState = Overlay.of(context);
    final renderBox =
        context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    StreamBuilder<String>(
                      stream: _text.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data!,
                            textAlign: TextAlign.center,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    overlayState.insert(overlayEntry);

    return LoadingScreenController(
      close: () {
        _text.close();
        overlayEntry.remove();
        return true;
      },
      update: (String message) {
        _text.add(message);
        return true;
      },
    );
  }
}
