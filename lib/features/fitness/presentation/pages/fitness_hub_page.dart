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
import '../../../../core/widgets/fire_sparks.dart';
import '../../../../core/widgets/gold_frame.dart';
import '../../domain/entities/health_program.dart';
import '../cubits/fitness_hub_cubit.dart';
import '../cubits/fitness_hub_state.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../core/widgets/content_width.dart';

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
    'hp1': Icons.monitor_heart_outlined,
    'yoga': Icons.self_improvement_outlined,
    'pilates': Icons.fitness_center_outlined,
    'nutrition': Icons.restaurant_outlined,
  };

  static HealthProgram? _byId(List<HealthProgram> programs, String id) {
    for (final program in programs) {
      // A section shows once the specialist has given it questions.
      if (program.id == id && program.fields.isNotEmpty) return program;
    }
    return null;
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
      body: ContentWidth(
        maxWidth: 760,
        child: BlocBuilder<FitnessHubCubit, FitnessHubState>(
        builder: (context, state) {
          if (state.status == FitnessHubStatus.loading ||
              state.status == FitnessHubStatus.initial) {
            return const CustomLoadingIndicator();
          }

          if (state.status == FitnessHubStatus.failure) {
            return ErrorRetry(failure: state.failure, onRetry: () => context.read<FitnessHubCubit>().load());
          }

          return ListView(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            children: [
              const _Hero(),
              const SizedBox(height: AppConstants.spacingXl), 
              _FitnessPyramid(
                base: _byId(state.programs, 'hp1'),
                yoga: _byId(state.programs, 'yoga'),
                pilates: _byId(state.programs, 'pilates'),
                nutrition: _byId(state.programs, 'nutrition'),
                icons: _programIcons,
                onTapProgram: (id) => context.push(RouteNames.healthProgramPath(id)),
              ),
              const SizedBox(height: AppConstants.spacingXl),
              _SupplementsTile(
                onTap: () => context.push(RouteNames.supplements),
              ),
              const SizedBox(height: AppConstants.spacingLg),
            ],
          );
        },
      ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return GoldFrame(
      child: Stack(
        children: [
          const Positioned.fill(child: FireSparks(active: true)),
          Container(
            width: double.infinity, // a Stack child otherwise hugs the corner on wide screens
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.45), blurRadius: 22, spreadRadius: 1)],
                  ),
                  child: Image.asset('assets/images/fitness_emblem.png', filterQuality: FilterQuality.medium),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                Text(
                  AppStrings.fitnessIntro,
                  style: AppTextStyles.body.copyWith(color: AppColors.textOnPrimary, height: 1.7),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
        // Wider than this the triangle turns into a flat roof.
        final width = constraints.maxWidth.clamp(0.0, 560.0);
        const bandHeight = _height / 3;

        return Center(
          child: SizedBox(
          height: _height,
          width: width,
          child: Stack(
            children: [
              // Same coal-to-fire fill and rising embers as the cards, cut to the triangle.
              Positioned.fill(
                child: ClipPath(
                  clipper: const _TriangleClipper(),
                  child: const DecoratedBox(
                    // Fire rising from the base into coal at the tip — a
                    // side-to-side sweep split the shape in two halves.
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppColors.flame, AppColors.scarlet, AppColors.ember, AppColors.surfaceDark],
                        stops: [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                    child: FireSparks(active: true),
                  ),
                ),
              ),
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
        ),
        );
      },
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  const _TriangleClipper();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width / 2, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Draws the triangle outline — gold stroke, transparent
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
      ..color = AppColors.goldLight.withValues(alpha: 0.6)
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
              color: AppColors.goldLight,
            ),
            const SizedBox(height: AppConstants.spacingXs),
            GoldText(
              program.title,
              style: (compact ? AppTextStyles.body : AppTextStyles.heading2).copyWith(
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 6, offset: const Offset(0, 1))],
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            if (!compact) ...[
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                program.intro,
                style: AppTextStyles.caption.copyWith(color: AppColors.goldLight.withValues(alpha: 0.85)),
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
    return GoldFrame(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          children: [
            const Icon(Icons.medical_services_outlined, size: AppConstants.iconLg, color: AppColors.goldLight),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: GoldText(AppStrings.supplements, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            ),
            const Icon(Icons.chevron_left, color: AppColors.goldLight, size: AppConstants.iconMd),
          ],
        ),
      ),
    );
  }
}
