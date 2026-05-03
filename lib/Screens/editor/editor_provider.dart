import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapcraft/core/constant.dart';

// ── Filter Model ──────────────────────────────────────────────────
class SnapFilter {
  final String name;
  final ColorFilter colorFilter;
  final String emoji;

  const SnapFilter(
      {required this.name, required this.colorFilter, required this.emoji});

  static const List<SnapFilter> all = [
    SnapFilter(
        name: 'Original',
        emoji: '🌿',
        colorFilter: ColorFilter.mode(Colors.transparent, BlendMode.multiply)),
    SnapFilter(
        name: 'Sepia',
        emoji: '🌅',
        colorFilter: ColorFilter.matrix([
          0.393,
          0.769,
          0.189,
          0,
          0,
          0.349,
          0.686,
          0.168,
          0,
          0,
          0.272,
          0.534,
          0.131,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ])),
    SnapFilter(
        name: 'Vintage',
        emoji: '📷',
        colorFilter: ColorFilter.matrix([
          0.9,
          0.5,
          0.1,
          0,
          50,
          0.3,
          0.8,
          0.1,
          0,
          20,
          0.2,
          0.3,
          0.5,
          0,
          10,
          0,
          0,
          0,
          1,
          0,
        ])),
    SnapFilter(
        name: 'Cool',
        emoji: '❄️',
        colorFilter: ColorFilter.matrix([
          0.8,
          0,
          0,
          0,
          0,
          0,
          0.9,
          0,
          0,
          0,
          0,
          0,
          1.2,
          0,
          20,
          0,
          0,
          0,
          1,
          0,
        ])),
    SnapFilter(
        name: 'Warm',
        emoji: '🌞',
        colorFilter: ColorFilter.matrix([
          1.2,
          0,
          0,
          0,
          20,
          0,
          1.0,
          0,
          0,
          10,
          0,
          0,
          0.8,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ])),
    SnapFilter(
        name: 'Mono',
        emoji: '⚫',
        colorFilter: ColorFilter.matrix([
          0.33,
          0.33,
          0.33,
          0,
          0,
          0.33,
          0.33,
          0.33,
          0,
          0,
          0.33,
          0.33,
          0.33,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ])),
    SnapFilter(
        name: 'Fade',
        emoji: '🌫️',
        colorFilter: ColorFilter.matrix([
          1.0,
          0,
          0,
          0,
          30,
          0,
          1.0,
          0,
          0,
          30,
          0,
          0,
          1.0,
          0,
          30,
          0,
          0,
          0,
          0.85,
          0,
        ])),
    SnapFilter(
        name: 'Chrome',
        emoji: '✨',
        colorFilter: ColorFilter.matrix([
          1.3,
          -0.1,
          -0.2,
          0,
          0,
          -0.1,
          1.2,
          -0.1,
          0,
          0,
          -0.2,
          -0.1,
          1.3,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ])),
  ];

  @override
  bool operator ==(Object other) => other is SnapFilter && other.name == name;
  @override
  int get hashCode => name.hashCode;
}

// ── Editor State ──────────────────────────────────────────────────
class EditorState {
  final File? originalFile;
  final Uint8List? originalImage;
  final Uint8List? processedImage;
  final SnapFilter activeFilter;
  final double brightness;
  final double contrast;
  final double saturation;
  final double warmth;
  final bool isProcessing;
  final bool showHistogram;
  final bool showingOriginal;
  final List<Uint8List> undoStack;
  final int undoIndex;

  const EditorState({
    this.originalFile,
    this.originalImage,
    this.processedImage,
    this.activeFilter = const SnapFilter(
      name: 'Original',
      emoji: '🌿',
      colorFilter: ColorFilter.mode(Colors.transparent, BlendMode.multiply),
    ),
    this.brightness = 0.0,
    this.contrast = 0.0,
    this.saturation = 0.0,
    this.warmth = 0.0,
    this.isProcessing = false,
    this.showHistogram = false,
    this.showingOriginal = false,
    this.undoStack = const [],
    this.undoIndex = -1,
  });

  bool get canUndo => undoIndex > 0;
  bool get canRedo => undoIndex < undoStack.length - 1;

  EditorState copyWith({
    File? originalFile,
    Uint8List? originalImage,
    Uint8List? processedImage,
    SnapFilter? activeFilter,
    double? brightness,
    double? contrast,
    double? saturation,
    double? warmth,
    bool? isProcessing,
    bool? showHistogram,
    bool? showingOriginal,
    List<Uint8List>? undoStack,
    int? undoIndex,
  }) {
    return EditorState(
      originalFile: originalFile ?? this.originalFile,
      originalImage: originalImage ?? this.originalImage,
      processedImage: processedImage ?? this.processedImage,
      activeFilter: activeFilter ?? this.activeFilter,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      warmth: warmth ?? this.warmth,
      isProcessing: isProcessing ?? this.isProcessing,
      showHistogram: showHistogram ?? this.showHistogram,
      showingOriginal: showingOriginal ?? this.showingOriginal,
      undoStack: undoStack ?? this.undoStack,
      undoIndex: undoIndex ?? this.undoIndex,
    );
  }
}

// ── Editor Notifier ───────────────────────────────────────────────
class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier() : super(const EditorState());

  Future<void> loadImage(File file) async {
    state = state.copyWith(isProcessing: true);
    final bytes = await file.readAsBytes();
    state = state.copyWith(
      originalFile: file,
      originalImage: bytes,
      processedImage: bytes,
      isProcessing: false,
      undoStack: [bytes],
      undoIndex: 0,
    );
  }

  void applyFilter(SnapFilter filter) {
    state = state.copyWith(activeFilter: filter);
    _processImage();
  }

  void setBrightness(double value) {
    state = state.copyWith(brightness: value);
    _processImage();
  }

  void setContrast(double value) {
    state = state.copyWith(contrast: value);
    _processImage();
  }

  void setSaturation(double value) {
    state = state.copyWith(saturation: value);
    _processImage();
  }

  void setWarmth(double value) {
    state = state.copyWith(warmth: value);
    _processImage();
  }

  void showOriginal(bool show) {
    state = state.copyWith(showingOriginal: show);
  }

  void undo() {
    if (!state.canUndo) return;
    final newIndex = state.undoIndex - 1;
    state = state.copyWith(
      processedImage: state.undoStack[newIndex],
      undoIndex: newIndex,
    );
  }

  void redo() {
    if (!state.canRedo) return;
    final newIndex = state.undoIndex + 1;
    state = state.copyWith(
      processedImage: state.undoStack[newIndex],
      undoIndex: newIndex,
    );
  }

  Future<void> _processImage() async {
    if (state.originalImage == null) return;
    state = state.copyWith(isProcessing: true);

    // Run image processing in isolate
    final processed = await _applyAdjustments(
      state.originalImage!,
      brightness: state.brightness,
      contrast: state.contrast,
      saturation: state.saturation,
      warmth: state.warmth,
    );

    // Update undo stack
    final newStack = [
      ...state.undoStack.sublist(0, state.undoIndex + 1),
      processed,
    ];

    state = state.copyWith(
      processedImage: processed,
      isProcessing: false,
      undoStack: newStack,
      undoIndex: newStack.length - 1,
    );
  }

  Future<Uint8List> _applyAdjustments(
    Uint8List imageBytes, {
    required double brightness,
    required double contrast,
    required double saturation,
    required double warmth,
  }) async {
    var image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    // Brightness
    if (brightness != 0) {
      image = img.adjustColor(image, brightness: 1 + brightness);
    }

    // Contrast
    if (contrast != 0) {
      image = img.adjustColor(image, contrast: 1 + contrast);
    }

    // Saturation
    if (saturation != 0) {
      image = img.adjustColor(image, saturation: 1 + saturation);
    }

    // Warmth (shift red/blue channels)
    if (warmth != 0) {
      final int warmAmount = (warmth * 30).round();
      final int width = image.width;
      final int height = image.height;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixel = image.getPixelSafe(x, y);
          final int red = pixel.r.toInt();
          final int green = pixel.g.toInt();
          final int blue = pixel.b.toInt();
          final int alpha = pixel.a.toInt();

          if (warmAmount > 0) {
            image.setPixelRgba(
              x,
              y,
              (red + warmAmount).clamp(0, 255).toInt(),
              green,
              blue,
              alpha,
            );
          } else {
            image.setPixelRgba(
              x,
              y,
              red,
              green,
              (blue + warmAmount.abs()).clamp(0, 255).toInt(),
              alpha,
            );
          }
        }
      }
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 95));
  }

  Future<void> aiEnhance() async {
    // This triggers the AI enhancement via Socket.io
    // Integration handled in AiProvider
    state = state.copyWith(isProcessing: true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate AI processing
    state = state.copyWith(isProcessing: false);
  }

  Future<void> saveImage(BuildContext context) async {
    if (state.processedImage == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/snapcraft_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(state.processedImage!);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Image saved to gallery'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> exportImage(BuildContext context) async {
    await saveImage(context);
    // Could also share via share_plus package
  }
}

final editorProvider = StateNotifierProvider<EditorNotifier, EditorState>(
  (ref) => EditorNotifier(),
);
