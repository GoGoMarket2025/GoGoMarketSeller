import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/pos/domain/models/cart_model.dart';
import 'package:sixvalley_vendor_app/features/pos/domain/models/temporary_cart_for_customer_model.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/cart_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';

class CartBottomSheetWidget extends StatefulWidget {
  final Product? product;
  final Function? callback;
  const CartBottomSheetWidget({super.key, required this.product, this.callback});

  @override
  CartBottomSheetWidgetState createState() => CartBottomSheetWidgetState();
}

class CartBottomSheetWidgetState extends State<CartBottomSheetWidget> {

  Future<void> route(bool isRoute, String message) async {
    if (isRoute) {
      showCustomSnackBarWidget(message, context, isError: false);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      showCustomSnackBarWidget(message, context);
    }
  }

  int qty = 0;
  bool isNotSetQty = true;

  @override
  void initState() {
    Provider.of<ProductController>(context, listen: false).initData(widget.product!,widget.product!.minimumOrderQty, context);
    Provider.of<ProductController>(context, listen: false).initDigitalVariationIndex();
    Provider.of<ProductController>(context, listen: false).updateQuantity(true, isUpdate: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).highlightColor,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
          ),
          child: Consumer<CartController>(
              builder: (ctx, cartController, child) {
              return Consumer<ProductController>(
                builder: (ctx, productProvider, child) {
                  List<String> variationFileType = [];
                  List<List<String>> extentions = [];
                  String? variantKey;

                  Variation? variationModel;
                  String? variantName = widget.product!.colors!.isNotEmpty ? widget.product!.colors![productProvider.variantIndex!].name : null;
                  List<String> variationList = [];
                  for(int index=0; index < widget.product!.choiceOptions!.length; index++) {
                    variationList.add(widget.product!.choiceOptions![index].options![productProvider.variationIndex![index]].trim());

                  }
                  String variationType = '';
                  if(variantName != null) {
                    variationType = variantName;
                    for (var variation in variationList) {
                      variationType = '$variationType-$variation';
                    }
                  }else {

                    bool isFirst = true;
                    for (var variation in variationList) {
                      if(isFirst) {
                        variationType = '$variationType$variation';
                        isFirst = false;
                      }else {
                        variationType = '$variationType-$variation';
                      }
                    }
                  }

                  if(widget.product?.digitalProductExtensions != null){
                    widget.product?.digitalProductExtensions?.keys.forEach((key) {
                      variationFileType.add(key);
                      extentions.add(widget.product?.digitalProductExtensions?[key]);
                    }
                    );
                  }

                  double? price = widget.product!.unitPrice;
                  int? stock = widget.product!.currentStock;
                  variationType = variationType.replaceAll(' ', '');
                  for(Variation variation in widget.product!.variation!) {
                    if(variation.type == variationType) {
                      price = variation.price;
                      variationModel = variation;
                      stock = variation.qty;
                      break;
                    }
                  }

                  if(variationFileType.isNotEmpty && extentions.isNotEmpty) {
                      variantKey = '${variationFileType[productProvider.digitalVariationIndex!]}-${extentions[productProvider.digitalVariationIndex!][productProvider.digitalVariationSubindex!]}';
                      for (int i=0; i<widget.product!.digitalVariation!.length; i++) {
                        if(widget.product!.digitalVariation?[i].variantKey == variantKey){
                          price = double.tryParse(widget.product!.digitalVariation![i].price.toString());
                        }
                      }
                  }


                  int isUpdate = getIsExistInCart(cartController.currentCartModel, widget.product!, variationType, variantKey);


                  if(isUpdate != -1 && productProvider.isUpdateQuantity) {

                    productProvider.setQuantity(cartController.currentCartModel?.cart?[isUpdate].quantity ?? 1, isUpdate: false);
                    productProvider.updateQuantity(false, isUpdate : false);
                    isNotSetQty = false;

                  } else if(productProvider.isUpdateQuantity) {

                    // print('---Inside-Else----');
                    // productProvider.setQuantity(1, isUpdate: false);
                    // productProvider.updateQuantity(true, isUpdate : false);
                    // isNotSetQty = false;

                  }


                  double priceWithDiscount = PriceConverter.convertWithDiscount(context, price,
                    widget.product?.clearanceSale != null ?
                    widget.product!.clearanceSale!.discountAmount :
                    widget.product!.discount,

                    widget.product?.clearanceSale != null ?
                    widget.product!.clearanceSale!.discountType :
                    widget.product!.discountType
                  )!;
                  double priceWithQuantity = priceWithDiscount * productProvider.quantity!;

                  double total = 0, avg = 0;
                  for (var review in widget.product!.reviews!) {
                    total += review.rating!;
                  }
                  avg = total /widget.product!.reviews!.length;


                  String ratting = widget.product!.reviews != null && widget.product!.reviews!.isNotEmpty?
                  avg.toString() : "0";







                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    // Close Button
                    Align(alignment: Alignment.centerRight, child: InkWell(
                      splashColor: Colors.transparent,
                      onTap: () => Navigator.pop(context),
                      child: Container(width: 25, height: 25,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).highlightColor, boxShadow: [BoxShadow(
                          color: Provider.of<ThemeController>(context, listen: false).darkTheme ?
                          Theme.of(context).cardColor : Theme.of(context).hintColor,

                          spreadRadius: 1, blurRadius: 5,)]),
                        child: const Icon(Icons.clear, size: Dimensions.iconSizeSmall),
                      ),
                    )),

                    Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Container(width: 100, height: 100,
                            decoration: BoxDecoration(color: Theme.of(context).highlightColor.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(width: .5,color: Theme.of(context).primaryColor.withValues(alpha:.20))),
                            child: ClipRRect(borderRadius: BorderRadius.circular(5),
                                child: CustomImageWidget(image: '${widget.product!.thumbnailFullUrl?.path}')),),
                            const SizedBox(width: Dimensions.paddingSizeDefault),


                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(widget.product!.name ?? '',
                                  style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),

                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              Row(children: [
                                const Icon(Icons.star,color: Colors.orange),
                                Text(double.parse(ratting).toStringAsFixed(1),
                                    style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                              ),
                            ]),
                            ),
                          ]),

                      Row(children: [
                        widget.product!.discount! > 0 || (widget.product?.clearanceSale != null && widget.product!.clearanceSale!.discountAmount! > 0) ?
                        Container(margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color:Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(PriceConverter.percentageCalculation(context, price,
                              widget.product?.clearanceSale != null ?
                              widget.product!.clearanceSale!.discountAmount
                              : widget.product!.discount,

                              widget.product?.clearanceSale != null ?
                              widget.product!.clearanceSale!.discountType :
                              widget.product!.discountType
                            ),
                              style: titilliumRegular.copyWith(color: Theme.of(context).cardColor,
                                  fontSize: Dimensions.fontSizeDefault))),
                        ) : const SizedBox(width: 93),


                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        widget.product!.discount! > 0 || (widget.product?.clearanceSale != null && widget.product!.clearanceSale!.discountAmount! > 0) ?
                        Text(PriceConverter.convertPrice(context, price),
                          style: titilliumRegular.copyWith(color: Theme.of(context).colorScheme.error,
                              decoration: TextDecoration.lineThrough)) : const SizedBox(),

                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Text(PriceConverter.convertPrice(context, price,
                          discountType:
                          widget.product?.clearanceSale != null ?
                          widget.product!.clearanceSale!.discountType :
                          widget.product!.discountType,

                          discount:
                          widget.product?.clearanceSale != null ?
                          widget.product!.clearanceSale!.discountAmount :
                          widget.product!.discount
                        ),
                              style: titilliumRegular.copyWith(color: Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeExtraLarge)),

                      ],
                      ),
                    ],),


                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    widget.product!.colors!.isNotEmpty ?
                    Row( children: [
                      Text('${getTranslated('select_variant', context)} : ',
                          style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          itemCount: widget.product!.colors!.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, index) {
                            String colorString = '0xff${widget.product!.colors![index].code!.substring(1, 7)}';
                            return InkWell(
                              onTap: () {
                                Provider.of<ProductController>(context, listen: false).setCartVariantIndex(widget.product!.minimumOrderQty, index, context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                    border: productProvider.variantIndex == index ? Border.all(width: 1,
                                        color: Theme.of(context).primaryColor):null
                                ),
                                child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),

                                  child: Container(height: Dimensions.topSpace, width: Dimensions.topSpace,
                                    padding: const EdgeInsets.all( Dimensions.paddingSizeExtraSmall),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Color(int.parse(colorString)),
                                      borderRadius: BorderRadius.circular(5),),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ]) : const SizedBox(),
                    widget.product!.colors!.isNotEmpty ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

                    // Variation
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.product!.choiceOptions!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, index) {
                        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Text('${getTranslated('available', context)}  ${widget.product!.choiceOptions![index].title} : ',
                              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),


                          Expanded(
                            child: Padding(padding: const EdgeInsets.all(2.0),
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                  childAspectRatio: (1 / .7),
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: widget.product!.choiceOptions![index].options!.length,
                                itemBuilder: (ctx, i) {
                                  return InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () => Provider.of<ProductController>(context, listen: false).setCartVariationIndex(widget.product!.minimumOrderQty, index, i, context),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: productProvider.variationIndex![index] == i? Theme.of(context).primaryColor: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(5),
                                        border: productProvider.variationIndex![index] != i ?  Border.all(color: Theme.of(context).hintColor,):
                                        Border.all(color: Theme.of(context).primaryColor,),),
                                      child: Center(
                                        child: Text(widget.product!.choiceOptions![index].options![i].trim(), maxLines: 1,
                                            overflow: TextOverflow.ellipsis, style: titilliumRegular.copyWith(
                                              fontSize: Dimensions.fontSizeDefault,
                                              color: productProvider.variationIndex![index] != i ?
                                              Theme.of(context).textTheme.bodyMedium?.color : Colors.white,
                                            )),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ]);
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),


                    // Digital Product Variation
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: variationFileType.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, index) {
                        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Text('${variationFileType[index][0].toUpperCase() + variationFileType[index].substring(1)} : ',
                              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),


                          Expanded(
                            child: Padding(padding: const EdgeInsets.all(2.0),
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                  childAspectRatio: (1 / .5),
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: extentions[index].length,
                                itemBuilder: (ctx, i) {
                                  bool isSelect = (productProvider.digitalVariationIndex == index && productProvider.digitalVariationSubindex == i);
                                  return InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () => Provider.of<ProductController>(context, listen: false).setDigitalVariationIndex(widget.product!.minimumOrderQty, index, i, context),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelect ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withValues(alpha:0.10),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Center(
                                        child: Text(extentions[index][i].trim(), maxLines: 1,
                                          overflow: TextOverflow.ellipsis, style: titilliumRegular.copyWith(
                                            fontSize: Dimensions.fontSizeDefault,
                                            color: isSelect ?  Colors.white : Theme.of(context).primaryColor.withValues(alpha:0.85),
                                          )),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ]);
                      },
                    ),







                    // Quantity
                    Row(children: [
                      Text(getTranslated('quantity', context)!, style: robotoBold),
                      // productProvider.quantity == 1 ? const SizedBox() :
                      QuantityButton( disable: productProvider.quantity == 1 ,  isIncrement: false, quantity: productProvider.quantity,
                        stock: stock, minimumOrderQuantity: 1,
                        digitalProduct: widget.product!.productType == "digital"),

                      Text((productProvider.quantity).toString(), style: titilliumSemiBold),

                      QuantityButton(isIncrement: true, quantity: productProvider.quantity, stock: stock,
                        minimumOrderQuantity: 1,
                        digitalProduct: widget.product!.productType == "digital"),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),


                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(getTranslated('total_price', context)!, style: robotoBold),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text(PriceConverter.convertPrice(context, priceWithQuantity),
                        style: titilliumBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // : getIsExistInCart(cartController.currentCartModel, widget.product) ? ''

                    Consumer<CartController>(
                      builder: (ctx, cartController, child) {
                        return CustomButtonWidget(btnTxt: getTranslated(stock! < widget.product!.minimumOrderQty! && widget.product!.productType == "physical"?
                        'out_of_stock':
                        isUpdate != -1 ? 'update_cart'  : 'add_to_cart', context),

                        onTap: stock < widget.product!.minimumOrderQty!  &&  widget.product!.productType == "physical" ? null : () {
                          double? digitalVariantPrice = variantKey != null ? price : null;
                          if(stock! >= widget.product!.minimumOrderQty!  || widget.product!.productType == "digital") {
                            CartModel cart = CartModel( widget.product!.unitPrice, widget.product!.discount, productProvider.quantity ?? 1, widget.product!.tax, variationModel?.type, variationModel, variantKey, digitalVariantPrice, widget.product, widget.product!.taxModel);
                            Provider.of<CartController>(context, listen: false).addToCart(context, cart, updateToCart: isUpdate != -1);
                            Navigator.pop(context);
                          }
                        });
                      }
                    ),



                    const SizedBox(width: Dimensions.paddingSizeDefault),
                  ]);
                },
              );
            }
          ),
        ),
      ],
    );
  }


  int getIsExistInCart(TemporaryCartListModel? currentCartModel, Product product, String variantKey, String? digitalVariantKey) {
    int index = -1;

    for (int i = 0; i < (currentCartModel?.cart?.length ?? 0); i++) {
      if(currentCartModel?.cart![i].product!.id == product.id && (variantKey == '' && digitalVariantKey == null)) {
        index = i;
        return i;
      } else if (currentCartModel?.cart![i].product!.id == product.id && (variantKey != '' || digitalVariantKey != null))  {
        String cartVariantKey = getVariantKey(currentCartModel!.cart![i]);

        if (cartVariantKey == variantKey || cartVariantKey == digitalVariantKey) {
          index = i;
          return index;
        }
      }
    }

    return index;
  }


  String getVariantKey(CartModel cartModel) {
    String variantKey = '';

    if (cartModel.variant != null && cartModel.variant != '') {
      return cartModel.variant!;
    } else if (cartModel.varientKey != null && cartModel.varientKey != '') {
      return cartModel.varientKey!;
    }
    return variantKey;
  }


}

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final int? quantity;
  final bool isCartWidget;
  final int? stock;
  final int? minimumOrderQuantity;
  final bool digitalProduct;
  final bool disable;

  const QuantityButton({super.key,
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    this.isCartWidget = false,required this.minimumOrderQuantity,required this.digitalProduct,
    this.disable = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: disable ? null :  () {
        if (!isIncrement && quantity! > 1 ) {
          if(quantity! > minimumOrderQuantity! ) {
            Provider.of<ProductController>(context, listen: false).setQuantity(quantity! - 1);
          }else{
            // Fluttertoast.showToast(
            //     msg: '${getTranslated('minimum_quantity_is', context)}$minimumOrderQuantity',
            //     toastLength: Toast.LENGTH_SHORT,
            //     gravity: ToastGravity.BOTTOM,
            //     timeInSecForIosWeb: 1,
            //     backgroundColor: Colors.red,
            //     textColor: Colors.white,
            //     fontSize: 16.0
            // );
          }
        } else if (isIncrement && quantity! < stock! || digitalProduct) {
          Provider.of<ProductController>(context, listen: false).setQuantity(quantity! + 1);

        }
      },
      icon: Container(
        width: 40,height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 1, color: Theme.of(context).primaryColor)
        ),
        child: Icon(
          isIncrement ? Icons.add : Icons.remove,
          color: isIncrement ? quantity! >= stock! && !digitalProduct?
          Provider.of<ThemeController>(context).darkTheme
              ?  Theme.of(context).primaryColor.withValues(alpha: 0.6) : Theme.of(context).primaryColor
              : Theme.of(context).primaryColor
              : quantity! > 1
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodyMedium?.color,
          size: isCartWidget?26:20,
        ),
      ),
    );
  }
}


