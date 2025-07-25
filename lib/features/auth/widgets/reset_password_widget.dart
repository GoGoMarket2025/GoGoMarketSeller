import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/auth/widgets/pass_view.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_pass_textfeild_widget.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/auth_screen.dart';

class ResetPasswordWidget extends StatefulWidget {
  final String mobileNumber;
  final String otp;
  const ResetPasswordWidget({super.key,required this.mobileNumber,required this.otp});

  @override
  ResetPasswordWidgetState createState() => ResetPasswordWidgetState();
}

class ResetPasswordWidgetState extends State<ResetPasswordWidget> {
  TextEditingController? _passwordController;
  TextEditingController? _confirmPasswordController;
  final FocusNode _newPasswordNode = FocusNode();
  final FocusNode _confirmPasswordNode = FocusNode();
  GlobalKey<FormState>? _formKeyReset;

  @override
  void initState() {
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    Provider.of<AuthController>(context, listen: false).validPassCheck('', isUpdate: false);
    if(Provider.of<AuthController>(context, listen: false).showPassView) {
      Provider.of<AuthController>(context, listen: false).showHidePass(isUpdate: false);
    }
    super.initState();
  }


  void resetPassword() async {
      String password = _passwordController!.text.trim();
      String confirmPassword = _confirmPasswordController!.text.trim();

      if (password.isEmpty) {
        showCustomSnackBarWidget(getTranslated('password_is_required', context), context, sanckBarType: SnackBarType.warning);
      } else if (confirmPassword.isEmpty) {
        showCustomSnackBarWidget(getTranslated('confirm_password_is_required', context), context, sanckBarType: SnackBarType.warning);
      } else if (!Provider.of<AuthController>(context, listen: false).isPasswordValid()) {
        showCustomSnackBarWidget(getTranslated('enter_valid_password', context), context, sanckBarType: SnackBarType.warning);
      } else if (password != confirmPassword) {
        showCustomSnackBarWidget(getTranslated('password_did_not_match', context), context, sanckBarType: SnackBarType.warning);
      } else {
        Provider.of<AuthController>(context, listen: false).resetPassword(widget.mobileNumber,widget.otp,
            password, confirmPassword).then((value) {
          if(value.isSuccess) {
            showCustomSnackBarWidget(getTranslated('password_reset_successfully', Get.context!), Get.context!, sanckBarType: SnackBarType.success);
            Navigator.pushAndRemoveUntil(Get.context!, MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false);
          }else {
            showCustomSnackBarWidget(value.message, Get.context!);
          }
        });
      }
    // }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKeyReset,
        child: Consumer<AuthController>(
          builder: (authContext, authProvider, _) {
            return ListView( padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall), children: [
                Padding(
                  padding: const EdgeInsets.all(50),
                  child: Image.asset(Images.logoWithAppName, height: 150, width: 200),
                ),

                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Text(getTranslated('password_reset', context)!, style: robotoBold),
                ),
                // for new password
                Container(
                    margin:
                    const EdgeInsets.only(left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge,
                        bottom: Dimensions.paddingSizeSmall),
                    child: CustomPasswordTextFieldWidget(
                      hintTxt: getTranslated('new_password', context),
                      focusNode: _newPasswordNode,
                      nextNode: _confirmPasswordNode,
                      controller: _passwordController,
                      onChanged: (String? value) {
                        if(value != null && value.isNotEmpty){
                          if(!authProvider.showPassView){
                            authProvider.showHidePass();
                          }
                          authProvider.validPassCheck(value);
                        }else{
                          if(authProvider.showPassView){
                            authProvider.showHidePass();
                          }
                        }
                      },
                    )),


                authProvider.showPassView ? const Padding(
                    padding:  EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeSmall),
                    child: PassView()) : const SizedBox(),
                authProvider.showPassView ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

                // for confirm Password
                Container(
                    margin:
                    const EdgeInsets.only(left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge,
                        bottom: Dimensions.paddingSizeLarge),
                    child: CustomPasswordTextFieldWidget(
                      hintTxt: getTranslated('confirm_password', context),
                      textInputAction: TextInputAction.done,
                      focusNode: _confirmPasswordNode,
                      controller: _confirmPasswordController,
                    )),

                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 30),
                  child: Provider.of<AuthController>(context).isLoading
                      ? Center(child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ) : CustomButtonWidget(onTap: resetPassword, btnTxt: getTranslated('reset_password', context)),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
