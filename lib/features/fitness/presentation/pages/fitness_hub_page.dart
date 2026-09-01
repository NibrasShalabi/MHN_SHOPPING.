import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/entities/health_program.dart';
import '../cubits/fitness_hub_cubit.dart';
import '../cubits/fitness_hub_state.dart';

/// Entry point for the fitness section: the supervised programs, plus the
/// display-only supplements shelf.
class FitnessHubPage extends StatefulWidget {
  const FitnessHubPage({super.key});

  @override
  State<FitnessHubPage> createState() => _FitnessHubPageState();
}

class _FitnessHubPageState extends State<FitnessHubPage> {
  @override
  void initState() {
    super.initState();
    context.read<FitnessHubCubit>().load();
  }

  /// Icons live here rather than on the entity: they're presentation, and
  /// the admin defines programs as data without picking Flutter icons.
  static const Map<String, IconData> _programIcons = {
    'body_management': Icons.monitor_heart_outlined,
    'yoga': Icons.self_improvement_outlined,
    'pilates': Icons.fitness_center_outlined,
    'nutrition': Icons.restaurant_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        centerTitle: true,
        bottom: const AppBarBottomBorder(),
        title: Text(AppStrings.fitness, style: AppTextStyles.heading2),
      ),
      body: BlocBuilder<FitnessHubCubit, FitnessHubState>(
        builder: (context, state) {
          if (state.status == FitnessHubStatus.loading ||
              state.status == FitnessHubStatus.initial) {
            return const CustomLoadingIndicator();
          }

          if (state.status == FitnessHubStatus.failure) {
            return Center(
              child: Text(
                state.failure?.message ?? AppStrings.somethingWentWrong,
                style: AppTextStyles.body,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            children: [
              const _Hero(),
              const SizedBox(height: AppConstants.spacingXl),
              ...state.programs.map(
                    (program) => _ProgramTile(
                  program: program,
                  icon: _programIcons[program.id] ?? Icons.spa_outlined,
                  onTap: () => context.push(RouteNames.healthProgramPath(program.id)),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              _SupplementsTile(
                onTap: () => context.push(RouteNames.supplements),
              ),
              const SizedBox(height: AppConstants.spacingLg),
            ],
          );
        },
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        gradient: AppColors.fireGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.gold, width: AppConstants.borderThin),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: AppConstants.borderThin),
            ),
            child: const Icon(
              Icons.spa_outlined,
              size: AppConstants.iconLg,
              color: AppColors.goldLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            AppStrings.fitnessIntro,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textOnPrimary,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProgramTile extends StatelessWidget {
  final HealthProgram program;
  final IconData icon;
  final VoidCallback onTap;

  const _ProgramTile({required this.program, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSm),
            decoration: BoxDecoration(
              gradient: AppColors.emberGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(icon, size: AppConstants.iconMd, color: AppColors.goldLight),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program.title,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: AppConstants.spacingXs),
                Text(
                  program.intro,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_left,
            color: AppColors.textDisabled,
            size: AppConstants.iconMd,
          ),
        ],
      ),
    );
  }
}

class _SupplementsTile extends StatelessWidget {
  final VoidCallback onTap;

  const _SupplementsTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      borderColor: AppColors.gold,
      child: Row(
        children: [
          const Icon(
            Icons.medical_services_outlined,
            size: AppConstants.iconLg,
            color: AppColors.gold,
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Text(
              AppStrings.supplements,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const Icon(
            Icons.chevron_left,
            color: AppColors.textDisabled,
            size: AppConstants.iconMd,
          ),
        ],
      ),
    );
  }
}