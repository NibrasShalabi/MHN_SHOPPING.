import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/onboarding_cubit.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: BlocBuilder<OnboardingCubit, dynamic>(
        builder: (context, state) {
          return const Center(child: Text('Onboarding Page'));
        },
      ),
    );
  }
}
