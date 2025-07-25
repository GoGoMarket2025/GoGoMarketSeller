import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/image_diaglog_widget.dart';
import 'package:sixvalley_vendor_app/data/model/image_full_url.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_screen.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/category_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/product_details/controllers/product_details_controller.dart';
import 'package:sixvalley_vendor_app/features/product_details/enums/preview_type.dart';
import 'package:sixvalley_vendor_app/features/product_details/widgets/audio_preview.dart';
import 'package:sixvalley_vendor_app/features/product_details/widgets/download_preview_file.dart';
import 'package:sixvalley_vendor_app/features/product_details/widgets/image_preview.dart';
import 'package:sixvalley_vendor_app/features/product_details/widgets/pdf_preview_flutter.dart';
import 'package:sixvalley_vendor_app/features/product_details/widgets/video_preview.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/helper/product_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

import '../../../main.dart';

class ProductDetailsWidget extends StatefulWidget {
  final Product? productModel;
  const ProductDetailsWidget({super.key, this.productModel});

  @override
  State<ProductDetailsWidget> createState() => _ProductDetailsWidgetState();
}

class _ProductDetailsWidgetState extends State<ProductDetailsWidget> {

  @override
  Widget build(BuildContext context) {

    return Consumer<CategoryController>(
        builder: (context, categoryProvider,_) {
          String? category = '';
          if(categoryProvider.categoryList != null && categoryProvider.categoryList!.isNotEmpty){
            for(int i=0; i< categoryProvider.categoryList!.length; i++){
              if(widget.productModel!.categoryIds![0].id == categoryProvider.categoryList![i].id.toString()){
                category = categoryProvider.categoryList![i].name;
              }}}

          bool isClearanceSaleActive = widget.productModel?.clearanceSale != null;

          return RefreshIndicator(
            onRefresh: () async{
              Provider.of<ProductDetailsController>(context, listen: false).getProductDetails(widget.productModel!.id);
              Provider.of<CategoryController>(context,listen: false).getCategoryList(context,null, 'en');
            },
            child: Column(children: [
              Expanded(child: SingleChildScrollView(
                child: Column(children: [

                  _ProductWidget(productModel: widget.productModel),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  /// General Information
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                        color: Theme.of(context).primaryColor.withOpacity(0.08),
                      )],
                    ),
                    child: Column(children: [
                      _InformationTitleWidget(title: getTranslated('general_information', context)!),
                      const SizedBox(height: Dimensions.paddingSizeMedium),

                      if( widget.productModel!.productType == 'physical')
                        _InformationElementWidget(labelText: getTranslated('brand', context)!, infoText: widget.productModel?.brand?.name ?? ''),

                      _InformationElementWidget(labelText: getTranslated('category', context)!, infoText: widget.productModel?.category?.name ?? ''),

                      _InformationElementWidget(labelText: getTranslated('product_type', context)!, infoText: widget.productModel?.productType ?? ''),

                      widget.productModel!.productType == 'physical' ?
                      _InformationElementWidget(labelText: getTranslated('product_unit', context)!, infoText: widget.productModel?.unit ?? '') : const SizedBox(),

                      widget.productModel!.productType == 'physical' ?
                      _InformationElementWidget(
                        labelText: getTranslated('current_stock', context)!,
                        infoText: widget.productModel?.currentStock.toString() ?? '',
                      ) : const SizedBox(),

                      _InformationElementWidget(
                        labelText: getTranslated('product_sku', context)!,
                        infoText: widget.productModel?.code ?? '',
                        showDivider: false,
                      ),
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                  /// Price Information
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                        color: Theme.of(context).primaryColor.withOpacity(0.08),
                      )],
                    ),
                    child: Column(children: [
                      _InformationTitleWidget(title: getTranslated('price_information', context)!),
                      const SizedBox(height: Dimensions.paddingSizeMedium),

                      _InformationElementWidget(
                        labelText: getTranslated('unit_price', context)!,
                        infoText: widget.productModel?.unitPrice?.toStringAsFixed(2) ?? '',
                        valueWithSign: true,
                      ),

                      _InformationElementWidget(
                        labelText: getTranslated('tax', context)!,
                        infoText: widget.productModel?.tax?.toStringAsFixed(2) ?? '',
                        isPercentage: true,
                      ),

                      widget.productModel!.productType == 'physical'?
                      _InformationElementWidget(
                        labelText: getTranslated('shipping_cost', context)!,
                        infoText:  PriceConverter.convertPrice(context,  double.tryParse(widget.productModel?.shippingCost.toString() ?? '') ?? 0)  ,
                      ) : const SizedBox(),

                      isClearanceSaleActive ?
                      _InformationElementWidget(
                        labelText: getTranslated('discount', context)!,
                        infoText: widget.productModel!.clearanceSale!.discountType == 'percentage'? widget.productModel!.clearanceSale!.discountAmount.toString() : '0',
                        showDivider: false,
                        isPercentage: widget.productModel!.clearanceSale!.discountType == 'percentage',
                        valueWithSign: widget.productModel!.clearanceSale!.discountType == 'flat',
                      ) :
                      _InformationElementWidget(
                        labelText: getTranslated('discount', context)!,
                        infoText: widget.productModel!.discountType == 'percent'? widget.productModel!.discount.toString() : widget.productModel!.discount.toString(),
                        valueWithSign : widget.productModel!.discountType == 'flat',
                        isPercentage: widget.productModel!.discountType == 'percent',
                        showDivider: false,
                      ),
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  /// Variation
                  if((widget.productModel?.variation?.isNotEmpty ?? false) || (widget.productModel?.digitalVariation?.isNotEmpty ?? false)) ...[
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeMedium).copyWith(bottom: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [BoxShadow(
                          offset: const Offset(0, 3),
                          blurRadius: 8,
                          color: Theme.of(context).primaryColor.withOpacity(0.08),
                        )],
                      ),
                      child: Column(children: [
                        _InformationTitleWidget(title: getTranslated('variation', context)!),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        if((widget.productModel?.variation?.isNotEmpty ?? false))
                          ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index){
                              return _VariationWidget(physicalProduct: widget.productModel!.variation![index], productModel: widget.productModel);
                            },
                            separatorBuilder: (context, index) => Divider(height: 1, color: Theme.of(context).hintColor.withOpacity(0.3), thickness: 1),
                            itemCount: widget.productModel!.variation!.length,
                          ),

                        if((widget.productModel?.digitalVariation?.isNotEmpty ?? false))
                          ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index){
                              return _VariationWidget(digitalProduct: widget.productModel!.digitalVariation![index], productModel: widget.productModel, index: index);
                            },
                            separatorBuilder: (context, index) => Divider(height: 1, color: Theme.of(context).hintColor.withOpacity(0.3), thickness: 1),
                            itemCount: widget.productModel!.digitalVariation!.length,
                          ),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  ],


                  /// Description
                  (widget.productModel?.details != null && widget.productModel!.details!.isNotEmpty) ?
                  Container(
                    padding: const EdgeInsets.only(top: Dimensions.paddingSizeMedium),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                        color: Theme.of(context).primaryColor.withOpacity(0.08),
                      )],
                    ),
                    child: Column(children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                        child: _InformationTitleWidget(title: getTranslated('description', context)!),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                        child: Html(
                          data: widget.productModel?.details ?? '',
                          style: {
                            "body": Style(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: FontSize.medium,
                            ),
                            "table": Style(
                              backgroundColor: const Color.fromARGB(0x50, 0xee, 0xee, 0xee),
                              padding: HtmlPaddings.zero,
                              margin: Margins.zero,
                            ),
                            "tr": Style(
                              border: const Border(bottom: BorderSide(color: Colors.grey)),
                            ),
                            "th": Style(
                              padding: HtmlPaddings.all(6),
                              backgroundColor: Colors.grey,
                              margin: Margins.zero,
                            ),
                            "td": Style(
                              padding: HtmlPaddings.all(6),
                              alignment: Alignment.topLeft,
                              margin: Margins.zero,
                            ),
                            "p": Style(
                              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.80),
                              fontSize: FontSize(Dimensions.fontSizeSmall),
                              fontWeight: FontWeight.w400,
                            ),
                          },
                        ),
                      ),
                    ]),
                  ) : const SizedBox(),
                ]),
              )),

              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: ThemeShadow.getShadow(context),
                ),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.fontSizeSmall,vertical: Dimensions.paddingSizeSmall),
                child: CustomButtonWidget(
                  borderRadius: Dimensions.paddingSizeSmall,
                  btnTxt: getTranslated('edit_product', context),
                  backgroundColor: Theme.of(context).primaryColor,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> AddProductScreen(product: widget.productModel))),
                ),
              ),
            ]),
          );
        }
    );
  }
}

class _InformationTitleWidget extends StatelessWidget {
  final String title;
  final TextStyle? titleTextStyle;
  final Color? backgroundColor;
  const _InformationTitleWidget({
    super.key,
    required this.title,
    this.titleTextStyle,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final double widthSize = MediaQuery.sizeOf(context).width;
    return Container(
      width: widthSize,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
      color: Theme.of(context).primaryColor.withOpacity(0.125),
      child: Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
    );
  }
}

class _InformationElementWidget extends StatelessWidget {
  final String labelText;
  final String infoText;
  final int labelFlex;
  final int infoFlex;
  final TextStyle? labelTextStyle;
  final TextStyle? infoTextStyle;
  final bool showDivider;
  final bool valueWithSign;
  final bool isPercentage;

  const _InformationElementWidget({
    super.key,
    required this.labelText,
    required this.infoText,
    this.labelFlex = 1,
    this.infoFlex = 1,
    this.labelTextStyle,
    this.infoTextStyle,
    this.showDivider = true,
    this.valueWithSign = false,
    this.isPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(flex: labelFlex, child: Text(labelText, style: labelTextStyle ?? robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.80),
        ), overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.start)),

        Expanded(flex: infoFlex, child: valueWithSign ?
        Text(PriceConverter.convertPrice(context, double.tryParse(infoText) ?? 0), style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.80),
        )) :
        Text('$infoText${isPercentage ? "%" : ''}', style: infoTextStyle ?? robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.80),
        ), overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.start)),

      ]),

      if(showDivider) ...[
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Divider(height: 1, color: Theme.of(context).hintColor.withOpacity(0.3), thickness: 1),
        const SizedBox(height: Dimensions.paddingSizeSmall),
      ]


    ]);
  }
}

class _ProductWidget extends StatelessWidget {
  final Product? productModel;
  const _ProductWidget({ this.productModel});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(
          offset: const Offset(0, 3),
          blurRadius: 8,
          color: Theme.of(context).primaryColor.withOpacity(0.08),
        )],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Column(children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.paddingEye),
                  border: Border.all(color: Colors.black.withOpacity(0.05), width: 1)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.paddingEye),
                child: CustomImageWidget(image: '${productModel?.thumbnailFullUrl?.path}', height: 120, width: 120),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            (productModel?.productType == 'digital' && productModel?.previewFileFullUrl != null && productModel?.previewFileFullUrl?.path != '') ? InkWell(
              onTap: () => _showPreview(productModel?.previewFileFullUrl?.path ?? '', productModel?.name ?? '', productModel?.previewFileFullUrl?.key ?? '', context),
              child: Text(
                getTranslated('see_preview', context)!,
                style: robotoRegular.copyWith(
                  color: Colors.transparent,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).primaryColor,
                  shadows: [Shadow(
                    color: Theme.of(context).primaryColor,
                    offset: const Offset(0, -5),
                  )],
                ),
              ),
            ) : const SizedBox(),
          ]),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Expanded(
                  child: Text(productModel!.name ?? '', style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color
                  ), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),


                if(productModel?.digitalProductType == 'ready_product' && productModel?.digitalFileReady != null && (productModel!.digitalVariation == null || productModel!.digitalVariation!.isEmpty))
                  Consumer<OrderDetailsController>(
                      builder: (context, orderDetails, _) {
                        return InkWell(
                          onTap: () {
                            _downloadProduct(1, productModel!.digitalFileReadyFullUrl!);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.15)),
                            ),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child:  (orderDetails.isDownloadLoading &&  orderDetails.downloadIndex == 1)  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()) :
                            Image.asset(Images.downloadIcon, height: 15, width: 15),
                          ),
                        );
                      }
                  ),
              ],
            ),

            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            /// Product Price
            Row(children: [
              Text(
                PriceConverter.convertPrice(context, productModel!.unitPrice,
                    discountType: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                        ? productModel?.clearanceSale?.discountType
                        : productModel?.discountType,
                    discount: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                        ? productModel?.clearanceSale?.discountAmount
                        : productModel?.discount
                ),
                style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              (productModel!.discount! > 0 || (productModel?.clearanceSale?.discountAmount ?? 0) > 0) ?
              Text(PriceConverter.convertPrice(context, productModel!.unitPrice),
                maxLines: 1,overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error,
                  decoration: TextDecoration.lineThrough,
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ) : const SizedBox.shrink(),

            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeVeryTiny),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeOrder),
                color: productModel!.requestStatus == 0?
                Theme.of(context).colorScheme.outline.withOpacity(0.2) :
                productModel!.requestStatus == 1 ? Theme.of(context).colorScheme.onTertiaryContainer.withOpacity(0.2) :
                Theme.of(context).colorScheme.error.withOpacity(0.2),
              ),
              child: Text(productModel!.requestStatus == 0 ? '${getTranslated('new_request', context)}' :
              productModel!.requestStatus == 1? '${getTranslated('approved', context)}' : '${getTranslated('denied', context)}',
                  style: robotoRegular.copyWith(
                      color: productModel!.requestStatus == 0 ?
                      Theme.of(context).colorScheme.outline : productModel!.requestStatus == 1
                          ? Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).colorScheme.error,
                      fontSize: Dimensions.fontSizeSmall
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: Dimensions.paddingEye),

            productModel!.imagesFullUrl != null ?
            SizedBox(height: Dimensions.paddingSizeRevenueBottom, child: ListView.builder(
                itemCount: productModel!.imagesFullUrl?.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index){
                  return GestureDetector(
                    onTap: (){
                      showDialog(context: context, builder: (_){
                        return ImageDialogWidget(imageUrl: '${productModel!.imagesFullUrl![index].path}');
                      });
                    },
                    child: _ProductImageWidget(productModel: productModel, index: index),
                  );
                })) : const SizedBox(),
          ]))
        ]),
      ]),
    );
  }

  void _downloadProduct (int index,  ImageFullUrl digitalProduct) {
    String url = digitalProduct.path ?? '';

    String filename = digitalProduct.key ?? '';

    Provider.of<OrderDetailsController>(Get.context!, listen: false).productDownload(
        url: url,
        fileName: filename,
        index: index
    );
  }

}

class _ProductImageWidget extends StatelessWidget {
  const _ProductImageWidget({
    required this.productModel, required this.index,
  });

  final Product? productModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
      child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.paddingEye),
              border: Border.all(color: Colors.black.withOpacity(0.05), width: 1)
          ),
          width: Dimensions.paddingSizeRevenueBottom,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
            child: CustomImageWidget(
              image: '${productModel!.imagesFullUrl![index].path}',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          )),
    );
  }
}

void _showPreview(String url, String productName, String fileName, BuildContext context) {
  PreviewType type = ProductHelper.getFileType(url);

  showDialog(context: context, builder: (BuildContext context){
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      insetPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: (type == PreviewType.pdf) ?
      PdfPreview(url: url, fileName: productName) : (type == PreviewType.image) ?
      ImagePreview(url: url, fileName: productName) : (type == PreviewType.video) ?
      VideoPreview(url: url, fileName: productName) : (type == PreviewType.audio)  ?
      AudioPreview(url: url, fileName: productName) : (type == PreviewType.others) ?
      DownloadPreview(url: url, fileName: fileName) :
      const SizedBox(),
    );
  });
}

class _VariationWidget extends StatefulWidget {
  final Variation? physicalProduct;
  final DigitalVariation? digitalProduct;
  final Product? productModel;
  final int? index;

  const _VariationWidget({ this.physicalProduct, this.digitalProduct, this.productModel, this.index});

  @override
  State<_VariationWidget> createState() => _VariationWidgetState();
}

class _VariationWidgetState extends State<_VariationWidget> {


  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      setState((){ });
    });

    FlutterDownloader.registerCallback(downloadCallback);

  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: (widget.physicalProduct != null ) ?
      Column(children: [

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(widget.physicalProduct?.type ?? '', style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color
          ),maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          Text(getTranslated('stock', context)!, style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
          )),
        ]),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(
              PriceConverter.convertPrice(context, widget.physicalProduct?.price),

              style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)
              ),maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          Text(widget.physicalProduct?.qty.toString() ?? '0', style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          )),
        ])
      ]) :
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.digitalProduct?.variantKey ?? '', style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color
          ),maxLines: 1, overflow: TextOverflow.ellipsis),

          if(widget.productModel?.digitalProductType == 'ready_product')...[
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Text(PriceConverter.convertPrice(context, widget.digitalProduct?.price),
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )
            ),
          ]
        ],
        ),


        if(widget.productModel?.digitalProductType != 'ready_product')...[
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Text(PriceConverter.convertPrice(context, widget.digitalProduct?.price),
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )
          ),
        ],


        if(widget.productModel?.digitalProductType == 'ready_product')
          Consumer<OrderDetailsController>(
              builder: (context, orderDetails, _) {
                return InkWell(
                  onTap: () {
                    _downloadProduct(widget.index!, widget.digitalProduct!);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.15)),
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child:  (orderDetails.isDownloadLoading &&  orderDetails.downloadIndex == widget.index)  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()) :
                    Image.asset(Images.downloadIcon, height: 15, width: 15),
                  ),
                );
              }
          ),


      ]),
    );
  }

  void _downloadProduct (int index,  DigitalVariation digitalProduct) {
    String url = digitalProduct.fileFullUrl?.path ?? '';

    String filename = digitalProduct.file ?? '';

    Provider.of<OrderDetailsController>(context, listen: false).productDownload(
        url: url,
        fileName: filename,
        index: index
    );
  }

}