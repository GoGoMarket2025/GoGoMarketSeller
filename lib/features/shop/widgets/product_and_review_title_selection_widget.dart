import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class ProductAndReviewSelectionWidget extends StatelessWidget {
  const ProductAndReviewSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: Theme.of(context).cardColor,
      child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Consumer<ShopController>(
          builder: (context,shopProvider,child)=>Row(children: [
            InkWell(
              onTap: () => shopProvider.updateSelectedIndex(0),
              child: Column(children: [
                Text(getTranslated('all_products', context)!, style: shopProvider.selectedIndex == 0 ?
                titilliumSemiBold : titilliumRegular),
                Container(height: 1, width: MediaQuery.of(context).size.width/2-30,
                  margin: const EdgeInsets.only(top: 8),
                  color: shopProvider.selectedIndex == 0 ?
                  Theme.of(context).primaryColor : Colors.transparent,
                ),
              ],),),
            const SizedBox(width: Dimensions.paddingSizeSmall),


            InkWell(onTap: () => shopProvider.updateSelectedIndex(1),
              child: Column(children: [
                Text(getTranslated('product_review', context)!, style: shopProvider.selectedIndex == 1 ?
                titilliumSemiBold : titilliumRegular),
                Container(height: 1, width: MediaQuery.of(context).size.width/2-30, margin: const EdgeInsets.only(top: 8),
                    color: shopProvider.selectedIndex == 1 ?
                    Theme.of(context).primaryColor : Colors.transparent
                ),
              ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
