import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/timer_bloc.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // 左侧数字倒计时显示
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BlocBuilder<TimerBloc, TimerState>(
                  builder: (context, state) {
                    String timeStr = '00:00:00';
                    if (state is TimerRunInProgress || state is TimerRunPause) {
                      final duration = state is TimerRunInProgress
                          ? state.duration
                          : (state as TimerRunPause).duration;
                      final hours = duration.inHours.toString().padLeft(2, '0');
                      final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
                      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
                      timeStr = '$hours:$minutes:$seconds';
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          timeStr,
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                state is TimerRunInProgress
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              onPressed: () {
                                if (state is TimerRunInProgress) {
                                  context.read<TimerBloc>().add(PauseTimer());
                                } else if (state is TimerRunPause) {
                                  context.read<TimerBloc>().add(ResumeTimer());
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.stop),
                              onPressed: () {
                                context.read<TimerBloc>().add(ResetTimer());
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 右侧图形化倒计时显示
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    '图形化倒计时区域',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}