import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/customer_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/cart_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/review/controllers/product_review_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_container_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_date_picker_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_drop_down_item_widget.dart';
import 'package:sixvalley_vendor_app/features/pos/screens/customer_search_screen.dart';
import 'package:sixvalley_vendor_app/features/review/widgets/review_product_filter_widget.dart';


class ReviewFilterBottomSheetWidget extends StatefulWidget {
  const ReviewFilterBottomSheetWidget({super.key});

  @override
  State<ReviewFilterBottomSheetWidget> createState() => _ReviewFilterBottomSheetWidgetState();
}

class _ReviewFilterBottomSheetWidgetState extends State<ReviewFilterBottomSheetWidget> {

  @override
  void initState() {
    Provider.of<ProductReviewController>(Get.context!,listen: false).setAllFieldSelected(true);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Consumer<ProductReviewController>(
        builder: (context, reviewProvider,_) {
          return Consumer<ProductController>(
            builder: (context, productProvider,_) {
              return Container(decoration: BoxDecoration(color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.paddingSizeDefault),
                      topRight: Radius.circular(Dimensions.paddingSizeDefault))),

                child: Column(mainAxisSize: MainAxisSize.min, children: [

                    Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault,
                      top: Dimensions.paddingSizeExtraLarge,),
                      child: Text(getTranslated('filter_date', context)!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),),),

                    if(productProvider.sellerProductModel != null && productProvider.sellerProductModel!.products != null && productProvider.sellerProductModel!.products!.isNotEmpty)

                  Consumer<ProductReviewController>(
                    builder: (context,productReviewController,_){
                      return CustomContainerWidget(title: productReviewController.selectedProductName, onTap: (){
                        showDialog(context: context, barrierDismissible: true,
                            builder: (_) => const ReviewProductFilterWidget());
                      });
                    },
                  ),

                  Consumer<CartController>(
                    builder: (context,cartController,_) {
                      return InkWell(
                          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const CustomerSearchScreen())),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                            child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                              child: Container(width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border.all(width: .25, color: Theme.of(context).hintColor.withValues(alpha:.75)),
                                      color: Theme.of(context).cardColor,
                                      boxShadow: ThemeShadow.getShadow(context),
                                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
                                  ),
                                  child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSize),
                                    child: Row(children: [
                                        Expanded(child: Text(cartController.searchCustomerController.text.trim().isNotEmpty?
                                        cartController.searchCustomerController.text: '${getTranslated('select_customer', context)}',
                                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),
                                      const Icon(Icons.arrow_drop_down_sharp)
                                      ],
                                    ),
                                  )),
                            ),
                          ));
                    }
                  ),


                    CustomDropDownItemWidget(
                      widget: DropdownButtonFormField<String>(
                        value: reviewProvider.reviewStatusName,
                        isExpanded: true,
                        decoration: const InputDecoration(border: InputBorder.none),
                        iconSize: 24, elevation: 16, style: robotoRegular,
                        onChanged: (value){
                          reviewProvider.setReviewStatusIndex(value == 'select_status'?0: value == 'active'? 1:2);
                        },
                        items: reviewProvider.reviewStatusList.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(getTranslated(value, context)!,
                                style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                          );
                        }).toList(),
                      ),
                    ),

                    Row(children: [
                      Expanded(child: CustomDatePickerWidget(
                        title: getTranslated('from', context),
                        image: Images.calenderIcon,
                        text: reviewProvider.startDate != null ?
                        reviewProvider.dateFormat.format(reviewProvider.startDate!).toString() : getTranslated('select_date', context),
                        selectDate: () => reviewProvider.selectDate("start", context),
                      )),
                      Expanded(child: CustomDatePickerWidget(
                        title: getTranslated('to', context),
                        image: Images.calenderIcon,
                        text: reviewProvider.endDate != null ?
                        reviewProvider.dateFormat.format(reviewProvider.endDate!).toString() : getTranslated('select_date', context),
                        selectDate: () => reviewProvider.selectDate("end", context),
                      )),
                    ],),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    !reviewProvider.allFieldSelected ?
                      Text(getTranslated('select_all_fields', context)!,
                        style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).colorScheme.error)) : const SizedBox(),

                    //const SizedBox(height: Dimensions.paddingSizeDefault),
                    Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: CustomButtonWidget(btnTxt: getTranslated('search', context),
                      onTap: () {
                        if(reviewProvider.startDate == null || reviewProvider.endDate == null || reviewProvider.reviewStatusIndex == 0 || Provider.of<CustomerController>(context, listen: false).customerId == 0 || Provider.of<ProductReviewController>(context, listen: false).selectedProductId == 0) {
                          reviewProvider.setAllFieldSelected(false);
                        } else{
                          reviewProvider.setAllFieldSelected(true);
                          int?  productId = Provider.of<ProductReviewController>(context, listen: false).selectedProductId;
                          int?  customerId = Provider.of<CustomerController>(context, listen: false).customerId;
                          reviewProvider.filterReviewList(context, productId, customerId);
                        }
                      }),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault,),

              ],),);
            }
          );
        }
      ),
    );
  }
}

