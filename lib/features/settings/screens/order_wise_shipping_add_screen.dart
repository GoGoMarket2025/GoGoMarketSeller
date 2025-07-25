import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/shipping/domain/models/shipping_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/shipping/controllers/shipping_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/settings/screens/order_wise_shipping_list_screen.dart';


class OrderWiseShippingAddScreen extends StatefulWidget {
  final ShippingModel? shipping;
  const OrderWiseShippingAddScreen({super.key, this.shipping});
  @override
  OrderWiseShippingAddScreenState createState() => OrderWiseShippingAddScreenState();
}

class OrderWiseShippingAddScreenState extends State<OrderWiseShippingAddScreen> {

  TextEditingController? _titleController ;
  TextEditingController? _durationController ;
  TextEditingController? _costController ;

  final FocusNode _resNameNode = FocusNode();
  final FocusNode _addressNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();
  GlobalKey<FormState>? _formKeyLogin;
  ShippingModel? shipping;

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    _titleController = TextEditingController();
    _durationController = TextEditingController();
    _costController = TextEditingController();
    shipping = ShippingModel();
  }

  @override
  void dispose() {
    _titleController!.dispose();
    _durationController!.dispose();
    _costController!.dispose();
    super.dispose();
  }
  void callback(bool route, String error ){
    if(route){
      if(widget.shipping==null){
        showCustomSnackBarWidget(getTranslated('shipping_method_added_successfully', context)!, context, isError: false);
        Navigator.of(context).pop();
      }else{
        showCustomSnackBarWidget(getTranslated('shipping_method_update_successfully', context)!, context, isError: false);
        Navigator.of(context).pop();
      }

        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OrderWiseShippingScreen()));

    }else{
      showCustomSnackBarWidget(error,context,  sanckBarType: SnackBarType.warning);
    }

}

  @override
  Widget build(BuildContext context) {
    if(widget.shipping!=null) {
      _titleController!.text = widget.shipping!.title!;
      _durationController!.text = widget.shipping!.duration!;
      _costController!.text = PriceConverter.convertAmount(widget.shipping!.cost!, context).toString();
    }
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Consumer<AuthController>(
          builder: (context, authProvider, child) => Form(
            key: _formKeyLogin,
            child: ListView(shrinkWrap: true, physics: const BouncingScrollPhysics(), children: [

                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(getTranslated('shipping_method_title', context)!,
                    style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).hintColor,)),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                CustomTextFieldWidget(
                  border: true,
                  hintText: getTranslated('enter_shipping_method_title', context),
                  focusNode: _resNameNode,
                  nextNode: _addressNode,
                  controller: _titleController,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Text(getTranslated('duration', context)!,
                    style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).hintColor,)),

                const SizedBox(height: Dimensions.paddingSizeSmall),
                CustomTextFieldWidget(
                  border: true,
                  hintText: 'Ex: 4-6 days',
                  focusNode: _addressNode,
                  controller: _durationController,
                  textInputType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 22),
                Text(getTranslated('cost', context)!,
                    style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).hintColor,)),

                const SizedBox(height: Dimensions.paddingSizeSmall),
                CustomTextFieldWidget(
                  border: true,
                  hintText: 'Ex: \$100',
                  controller: _costController,
                  focusNode: _phoneNode,
                  textInputAction: TextInputAction.done,
                  textInputType: TextInputType.number,
                  isAmount: true,
                ),

                // for login button
                const SizedBox(height: 50),

                Consumer<ShippingController>(builder: (context, shipProvider, child) {
                  return !shipProvider.isLoading ? CustomButtonWidget(
                    fontColor: Colors.white,
                    btnTxt: widget.shipping == null?
                    getTranslated('save', context):getTranslated('update', context),
                    onTap: ()  {
                      String title = _titleController!.text.trim();
                      String cost = _costController!.text.trim();
                      String duration = _durationController!.text.trim();

                      if(title.isEmpty){
                        showCustomSnackBarWidget(getTranslated('enter_title', context),context,  sanckBarType: SnackBarType.warning);
                      }else if(cost.isEmpty){
                        showCustomSnackBarWidget(getTranslated('enter_cost', context),context,  sanckBarType: SnackBarType.warning);
                      }else if(duration.isEmpty){
                        showCustomSnackBarWidget(getTranslated('enter_duration', context),context,  sanckBarType: SnackBarType.warning);
                      } else{
                        shipping!.title = title;
                        shipping!.cost = PriceConverter.systemCurrencyToDefaultCurrency(double.parse(cost), context);
                        shipping!.duration = duration;
                        if (kDebugMode) {
                          print('-------${shipping!.cost}');
                        }
                        if(widget.shipping == null){
                          Provider.of<ShippingController>(context,listen: false).addShippingMethod(shipping, callback);
                        }
                        else if(widget.shipping != null){
                          Provider.of<ShippingController>(context,listen: false).updateShippingMethod(shipping!.title,shipping!.duration,shipping!.cost,widget.shipping!.id, callback);
                        }
                      }
                    },
                  ) : const Center(child: CircularProgressIndicator());
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
