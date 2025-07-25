import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/bank_info/controllers/bank_info_controller.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/features/home/widgets/order_type_button_head_widget.dart';

class OngoingOrderWidget extends StatelessWidget {
  final Function? callback;
  const OngoingOrderWidget({super.key, this.callback});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(
      builder: (context, order, child) {
        return Consumer<BankInfoController>(
          builder: (context,bankInfoController,child){
            return Container(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:.05),
                      spreadRadius: -3, blurRadius: 12, offset: Offset.fromDirection(0,6))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [


                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(width: Dimensions.iconSizeLarge,height: Dimensions.iconSizeLarge ,
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                          child: Image.asset(Images.monthlyEarning)),
                      const SizedBox(width: Dimensions.paddingSizeSmall,),

                      Text(getTranslated('business_analytics', context)!, style: robotoBold.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: Dimensions.fontSizeDefault),),

                      const Expanded(child: SizedBox(width: Dimensions.paddingSizeExtraLarge,)),
                      Container(
                        height: 50,width: 120,
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(width: .7,color: Theme.of(context).hintColor.withValues(alpha:.3)),
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),

                        ),
                        child: DropdownButton<String>(
                          value: bankInfoController.analyticsIndex == 0 ? 'overall' : bankInfoController.analyticsIndex == 1 ?  'today' : 'this_month',
                          items: <String>['overall', 'today', 'this_month' ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(getTranslated(value, context)!, style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            bankInfoController.setAnalyticsFilterName(context,value, true);
                            bankInfoController.setAnalyticsFilterType(value == 'overall' ? 0 : value == 'today'? 1:2, true);
                          },
                          isExpanded: true,
                          underline: const SizedBox(),
                        ),
                      ),
                    ],),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall,),
                Padding(
                  padding: const EdgeInsets.fromLTRB( Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeExtraSmall, Dimensions.paddingSizeDefault,Dimensions.paddingSeven),
                  child: Text(getTranslated('on_going_orders', context)!,
                    style: robotoBold.copyWith(color: Theme.of(context).primaryColor),),
                ),

                order.orderModel != null ?
                Consumer<BankInfoController>(
                  builder: (context, bankInfoController, child) => Padding(
                    padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall,0, Dimensions.paddingSizeSmall,Dimensions.fontSizeSmall),
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: (1 / .65),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        OrderTypeButtonHeadWidget(
                          color: ColorHelper.blendColors(Colors.white, Theme.of(context).primaryColor, 0.9),
                          text: getTranslated('pending', context), index: 1,
                          subText: getTranslated('orders', context),
                          numberOfOrder: bankInfoController.businessAnalyticsFilterData?.pending ?? 0, callback: callback,
                        ),

                        OrderTypeButtonHeadWidget(
                          color: ColorHelper.blendColors(Colors.white, Theme.of(context).primaryColor, 0.8),
                          text: getTranslated('processing', context), index: 2,
                          numberOfOrder: bankInfoController.businessAnalyticsFilterData?.processing ?? 0, callback: callback,
                          subText: getTranslated('orders', context),
                        ),

                        OrderTypeButtonHeadWidget(
                          color: Theme.of(context).colorScheme.onTertiaryContainer,
                          text: getTranslated('confirmed', context), index: 7,
                          subText: getTranslated('orders', context),
                          numberOfOrder: bankInfoController.businessAnalyticsFilterData?.confirmed ?? 0, callback: callback,
                        ),

                        OrderTypeButtonHeadWidget(
                          color: Theme.of(context).colorScheme.error,
                          text: getTranslated('out_for_delivery', context), index: 8,
                          subText: '',
                          numberOfOrder: bankInfoController.businessAnalyticsFilterData?.outForDelivery ?? 0, callback: callback,
                        ),
                      ],
                    ),
                  ),
                ) : SizedBox(height: 150,
                    child: Center(child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor)))),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],),);
          },
        );
      }
    );
  }
}
