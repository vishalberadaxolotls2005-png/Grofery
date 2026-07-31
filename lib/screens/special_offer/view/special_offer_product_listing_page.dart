import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grofery_user/bloc/user_cart_bloc/user_cart_bloc.dart';
import 'package:grofery_user/bloc/user_cart_bloc/user_cart_event.dart';
import 'package:grofery_user/model/user_cart_model/cart_sync_action.dart';
import 'package:grofery_user/model/user_cart_model/user_cart.dart';
import 'package:grofery_user/screens/product_detail_page/model/product_detail_model.dart';
import 'package:grofery_user/utils/widgets/custom_product_card.dart';
import 'package:grofery_user/utils/widgets/custom_scaffold.dart';
import 'package:grofery_user/utils/widgets/empty_states_page.dart';

class SpecialOfferProductListingPage extends StatelessWidget {
  final List<ProductData> products;

  const SpecialOfferProductListingPage({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Special Offers",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "${products.length} items",
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
          ],
        ),
      ),
      body: products.isEmpty
          ? const NoProductPage()
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: GridView.builder(
                padding: EdgeInsets.only(bottom: 20.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 0.53, // Similar to CustomProductCard aspect ratio
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final variant = product.variants != null && product.variants!.isNotEmpty
                      ? product.variants!.first
                      : null;

                  if (variant == null) return const SizedBox.shrink();

                  return CustomProductCard(
                    productId: product.id ?? 0,
                    productImage: product.mainImage ?? '',
                    productName: product.title ?? '',
                    productSlug: product.slug ?? '',
                    productPrice: variant.price.toString(),
                    productTags: product.tags ?? [],
                    productTag: product.tag,
                    productRemark: product.remark,
                    specialPrice: variant.specialPrice.toString(),
                    estimatedDeliveryTime: product.estimatedDeliveryTime ?? '',
                    ratings: (product.ratings ?? 0.0).toDouble(),
                    ratingCount: product.ratingCount ?? 0,
                    quickDeliveryAvailable: product.quickDeliveryAvailable ?? false,
                    onAddToCart: (qty) {
                      context.read<CartBloc>().add(
                            AddToCart(
                              context: context,
                              item: UserCart(
                                productId: product.id.toString(),
                                variantId: variant.id.toString(),
                                variantName: variant.title,
                                vendorId: variant.storeId.toString(),
                                name: product.title,
                                image: product.mainImage,
                                price: variant.getEffectivePrice(qty),
                                originalPrice: variant.price.toDouble(),
                                quantity: qty,
                                minQty: product.minimumOrderQuantity,
                                maxQty: product.totalAllowedQuantity,
                                isOutOfStock: (variant.stock ?? 0) <= 0,
                                isSynced: false,
                                updatedAt: DateTime.now(),
                                syncAction: CartSyncAction.add,
                                tieredPricing: variant.tieredPricing,
                              ),
                            ),
                          );
                    },
                    isStoreOpen: product.storeStatus?.isOpen ?? true,
                    isWishListed: product.favorite != null && product.favorite!.isNotEmpty,
                    productVariantId: variant.id ?? 0,
                    storeId: variant.storeId ?? 0,
                    wishlistItemId: (product.favorite != null && product.favorite!.isNotEmpty)
                        ? product.favorite!.first.id ?? 0
                        : 0,
                    totalStocks: variant.stock ?? 0,
                    imageFit: product.imageFit ?? 'contain',
                    quantityStepSize: product.quantityStepSize ?? 1,
                    minQty: product.minimumOrderQuantity ?? 1,
                    totalAllowedQuantity: product.totalAllowedQuantity ?? 10,
                    tieredPricing: variant.tieredPricing,
                    indicator: product.indicator,
                    useHorizontalLayout: false,
                    mrp: variant.mrp.toString(),
                    mrpStatus: variant.mrpStatus,
                    pricePerUnit: (variant.pricePerUnit != null && variant.pricePerUnit!.isNotEmpty)
                        ? variant.pricePerUnit!
                        : product.pricePerUnit ?? '',
                    measurementUnit: variant.measurementUnit,
                  );
                },
              ),
            ),
    );
  }
}
