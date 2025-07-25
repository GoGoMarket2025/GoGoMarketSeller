import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';




class CustomEditDialogWidget extends StatefulWidget {
  final double totalEarning;
  const CustomEditDialogWidget({super.key, required this.totalEarning});

  @override
  CustomEditDialogWidgetState createState() => CustomEditDialogWidgetState();
}

class CustomEditDialogWidgetState extends State<CustomEditDialogWidget> {

  final TextEditingController _balanceController = TextEditingController();

  @override
  void initState() {

    Provider.of<WalletController>(context, listen: false).setMethodTypeIndex(0, notify: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return SingleChildScrollView(
      child: Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,),
        child: Container(decoration: BoxDecoration(
          color: Provider.of<ThemeController>(context).darkTheme ?
          Theme.of(context).cardColor :
          Theme.of(context).highlightColor,
          borderRadius: const BorderRadius.only(topLeft:  Radius.circular(25), topRight: Radius.circular(25)),),
          child: Container(width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
                GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.keyboard_arrow_down)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

                Consumer<WalletController>(
                    builder: (context, withdraw,_) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeDefault,
                          horizontal: Dimensions.paddingSizeSmall,
                        ),
                        child: Column(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(color: Theme.of(context).cardColor,
                                border: Border.all(width: .5, color: Theme.of(context).hintColor.withValues(alpha:.7)),
                                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
                            child: DropdownButton<int>(
                              value: withdraw.methodSelectedIndex,
                              items: withdraw.methodsIds.map((int? value) {
                                return DropdownMenuItem<int>(
                                  value: withdraw.methodsIds.indexOf(value),
                                  child: Text(withdraw.methodList[(withdraw.methodsIds.indexOf(value))].methodName!),);}).toList(),
                              onChanged: (int? value) {
                                withdraw.setMethodTypeIndex(value);
                              },
                              isExpanded: true, underline: const SizedBox(),),),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          if(withdraw.methodList.isNotEmpty &&
                              withdraw.methodList[withdraw.methodSelectedIndex!].methodFields != null &&
                              withdraw.inputFieldControllerList.isNotEmpty &&
                              withdraw.methodList[withdraw.methodSelectedIndex!].methodFields!.isNotEmpty)
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: withdraw.methodList[withdraw.methodSelectedIndex!].methodFields!.length,
                              itemBuilder: (context, index){

                                String? type = withdraw.methodList[withdraw.methodSelectedIndex!].methodFields![index].inputType;

                                return Padding(
                                  padding:  const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                  child: Column(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextFieldWidget(
                                        textInputType: (type == 'number' || type == "phone") ? TextInputType.number:
                                        TextInputType.text,
                                        border: true,
                                        controller: withdraw.inputFieldControllerList[index],
                                        hintText: withdraw.methodList[withdraw.methodSelectedIndex!].methodFields![index].placeholder,

                                      ),
                                    ],
                                  ),
                                );
                              })
                        ],),
                      );
                    }
                ),

                const SizedBox(height: 20,),
                Text(getTranslated('enter_Amount', context)!, style: const TextStyle(fontWeight: FontWeight.w500,fontSize: Dimensions.fontSizeDefault),),

                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(Provider.of<SplashController>(context, listen: false).myCurrency!.symbol!,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLargeTwenty)),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _balanceController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: 'Ex: 500',
                          hintStyle: robotoMedium.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeLarge),
                        ),
                      ),
                    ),
                  ],
                ),
                Image.asset(Images.inputLine),

                const SizedBox(height: 35,),

                !Provider.of<WalletController>(context).isLoading?
                Consumer<WalletController>(
                  builder: (context, withdraw,_) {
                    return InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        bool haveBlankTitle = false;
                        for(TextEditingController title in withdraw.inputFieldControllerList){
                          if(title.text.isEmpty){
                            haveBlankTitle = true;
                            break;
                          }
                        }

                        if(haveBlankTitle) {
                          Navigator.of(context).pop();
                          showCustomSnackBarWidget(getTranslated('please_fill_all_the_field', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
                        } else if(_balanceController.text.trim() == '') {
                          Navigator.of(context).pop();
                          showCustomSnackBarWidget(getTranslated('please_enter_amount', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
                        } else if ((double.tryParse(_balanceController.text) ?? 0) <= 0) {
                          Navigator.of(context).pop();
                          showCustomSnackBarWidget(getTranslated('withdraw_amount_should_be_grater_then', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
                        } else if(double.parse(_balanceController.text != '' ? _balanceController.text : '0') >  double.tryParse(PriceConverter.convertPriceWithoutSymbol(context, widget.totalEarning))!) {
                          Navigator.of(context).pop();
                          showCustomSnackBarWidget(getTranslated('amount_should_be', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
                        }else{
                          withdrawBalance();
                        }
                      },
                      child: Card(
                        color: Theme.of(context).primaryColor,
                        child: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text(getTranslated('withdraw', context)!,
                                style: const TextStyle(fontSize: Dimensions.fontSizeLarge,fontWeight: FontWeight.w500,color: Colors.white)),
                          ),
                        ),
                      ),
                    );
                  }
                ): Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
              ],
            ),
          ),
        ),
      ),
    );

  }

  void withdrawBalance() async {
    String balance = '0';
    double bal = 0;
    balance = _balanceController.text.trim();
    if(balance.isNotEmpty){
       bal = double.parse(balance);
    }
    if (balance.isEmpty) {
      showCustomSnackBarWidget(getTranslated('enter_balance', context), context, isToaster: true);

    }else if(bal > double.parse(PriceConverter.convertPriceWithoutSymbol(context, Provider.of<ProfileController>(context, listen: false).userInfoModel!.wallet!.totalEarning))) {
      showCustomSnackBarWidget(getTranslated('insufficient_balance', context), context, isToaster: true);
    }else if(bal <= 1 ) {
      showCustomSnackBarWidget(getTranslated('minimum_amount', context), context, isToaster: true);
    }else if(bal <= 1 ) {
      showCustomSnackBarWidget(getTranslated('minimum_amount', context), context, isToaster: true);
    }
    else {
      await Provider.of<WalletController>(context, listen: false).updateBalance(bal.toString(), context);
    }
  }
}
