import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/whatsapp.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../home/data/repository/catalog_repository.dart';
import '../../../home/domain/entities/product.dart';
import '../../domain/entities/supplier.dart';

/// Who sells [product], if a supplier does: its own supplierId, or — for
/// products saved before that field existed — its category's. Both reads
/// come from the catalog cache.
Future<Supplier?> supplierOf(Product product) async {
  final catalog = GetIt.instance<CatalogRepository>();
  try {
    final id = product.supplierId ?? (await catalog.getCategory(product.categoryId)).supplierId;
    return id == null ? null : await catalog.getSupplier(id);
  } catch (_) {
    return null;
  }
}

/// Supplier products are ordered from the supplier directly on WhatsApp.
class SupplierOrderBar extends StatelessWidget {
  final Supplier supplier;
  final String productName;

  const SupplierOrderBar({super.key, required this.supplier, required this.productName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWine,
        border: Border(top: BorderSide(color: AppColors.border, width: AppConstants.borderThin)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.soldBy(supplier.name),
                  textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppConstants.spacingSm),
              CustomButton(
                label: AppStrings.orderFromSupplier,
                icon: Icons.chat_outlined,
                onPressed: () => WhatsApp.open(context, supplier.phone, text: AppStrings.supplierOrderText(productName)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
