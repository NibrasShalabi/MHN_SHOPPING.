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

  static HealthProgram? _byId(List<HealthProgram> programs, String id) {
    for (final program in programs) {
      if (program.id == id) return program;
    }
    return null;
  }

  /// Base → middle → top, per 7.9: body management (the assessment
  /// everything else builds on) is the most prominent, nutrition the
  /// least. Yoga and pilates share the middle tier since the spec treats
  /// them as one "activity" step.
  static List<HealthProgram> _otherPrograms(List<HealthProgram> programs) {
    const knownIds = {'body_management', 'yoga', 'pilates', 'nutrition'};
    return programs.where((p) => !knownIds.contains(p.id)).toList();
  }

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

          final others = _otherPrograms(state.programs);

          return ListView(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            children: [
              const _Hero(),
              const SizedBox(height: AppConstants.spacingXl),
              _FitnessPyramid(
                base: _byId(state.programs, 'body_management'),
                yoga: _byId(state.programs, 'yoga'),
                pilates: _byId(state.programs, 'pilates'),
                nutrition: _byId(state.programs, 'nutrition'),
                icons: _programIcons,
                onTapProgram: (id) => context.push(RouteNames.healthProgramPath(id)),
              ),
              // Any program id the admin adds later that isn't one of the
              // known four still renders here, rather than vanishing.
              for (final program in others) ...[
                const SizedBox(height: AppConstants.spacingSm),
                _ProgramTile(
                  program: program,
                  icon: _programIcons[program.id] ?? Icons.spa_outlined,
                  onTap: () => context.push(RouteNames.healthProgramPath(program.id)),
                ),
              ],
              const SizedBox(height: AppConstants.spacingXl),
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

/// The pyramid itself: a hollow, gold-outlined step shape (drawn, not
/// simulated with card sizes) with each program's icon + title overlaid
/// on its band. Base is full width, middle narrower (yoga + pilates side
/// by side), top narrowest (nutrition) — matching 7.9's sketch as an
/// actual pyramid silhouette instead of stacked rectangles.
class _FitnessPyramid extends StatelessWidget {
  final HealthProgram? base;
  final HealthProgram? yoga;
  final HealthProgram? pilates;
  final HealthProgram? nutrition;
  final Map<String, IconData> icons;
  final ValueChanged<String> onTapProgram;

  const _FitnessPyramid({
    required this.base,
    required this.yoga,
    required this.pilates,
    required this.nutrition,
    required this.icons,
    required this.onTapProgram,
  });

  static const double _height = 300;
  // The triangle's own width at each seam is w/3 and 2w/3 — these stay a
  // little under that so content clears the slopes with some margin.
  static const double _topWidthFactor = 0.3;
  static const double _midWidthFactor = 0.6;

  @override
  Widget build(BuildContext context) {
    if (base == null && yoga == null && pilates == null && nutrition == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const bandHeight = _height / 3;

        return SizedBox(
          height: _height,
          width: width,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, _height),
                painter: const _PyramidOutlinePainter(),
              ),
              if (nutrition != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: bandHeight,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      widthFactor: _topWidthFactor,
                      child: _PyramidBandContent(
                        program: nutrition!,
                        icon: icons[nutrition!.id] ?? Icons.spa_outlined,
                        onTap: () => onTapProgram(nutrition!.id),
                        compact: true,
                      ),
                    ),
                  ),
                ),
              if (yoga != null || pilates != null)
                Positioned(
                  top: bandHeight,
                  left: 0,
                  right: 0,
                  height: bandHeight,
                  child: Center(
                    child: FractionallySizedBox(
                      widthFactor: _midWidthFactor,
                      child: Row(
                        children: [
                          if (yoga != null)
                            Expanded(
                              child: _PyramidBandContent(
                                program: yoga!,
                                icon: icons[yoga!.id] ?? Icons.spa_outlined,
                                onTap: () => onTapProgram(yoga!.id),
                                compact: true,
                              ),
                            ),
                          if (pilates != null)
                            Expanded(
                              child: _PyramidBandContent(
                                program: pilates!,
                                icon: icons[pilates!.id] ?? Icons.spa_outlined,
                                onTap: () => onTapProgram(pilates!.id),
                                compact: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (base != null)
                Positioned(
                  top: bandHeight * 2,
                  left: 0,
                  right: 0,
                  height: bandHeight,
                  child: Center(
                    child: _PyramidBandContent(
                      program: base!,
                      icon: icons[base!.id] ?? Icons.spa_outlined,
                      onTap: () => onTapProgram(base!.id),
                      compact: false,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Draws the hollow triangle outline only — gold stroke, transparent
/// fill, sharp (miter) corners so the apex is an actual point, not a
/// rounded dome. Exactly 3 sides: two slopes + the base. Two horizontal
/// seams cross the interior at the tier boundaries, each sized to the
/// triangle's own width at that height — not an independent value — so
/// they sit flush with the slopes instead of poking past them.
class _PyramidOutlinePainter extends CustomPainter {
  const _PyramidOutlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bandHeight = h / 3;

    double leftEdgeAt(double y) => (w / 2) * (1 - y / h);
    double rightEdgeAt(double y) => w - leftEdgeAt(y);

    final outline = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppConstants.borderThin * 2
      ..strokeJoin = StrokeJoin.miter;

    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, outline);

    final seam = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.5)
      ..strokeWidth = AppConstants.borderThin;
    canvas.drawLine(
      Offset(leftEdgeAt(bandHeight), bandHeight),
      Offset(rightEdgeAt(bandHeight), bandHeight),
      seam,
    );
    canvas.drawLine(
      Offset(leftEdgeAt(bandHeight * 2), bandHeight * 2),
      Offset(rightEdgeAt(bandHeight * 2), bandHeight * 2),
      seam,
    );
  }

  @override
  bool shouldRepaint(covariant _PyramidOutlinePainter oldDelegate) => false;
}

/// Icon + title (+ intro, base tier only) for one band. Kept hollow like
/// the shape itself: no card background, gold icon, tappable via InkWell.
class _PyramidBandContent extends StatelessWidget {
  final HealthProgram program;
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  const _PyramidBandContent({
    required this.program,
    required this.icon,
    required this.onTap,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? AppConstants.iconMd : AppConstants.iconLg,
              color: AppColors.iconPrimary,
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              program.title,
              style: compact
                  ? AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)
                  : AppTextStyles.heading2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (!compact) ...[
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                program.intro,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
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
            color: AppColors.iconPrimary,
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