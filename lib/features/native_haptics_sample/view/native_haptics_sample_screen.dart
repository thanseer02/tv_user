import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/native_haptics_viewmodel.dart';

class NativeHapticsSampleScreen extends StatelessWidget {
  static const routeName = '/NativeHapticsSampleScreen';

  const NativeHapticsSampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NativeHapticsViewModel(),
      child: const _NativeHapticsSampleScreenContent(),
    );
  }
}

class _NativeHapticsSampleScreenContent extends StatelessWidget {
  const _NativeHapticsSampleScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Haptics Sample'),
      ),
      body: Consumer<NativeHapticsViewModel>(
        builder: (context, viewModel, child) {
          final colorScheme = Theme.of(context).colorScheme;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.platformVersion,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.lastAction,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _Section(
                title: 'Impact',
                children: [
                  _HapticButton(
                    label: 'Heavy Impact',
                    icon: Icons.vibration,
                    onPressed: () =>
                        viewModel.play('Heavy Impact', viewModel.haptics.heavyImpact),
                  ),
                  _HapticButton(
                    label: 'Medium Impact',
                    icon: Icons.touch_app,
                    onPressed: () =>
                        viewModel.play('Medium Impact', viewModel.haptics.mediumImpact),
                  ),
                  _HapticButton(
                    label: 'Light Impact',
                    icon: Icons.radio_button_checked,
                    onPressed: () =>
                        viewModel.play('Light Impact', viewModel.haptics.lightImpact),
                  ),
                  _HapticButton(
                    label: 'Selection Click',
                    icon: Icons.ads_click,
                    onPressed: () => viewModel.play(
                        'Selection Click', viewModel.haptics.selectionClick),
                  ),
                ],
              ),
              _Section(
                title: 'Notifications',
                children: [
                  _HapticButton(
                    label: 'Success',
                    icon: Icons.check_circle_outline,
                    onPressed: () =>
                        viewModel.play('Success', viewModel.haptics.success),
                  ),
                  _HapticButton(
                    label: 'Warning',
                    icon: Icons.warning_amber_rounded,
                    onPressed: () =>
                        viewModel.play('Warning', viewModel.haptics.warning),
                  ),
                  _HapticButton(
                    label: 'Error',
                    icon: Icons.error_outline,
                    onPressed: () => viewModel.play('Error', viewModel.haptics.error),
                  ),
                ],
              ),
              _Section(
                title: 'Advanced Patterns',
                children: [
                  _HapticButton(
                    label: 'Bounce',
                    icon: Icons.sports_basketball_outlined,
                    onPressed: () =>
                        viewModel.play('Bounce', viewModel.haptics.bounce),
                  ),
                  _HapticButton(
                    label: 'Bounce Once',
                    icon: Icons.expand_circle_down_outlined,
                    onPressed: () =>
                        viewModel.play('Bounce Once', viewModel.haptics.bounceOnce),
                  ),
                  _HapticButton(
                    label: 'Ramp Up',
                    icon: Icons.trending_up,
                    onPressed: () =>
                        viewModel.play('Ramp Up', viewModel.haptics.rampUpPattern),
                  ),
                  _HapticButton(
                    label: 'Repeating Pattern',
                    icon: Icons.repeat,
                    onPressed: () => viewModel.play(
                        'Repeating Pattern', viewModel.haptics.repeatingPattern),
                  ),
                  _HapticButton(
                    label: 'Resist',
                    icon: Icons.compress,
                    onPressed: () =>
                        viewModel.play('Resist', viewModel.haptics.resist),
                  ),
                  _HapticButton(
                    label: 'Expand',
                    icon: Icons.open_in_full,
                    onPressed: () =>
                        viewModel.play('Expand', viewModel.haptics.expand),
                  ),
                  _HapticButton(
                    label: 'Wobble',
                    icon: Icons.screen_rotation_alt,
                    onPressed: () =>
                        viewModel.play('Wobble', viewModel.haptics.wobble),
                  ),
                  _HapticButton(
                    label: 'Wobble Once',
                    icon: Icons.rotate_90_degrees_ccw,
                    onPressed: () =>
                        viewModel.play('Wobble Once', viewModel.haptics.wobbleOnce),
                  ),
                  _HapticButton(
                    label: 'Spring',
                    icon: Icons.keyboard_double_arrow_up,
                    onPressed: () =>
                        viewModel.play('Spring', viewModel.haptics.spring),
                  ),
                  _HapticButton(
                    label: 'Rocket Launch',
                    icon: Icons.rocket_launch_outlined,
                    onPressed: () =>
                        viewModel.play('Rocket Launch', viewModel.haptics.rocketLaunch),
                  ),
                ],
              ),
              _Section(
                title: 'Android Custom Vibration',
                children: [
                  _HapticButton(
                    label: 'Vibrate Pattern',
                    icon: Icons.graphic_eq,
                    onPressed: () => viewModel.play(
                      'Vibrate Pattern',
                      () => viewModel.haptics.vibratePattern(
                        pattern: [50, 50, 50, 50, 50, 100, 350, 250],
                        amplitudes: [77, 79, 84, 99, 143, 255, 0, 255],
                        repeat: false,
                      ),
                    ),
                  ),
                  _HapticButton(
                    label: 'Amplitude 300ms',
                    icon: Icons.tune,
                    onPressed: () => viewModel.play(
                      'Amplitude 300ms',
                      () => viewModel.haptics.vibrateWithAmplitude(
                        duration: 300,
                        amplitude: 180,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _HapticButton extends StatelessWidget {
  const _HapticButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }
}
