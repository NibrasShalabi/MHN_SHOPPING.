import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/loyalty_cubit.dart';

class LoyaltyPage extends StatelessWidget {
  const LoyaltyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loyalty')),
      body: BlocBuilder<LoyaltyCubit, dynamic>(
        builder: (context, state) {
          return const Center(child: Text('Loyalty Page'));
        },
      ),
    );
  }
}
