// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../core/constants/app_constants.dart';
// import '../../../../core/constants/app_strings.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/utils/validators.dart';
// import '../../../../core/widgets/app_bar_bottom_border.dart';
// import '../../../../core/widgets/app_snackbar.dart';
// import '../../../../core/widgets/custom/custom_button.dart';
// import '../../../../core/widgets/custom/custom_text_field.dart';
// import '../../domain/entities/product_suggestion.dart';
// import '../cubits/suggest_product_cubit.dart';
// import '../cubits/suggest_product_state.dart';
// import '../widgets/suggestion_terms_card.dart';
//
// class SuggestProductPage extends StatefulWidget {
//   const SuggestProductPage({super.key});
//
//   @override
//   State<SuggestProductPage> createState() => _SuggestProductPageState();
// }
//
// class _SuggestProductPageState extends State<SuggestProductPage> {
//   final _nameController = TextEditingController();
//   final _linkController = TextEditingController();
//
//   String? _nameError;
//   String? _linkError;
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _linkController.dispose();
//     super.dispose();
//   }
//
//   void _submit(BuildContext context) {
//     final nameError = Validators.productName(_nameController.text);
//     final linkError = Validators.productLink(_linkController.text);
//
//     setState(() {
//       _nameError = nameError;
//       _linkError = linkError;
//     });
//
//     if (nameError != null || linkError != null) return;
//
//     context.read<SuggestProductCubit>().submit(
//       ProductSuggestion(
//         productName: _nameController.text.trim(),
//         productLink: _linkController.text.trim(),
//       ),
//     );
//   }
//
//   void _clear() {
//     _nameController.clear();
//     _linkController.clear();
//     setState(() {
//       _nameError = null;
//       _linkError = null;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.surface,
//       appBar: AppBar(
//         backgroundColor: AppColors.surfaceWine,
//         elevation: 0,
//         centerTitle: true,
//         // It's a bottom-nav tab now, not a pushed page — no back arrow.
//         automaticallyImplyLeading: false,
//         bottom: const AppBarBottomBorder(),
//         title: Text(AppStrings.suggestProduct, style: AppTextStyles.heading2),
//       ),
//       body: BlocConsumer<SuggestProductCubit, SuggestProductState>(
//         listener: (context, state) {
//           if (state.status == SuggestProductStatus.success) {
//             _clear();
//             AppSnackbar.success(context, AppStrings.suggestionSent);
//           } else if (state.status == SuggestProductStatus.failure &&
//               state.failure != null) {
//             AppSnackbar.error(context, state.failure!.message);
//           }
//         },
//         builder: (context, state) {
//           final isSubmitting = state.status == SuggestProductStatus.submitting;
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(AppConstants.spacingMd),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const _Hero(),
//                 const SizedBox(height: AppConstants.spacingXl),
//
//                 CustomTextField(
//                   controller: _nameController,
//                   label: AppStrings.productName,
//                   hint: AppStrings.suggestProductHint,
//                   prefixIcon: Icons.shopping_bag_outlined,
//                   errorText: _nameError,
//                   enabled: !isSubmitting,
//                 ),
//                 const SizedBox(height: AppConstants.spacingMd),
//                 CustomTextField(
//                   controller: _linkController,
//                   label: AppStrings.productLink,
//                   hint: AppStrings.productLinkHint,
//                   keyboardType: TextInputType.url,
//                   prefixIcon: Icons.link,
//                   errorText: _linkError,
//                   enabled: !isSubmitting,
//                 ),
//                 const SizedBox(height: AppConstants.spacingLg),
//
//                 const SuggestionTermsCard(),
//                 const SizedBox(height: AppConstants.spacingLg),
//
//                 CustomButton(
//                   label: AppStrings.submitSuggestion,
//                   icon: Icons.send_outlined,
//                   width: double.infinity,
//                   isLoading: isSubmitting,
//                   onPressed: () => _submit(context),
//                 ),
//                 const SizedBox(height: AppConstants.spacingLg),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _Hero extends StatelessWidget {
//   const _Hero();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(AppConstants.spacingLg),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [AppColors.primary, AppColors.primaryDark],
//         ),
//         borderRadius: BorderRadius.circular(AppConstants.radiusLg),
//         border: Border.all(color: AppColors.gold, width: AppConstants.borderThin),
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(AppConstants.spacingSm),
//             decoration: BoxDecoration(
//               color: AppColors.surfaceDark.withValues(alpha: 0.35),
//               shape: BoxShape.circle,
//               border: Border.all(color: AppColors.gold, width: AppConstants.borderThin),
//             ),
//             child: const Icon(
//               Icons.lightbulb_outline,
//               size: AppConstants.iconLg,
//               color: AppColors.goldLight,
//             ),
//           ),
//           const SizedBox(height: AppConstants.spacingMd),
//           Text(
//             AppStrings.suggestProductIntro,
//             style: AppTextStyles.body.copyWith(
//               color: AppColors.textOnPrimary,
//               height: 1.7,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_text_field.dart';
import '../../domain/entities/product_suggestion.dart';
import '../cubits/suggest_product_cubit.dart';
import '../cubits/suggest_product_state.dart';
import '../widgets/suggestion_terms_card.dart';

class SuggestProductPage extends StatefulWidget {
  const SuggestProductPage({super.key});

  @override
  State<SuggestProductPage> createState() => _SuggestProductPageState();
}

class _SuggestProductPageState extends State<SuggestProductPage> {
  final _nameController = TextEditingController();
  final _linkController = TextEditingController();

  String? _nameError;
  String? _linkError;

  @override
  void dispose() {
    _nameController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final nameError = Validators.productName(_nameController.text);
    final linkError = Validators.productLink(_linkController.text);

    setState(() {
      _nameError = nameError;
      _linkError = linkError;
    });

    if (nameError != null || linkError != null) return;

    context.read<SuggestProductCubit>().submit(
      ProductSuggestion(
        productName: _nameController.text.trim(),
        productLink: _linkController.text.trim(),
      ),
    );
  }

  void _clear() {
    _nameController.clear();
    _linkController.clear();
    setState(() {
      _nameError = null;
      _linkError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        centerTitle: true,
        // It's a bottom-nav tab now, not a pushed page — no back arrow.
        automaticallyImplyLeading: false,
        bottom: const AppBarBottomBorder(),
        title: Text(AppStrings.suggestProduct, style: AppTextStyles.heading2),
      ),
      body: BlocConsumer<SuggestProductCubit, SuggestProductState>(
        listener: (context, state) {
          if (state.status == SuggestProductStatus.success) {
            _clear();
            AppSnackbar.success(context, AppStrings.suggestionSent);
          } else if (state.status == SuggestProductStatus.failure &&
              state.failure != null) {
            AppSnackbar.error(context, state.failure!.message);
          }
        },
        builder: (context, state) {
          final isSubmitting = state.status == SuggestProductStatus.submitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Hero(),
                const SizedBox(height: AppConstants.spacingXl),

                CustomTextField(
                  controller: _nameController,
                  label: AppStrings.productName,
                  hint: AppStrings.suggestProductHint,
                  prefixIcon: Icons.shopping_bag_outlined,
                  errorText: _nameError,
                  enabled: !isSubmitting,
                ),
                const SizedBox(height: AppConstants.spacingMd),
                CustomTextField(
                  controller: _linkController,
                  label: AppStrings.productLink,
                  hint: AppStrings.productLinkHint,
                  keyboardType: TextInputType.url,
                  prefixIcon: Icons.link,
                  errorText: _linkError,
                  enabled: !isSubmitting,
                ),
                const SizedBox(height: AppConstants.spacingLg),

                const SuggestionTermsCard(),
                const SizedBox(height: AppConstants.spacingLg),

                CustomButton(
                  label: AppStrings.submitSuggestion,
                  icon: Icons.send_outlined,
                  width: double.infinity,
                  isLoading: isSubmitting,
                  onPressed: () => _submit(context),
                ),
                const SizedBox(height: AppConstants.spacingLg),
              ],
            ),
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
              Icons.lightbulb_outline,
              size: AppConstants.iconLg,
              color: AppColors.goldLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            AppStrings.suggestProductIntro,
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