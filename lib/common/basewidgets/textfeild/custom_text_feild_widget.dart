import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

class CustomTextFieldWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? textInputType;
  final int? maxLine;
  final FocusNode? focusNode;
  final FocusNode? nextNode;
  final TextInputAction? textInputAction;
  final bool isPhoneNumber;
  final bool isValidator;
  final String? validatorMessage;
  final Color? fillColor;
  final TextCapitalization capitalization;
  final bool isAmount;
  final bool isFullNumber;
  final bool amountIcon;
  final bool border;
  final bool isDescription;
  final bool idDate;
  final bool isPassword;
  final Function(String text)? onChanged;
  final Function(String text)? onFieldSubmit;
  final String? prefixIconImage;
  final String? suffixIconImage;
  final bool isPos;
  final int? maxSize;
  final bool variant;
  final bool focusBorder;
  final bool showBorder;
  final Color borderColor;
  final bool required;
  final bool formProduct;
  final List<TextInputFormatter>? inputFormatters;
  final double focusedBorderRadius;
  final bool readOnly;

  const CustomTextFieldWidget(
      {super.key, this.controller,
        this.hintText,
        this.textInputType,
        this.maxLine,
        this.focusNode,
        this.nextNode,
        this.textInputAction,
        this.isPhoneNumber = false,
        this.isValidator=false,
        this.validatorMessage,
        this.capitalization = TextCapitalization.none,
        this.fillColor,
        this.isAmount = false,
        this.isFullNumber = false,
        this.amountIcon = false,
        this.border = false,
        this.isDescription = false,
        this.onChanged,
        this.onFieldSubmit,
        this.idDate = false,
        this.prefixIconImage,
        this.suffixIconImage,
        this.isPassword = false,
        this.isPos = false,
        this.maxSize,
        this.variant = false,
        this.focusBorder = true,
        this.showBorder = false,
        this.borderColor = const Color(0x261455AC),
        this.required = false,
        this.formProduct = false,
        this.inputFormatters,
        this.focusedBorderRadius = 8,
        this.readOnly = false
      });

  @override
  State<CustomTextFieldWidget> createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  bool _obscureText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  @override
  Widget build(context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        //border : !widget.formProduct ? widget.border? Border.all(width: 1, color: Theme.of(context).hintColor.withValues(alpha:.35)):null : null,
        color: Theme.of(context).highlightColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        readOnly: widget.readOnly,
        controller: widget.controller,
        maxLines: widget.maxLine ?? 1,
        textCapitalization: widget.capitalization,
        maxLength: widget. maxSize ?? (widget.isPhoneNumber ? 15 : null),
        focusNode: widget.focusNode,
        initialValue: null,
        obscureText: widget.isPassword?_obscureText: false,
        onChanged: widget.onChanged,
        enabled: widget.idDate ? false : true,
        inputFormatters: widget.inputFormatters ?? ((widget.textInputType == TextInputType.phone || widget.isPhoneNumber) ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp('[0-9+]'))]
            : widget.isAmount ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : widget.isFullNumber ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]  : null),
        keyboardType: widget.isAmount ? TextInputType.number : widget.textInputType ?? TextInputType.text,
        textInputAction: widget.textInputAction ?? TextInputAction.next,
        onFieldSubmitted: widget.onFieldSubmit ?? (v) {
          FocusScope.of(context).requestFocus(widget.nextNode);
        },
        validator: (input){
          if(input!.isEmpty){
            if(widget.isValidator){
              return widget.validatorMessage??"";
            }
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIconConstraints: BoxConstraints(
            minWidth: widget.variant ? 5 : 20,
            minHeight: widget.variant ? 5 : 20,),
          prefixIcon: widget.prefixIconImage != null ?
          Padding(padding: EdgeInsets.fromLTRB(Provider.of<LocalizationController>(context, listen: false).isLtr? 0 :
          Dimensions.paddingSizeSmall , 0, Provider.of<LocalizationController>(context, listen: false).isLtr?Dimensions.paddingSizeSmall:0,0),
            child: Container(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall+3),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha:.135)),
            child: Image.asset(widget.prefixIconImage!,width: 20, height: 20))) : const SizedBox(),
          suffixIconConstraints:  BoxConstraints(minWidth:widget.variant ? 5 : widget.isPos ? 0 : 40,
            minHeight:widget.variant ? 5 : 20),

          suffixIcon: widget.suffixIconImage != null ?
          Padding(padding: EdgeInsets.fromLTRB(
            Provider.of<LocalizationController>(context, listen: false).isLtr ? 0 : Dimensions.paddingSizeSmall, 0,
            Provider.of<LocalizationController>(context, listen: false).isLtr ? Dimensions.paddingSizeSmall : 0, 0),
            child: Container(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall+3),
              child: Image.asset(widget.suffixIconImage!, width: 20, height: 20))
          ) :

          widget.isPassword? GestureDetector(onTap: _toggle,
            child: Icon(_obscureText ? Icons.visibility_off : Icons.visibility)):const SizedBox.shrink(),
          hintText: widget.hintText ?? '',
          focusedBorder: widget.focusBorder ? OutlineInputBorder(
              borderSide: BorderSide(color: widget.borderColor.withValues(alpha: 1)),
              borderRadius: BorderRadius.circular(widget.focusedBorderRadius),
          ) : null,
          disabledBorder: widget.border ? OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: widget.borderColor,
                width: widget.showBorder ? 0 : .75,)) : null,



          // OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          //   borderSide: BorderSide(color: Theme.of(context).primaryColor,//widget.borderColor,
          //   width: widget.showBorder ? 0 : .75,)),


          filled: widget.fillColor != null,
          fillColor: widget.fillColor,
          isDense: true,
          contentPadding:  EdgeInsets.symmetric(vertical: 12.0, horizontal:widget.variant ? 0 : 10),
          alignLabelWithHint: true,
          counterText: '',
          hintStyle: titilliumRegular.copyWith(color: widget.idDate ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor),
          errorStyle: const TextStyle(height: 1.5),
          border: widget.formProduct ? InputBorder.none : widget.border ?
          OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.borderColor,
                width: widget.showBorder ? 0 : .75,
              ),
          ) : InputBorder.none,


          enabledBorder: widget.border ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: widget.borderColor,
              width: widget.showBorder ? 0 : .75,
            ),
          ) : null,



          labelStyle: titilliumRegular.copyWith(color: widget.idDate ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor),


          label: widget.formProduct ? Text.rich(TextSpan(children: [
            TextSpan(text: widget.hintText??'', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
            if(widget.required && widget.hintText != null)
              TextSpan(text : ' *', style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeLarge))
          ])) : null,
        ),
      ),
    );
  }
}
