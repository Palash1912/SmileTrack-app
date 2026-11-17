import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrushingTimerState {
  final int targetDuration;
  final int elapsed;
  final bool isRunning;
  final bool isCompleted;

  const BrushingTimerState({
    this.targetDuration = 120,
    this.elapsed = 0,
    this.isRunning = false,
    this.isCompleted = false,
  });

  int get remaining => (targetDuration - elapsed).clamp(0, targetDuration);
  double get progress =>
      targetDuration > 0 ? (elapsed / targetDuration).clamp(0.0, 1.0) : 0.0;

  String get timeString {
    final rem = remaining;
    final minutes = rem ~/ 60;
    final seconds = rem % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  BrushingTimerState copyWith({
    int? targetDuration,
    int? elapsed,
    bool? isRunning,
    bool? isCompleted,
  }) {
    return BrushingTimerState(
      targetDuration: targetDuration ?? this.targetDuration,
      elapsed: elapsed ?? this.elapsed,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class BrushingTimerNotifier extends StateNotifier<BrushingTimerState> {
  BrushingTimerNotifier() : super(const BrushingTimerState());

  Timer? _timer;

  void startTimer() {
    if (state.isRunning || state.isCompleted) return;
    _timer?.cancel();
    state = state.copyWith(isRunning: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.elapsed + 1 >= state.targetDuration) {
        timer.cancel();
        state = state.copyWith(
          elapsed: state.targetDuration,
          isRunning: false,
          isCompleted: true,
        );
      } else {
        state = state.copyWith(elapsed: state.elapsed + 1);
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void resetTimer() {
    _timer?.cancel();
    state = state.copyWith(
      elapsed: 0,
      isRunning: false,
      isCompleted: false,
    );
  }

  void completeTimer() {
    _timer?.cancel();
    state = state.copyWith(
      elapsed: state.targetDuration,
      isRunning: false,
      isCompleted: true,
    );
  }

  void setTargetDuration(int seconds) {
    state = state.copyWith(targetDuration: seconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final brushingTimerProvider =
    StateNotifierProvider<BrushingTimerNotifier, BrushingTimerState>((ref) {
  return BrushingTimerNotifier();
});
