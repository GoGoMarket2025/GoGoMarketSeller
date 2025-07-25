import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/delivery_man/controllers/delivery_man_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';




class CollectedCashFromDeliveryManDialog extends StatefulWidget {
  final double? totalCashInHand;
  final int? deliveryManId;
  const CollectedCashFromDeliveryManDialog({super.key, this.totalCashInHand, this.deliveryManId});
  @override
  CollectedCashFromDeliveryManDialogState createState() => CollectedCashFromDeliveryManDialogState();
}

class CollectedCashFromDeliveryManDialogState extends State<CollectedCashFromDeliveryManDialog> {
  bool isTextFieldEmpty = true;

  final TextEditingController _balanceController = TextEditingController();

  List<String> suggestedValue = ['500', '1000', '2000', '5000', '10000'];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Padding(padding: const EdgeInsets.only(top: 70),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Provider.of<ThemeController>(context).darkTheme ?
            Theme.of(context).highlightColor.withValues(alpha: 0.9) :
            Theme.of(context).highlightColor,
            borderRadius: const BorderRadius.only(
                topLeft:  Radius.circular(25),
                topRight: Radius.circular(25)),
          ),
          child: Consumer<DeliveryManController>(
            builder: (context, deliverymanProvider, child)
                {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 100, Dimensions.paddingSizeDefault, 0),
                    child: Column(children: [
                        Row(mainAxisAlignment : MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(child: SizedBox()),

                            IntrinsicWidth(
                              child: TextFormField(
                                inputFormatters: [
                                 LengthLimitingTextInputFormatter(20),
                                ],
                                keyboardType: TextInputType.number,
                                controller: _balanceController,
                                textAlignVertical: TextAlignVertical.center,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                decoration: InputDecoration(
                                    border : InputBorder.none,
                                    isCollapsed: true,
                                    hintText: "Ex: 500",
                                    hintStyle: robotoBold.copyWith(
                                        fontSize: 20)
                                ),
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLargeTwenty,
                                    color: Theme.of(context).textTheme.bodyLarge?.color),
                                onChanged: (String value){
                                  setState(() {
                                    if(value.isNotEmpty){
                                     isTextFieldEmpty = false;
                                    }else{
                                     isTextFieldEmpty = true;
                                    }
                                  });
                                },
                              ),
                            ),

                            Text(Provider.of<SplashController>(context, listen: false).myCurrency!.symbol!,
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLargeTwenty,
                                  color:isTextFieldEmpty? Theme.of(context).hintColor :
                                  Theme.of(context).textTheme.bodyLarge?.color),),

                            const Expanded(child: SizedBox()),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeExtraSmall),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${getTranslated('available_balance', context)} : ', style: robotoRegular.copyWith(
                                color: Theme.of(context).hintColor
                              )),
                              Text(PriceConverter.convertPrice(context, widget.totalCashInHand??0),
                                  style: robotoRegular.copyWith(
                                      color: Theme.of(context).hintColor,
                                      fontSize: Dimensions.fontSizeDefault)),
                            ],
                          ),
                        ),

                        const Divider(),

                        Padding(
                          padding: const EdgeInsets.fromLTRB( Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall, 50),
                          child: SizedBox(height: 30,
                            child: ListView.builder(itemCount: 5,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index){
                              return GestureDetector(
                                onTap: (){
                                  setState(() {
                                    selectedIndex = index;
                                    _balanceController.text = suggestedValue[index];

                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium, ),
                                    decoration: BoxDecoration(
                                      color: index == selectedIndex? Theme.of(context).primaryColor: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(color: index == selectedIndex? Theme.of(context).primaryColor: Theme.of(context).hintColor)
                                    ),
                                    child: Center(child: Text(suggestedValue[index],
                                      style: robotoRegular.copyWith(color: index == selectedIndex?  Colors.white: Theme.of(context).textTheme.bodyLarge?.color),)),
                                  ),
                                ),
                              );
                                }),
                          ),
                        ),

                        !deliverymanProvider.isLoading?
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                          child: CustomButtonWidget(btnTxt: getTranslated('submit', context),onTap: (){
                            String amount =  _balanceController.text.trim();
                            if(amount.isEmpty){
                              Navigator.pop(context);
                              showCustomSnackBarWidget(getTranslated('amount_is_required', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
                            } else if ((widget.totalCashInHand != null && widget.totalCashInHand! < double.parse(amount)) || widget.totalCashInHand == null || widget.totalCashInHand! == 0){
                              Navigator.pop(context);
                              showCustomSnackBarWidget(getTranslated('receive_amount_cantbe_more_then_cash_in_hand', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
                            } else {
                              deliverymanProvider.collectCashFromDeliveryMan(context, widget.deliveryManId, amount);
                            }

                          },),
                        ): Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),

                      ],
                    ),
                  );
                }
          ),
        ),
      ),
    );
  }
}
