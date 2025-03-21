import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/timer_model.dart';

// Events
abstract class TimerEvent {}

class StartTimer extends TimerEvent {
  final TimerModel timer;
  StartTimer(this.timer);
}

class PauseTimer extends TimerEvent {}

class ResumeTimer extends TimerEvent {}

class ResetTimer extends TimerEvent {}

class TimerTick extends TimerEvent {
  final Duration duration;
  TimerTick(this.duration);
}

// States
abstract class TimerState {}

class TimerInitial extends TimerState {}

class TimerRunInProgress extends TimerState {
  final Duration duration;
  TimerRunInProgress(this.duration);
}

class TimerRunPause extends TimerState {
  final Duration duration;
  TimerRunPause(this.duration);
}

class TimerRunComplete extends TimerState {}

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  static const int _tickDuration = 1;
  Timer? _timer;
  Duration? _currentDuration;

  TimerBloc() : super(TimerInitial()) {
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<ResumeTimer>(_onResumeTimer);
    on<ResetTimer>(_onResetTimer);
    on<TimerTick>(_onTimerTick);
  }

  void _onStartTimer(StartTimer event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.timer.duration));
    _currentDuration = event.timer.duration;
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: _tickDuration),
      (timer) {
        if (_currentDuration!.inSeconds > 0) {
          add(TimerTick(_currentDuration! - const Duration(seconds: _tickDuration)));
        } else {
          timer.cancel();
          add(ResetTimer());
        }
      },
    );
  }

  void _onPauseTimer(PauseTimer event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _timer?.cancel();
      emit(TimerRunPause(_currentDuration!));
    }
  }

  void _onResumeTimer(ResumeTimer event, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      emit(TimerRunInProgress(_currentDuration!));
      _timer = Timer.periodic(
        const Duration(seconds: _tickDuration),
        (timer) {
          if (_currentDuration!.inSeconds > 0) {
            add(TimerTick(_currentDuration! - const Duration(seconds: _tickDuration)));
          } else {
            timer.cancel();
            add(ResetTimer());
          }
        },
      );
    }
  }

  void _onResetTimer(ResetTimer event, Emitter<TimerState> emit) {
    _timer?.cancel();
    emit(TimerRunComplete());
  }

  void _onTimerTick(TimerTick event, Emitter<TimerState> emit) {
    _currentDuration = event.duration;
    emit(TimerRunInProgress(event.duration));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}