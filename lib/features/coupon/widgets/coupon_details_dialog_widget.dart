import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/coupon/domain/models/coupon_model.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class CouponDetailsDialogWidget extends StatelessWidget {
  final Coupons? coupons;
  const CouponDetailsDialogWidget({super.key, this.coupons});

  @override
  Widget build(BuildContext context) {
    double circleSize = 90;
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Stack(children: [
          Center(child: Stack(children: [
                Container(height: 260, decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.paddingSizeMedium),
                          bottomLeft: Radius.circular(Dimensions.paddingSizeMedium))),
                  child: Row(children: [

                    Expanded(child: Container(decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.paddingSizeMedium),
                              bottomLeft: Radius.circular(Dimensions.paddingSizeMedium))))),
                    Container(width: 10, decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiaryContainer)),

                    Container(width: 50, decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(Dimensions.paddingSizeMedium),
                            bottomRight: Radius.circular(Dimensions.paddingSizeMedium))
                    ),),
                  ],),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(children: [
                    Padding(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeMedium, Dimensions.paddingSizeMedium,Dimensions.paddingSizeSmall,Dimensions.paddingSize),
                      child: Container(
                        width: circleSize,height: circleSize,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100),
                          border: Border.all(width: 6,color: Theme.of(context).colorScheme.tertiaryContainer)),
                        child: coupons!.couponType == 'free_delivery'?
                        Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: Image.asset(Images.freeDelivery,width: 40,)):
                        Center(child: coupons!.discountType == 'amount'?
                        Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(PriceConverter.convertPrice(context, coupons!.discount),
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                            Text(getTranslated('off', context)!,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          ],
                        ):
                        Column(mainAxisSize: MainAxisSize.min, children: [
                            Text('${coupons!.discount}%',
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),

                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Text(getTranslated('off', context)!,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          ],
                        )
                        ),
                      ),
                    ),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: Dimensions.paddingSizeSmall,),
                        SizedBox(width: MediaQuery.of(context).size.width/2.4, child: Text(coupons!.title!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,
                            color:  Theme.of(context).textTheme.bodyMedium?.color))),
                        const SizedBox(height: Dimensions.paddingEye),
                        Text('${getTranslated('code', context)} : ${coupons!.code}',
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyMedium?.color)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Text(getTranslated(coupons!.couponType, context)!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      ],
                    )
                  ]),
                  Padding(padding: const EdgeInsets.only(left: 30),
                    child: Column(children: [
                      Row(children: [
                        Text('${getTranslated('minimum_purchase', context)} : ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        Text(PriceConverter.convertPrice(context, coupons!.minPurchase), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),),
                      ],),
                      const SizedBox(height: Dimensions.paddingSizeMedium,),
                      Row(children: [
                        Text('${getTranslated('maximum_discount', context)} : ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        Text(PriceConverter.convertPrice(context, coupons!.maxDiscount), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      ],),
                      const SizedBox(height: Dimensions.paddingSizeMedium,),
                      Row(children: [
                        Text('${getTranslated('start_from', context)} : ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        Text(DateConverter.isoStringToDateTimeString(coupons!.createdAt!), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),),
                      ],),
                      const SizedBox(height: Dimensions.paddingSizeMedium,),
                      Row(children: [
                        Text('${getTranslated('expires_on', context)} : ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        Text(DateConverter.isoStringToDateTimeString(coupons!.expireDate!), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),),
                      ],),
                    ],),
                  )
                ],),
              ],
            ),
          ),
          Positioned(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: ()=> Navigator.pop(context),
                    child: Padding(
                      padding:  EdgeInsets.only(left:Dimensions.paddingSizeSmall,
                          right:Dimensions.paddingSizeSmall,
                          bottom: MediaQuery.of(context).size.height/3.9),
                      child: const SizedBox(child: Icon(Icons.clear, color: Colors.white),),
                    ),
                  ))),
        ],
      ),
    );
  }
}
