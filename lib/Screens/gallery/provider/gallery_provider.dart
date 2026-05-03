import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

final galleryProvider = StreamProvider<List<File>>((ref) async* {
  final dir = await getApplicationDocumentsDirectory();

  List<File> getFiles() {
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('snapcraft_') && f.path.endsWith('.jpg'))
        .toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }

  // Yield initial list of files
  yield getFiles();

  // Listen to directory changes for real-time updates
  await for (final _ in dir.watch()) {
    yield getFiles();
  }
});

class CollageLayout {
  final int id;
  final String name;
  final IconData icon;
  final int rows;
  final int cols;

  const CollageLayout({
    required this.id,
    required this.name,
    required this.icon,
    required this.rows,
    required this.cols,
  });
}

// ── Collage State ─────────────────────────────────────────────────
class CollageState {
  final List<File?> slots;
  final CollageLayout? layout;
  final Color background;
  final double gap;

  const CollageState({
    this.slots = const [],
    this.layout,
    this.background = Colors.black,
    this.gap = 2.0,
  });

  CollageState copyWith({
    List<File?>? slots,
    CollageLayout? layout,
    Color? background,
    double? gap,
  }) {
    return CollageState(
      slots: slots ?? this.slots,
      layout: layout ?? this.layout,
      background: background ?? this.background,
      gap: gap ?? this.gap,
    );
  }
}

// ── Collage Notifier ──────────────────────────────────────────────
class CollageNotifier extends StateNotifier<CollageState> {
  CollageNotifier()
      : super(const CollageState(slots: [null, null, null, null]));

  void setLayout(CollageLayout layout) {
    final totalSlots = layout.rows * layout.cols;
    final currentSlots = [...state.slots];

    // Resize slots list to match new layout
    while (currentSlots.length < totalSlots) currentSlots.add(null);

    state = state.copyWith(
      layout: layout,
      slots: currentSlots.sublist(0, totalSlots),
    );
  }

  void setSlotImage(int index, File file) {
    final slots = [...state.slots];
    while (slots.length <= index) slots.add(null);
    slots[index] = file;
    state = state.copyWith(slots: slots);
  }

  void removeSlotImage(int index) {
    final slots = [...state.slots];
    if (index < slots.length) slots[index] = null;
    state = state.copyWith(slots: slots);
  }

  void setBackground(Color color) {
    state = state.copyWith(background: color);
  }

  void clearAll() {
    state = state.copyWith(
      slots: List.filled(state.slots.length, null),
    );
  }

  Future<void> autoFill(ImagePicker picker) async {
    for (int i = 0; i < state.slots.length; i++) {
      if (state.slots[i] == null) {
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          setSlotImage(i, File(picked.path));
        }
      }
    }
  }

  Future<void> exportCollage(BuildContext context) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Collage saved to gallery!'),
          backgroundColor: const Color(0xFF3DDC84),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

final collageProvider = StateNotifierProvider<CollageNotifier, CollageState>(
  (ref) => CollageNotifier(),
);
