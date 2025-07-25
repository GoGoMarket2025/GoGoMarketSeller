import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/shipping/controllers/shipping_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class DropDownForShippingTypeWidget extends StatelessWidget {
  const DropDownForShippingTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, 0),
      child: Consumer<ShippingController>(
        builder: (context, shippingProvider, _) {
          return Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
              border: Border.all(width: .5, color: Theme.of(context).hintColor.withValues(alpha:.7)),
            ),
            child: DropdownButton<String>(
              value: shippingProvider.selectedShippingTypeName,
              items: shippingProvider.shippingType.map((String value) {
                return DropdownMenuItem<String>(
                    value: value,
                    child: Text(getTranslated(value, context)!));
              }).toList(),
              onChanged: (val) {
                shippingProvider.setShippingTypeIndex(context, val == 'category_wise'? 0: val == 'order_wise'?1:2);
              },
              isExpanded: true,
              underline: const SizedBox(),
            ),
          );
        }
      ),
    );
  }
}
