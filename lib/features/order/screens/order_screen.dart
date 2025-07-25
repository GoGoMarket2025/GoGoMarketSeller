 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/home/widgets/order_widget.dart';

class OrderScreen extends StatefulWidget {
  final bool isBacButtonExist;
  final bool fromHome;
  const OrderScreen({super.key, this.isBacButtonExist = false, this.fromHome = false});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {

  ScrollController scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: CustomAppBarWidget(title: getTranslated('my_order', context), isBackButtonExist: widget.isBacButtonExist),
      body: Consumer<OrderController>(builder: (context, order, child) {
        List<Order>? orderList = [];
        orderList = order.orderModel?.orders;
        return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
              child: SizedBox(
                height: 40,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: [
                    OrderTypeButton(text: getTranslated('all', context), index: 0, ),
                    const SizedBox(width: 5),
                    OrderTypeButton(text: getTranslated('pending', context), index: 1),
                    const SizedBox(width: 5),
                    OrderTypeButton(text: getTranslated('processing', context), index: 2),
                    const SizedBox(width: 5),
                    OrderTypeButton(text: getTranslated('delivered', context), index: 3),
                    const SizedBox(width: 5),
                    OrderTypeButton(text: getTranslated('return', context), index: 4),
                    const SizedBox(width: 5),
                    OrderTypeButton(text: getTranslated('failed', context), index: 5),
                    const SizedBox(width: 5),
                    OrderTypeButton(text: getTranslated('cancelled', context), index: 6),
                    const SizedBox(width: 5),
                    OrderTypeButton(text: getTranslated('confirmed', context), index: 7),
                    const SizedBox(width: 5),
                    OrderTypeButton(text: getTranslated('out_for_delivery', context), index: 8),
                  ],
                ),
              ),
            ),
            order.orderModel != null ? orderList!.isNotEmpty ?

            Expanded(child: RefreshIndicator(
                onRefresh: () async {
                  await order.getOrderList(context,1, order.orderType);
                },
                child:SingleChildScrollView(
                  controller: scrollController,
                  child: PaginatedListViewWidget(
                    reverse: false,
                    scrollController: scrollController,
                    totalSize: order.orderModel?.totalSize,
                    offset: order.orderModel != null ? int.parse(order.orderModel!.offset.toString()) : null,
                    onPaginate: (int? offset) async {
                      await order.getOrderList( context,offset!,order.orderType, reload: false);
                    },

                    itemView: ListView.builder(
                      itemCount: orderList.length,
                      padding: const EdgeInsets.all(0),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return OrderWidget(orderModel: orderList![index], index: index,);
                      },
                    ),
                  ),
                ),
              ),
            ) : const Expanded(child: NoDataScreen(title: 'no_order_found',)) : const Expanded(child: OrderShimmer()),
          ],
        );
      },
      ),
    );
  }
}

class OrderShimmer extends StatelessWidget {
  const OrderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      padding: const EdgeInsets.all(0),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          color: Theme.of(context).highlightColor,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10, width: 150, color: Theme.of(context).colorScheme.secondaryContainer),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: Container(height: 45, color: Theme.of(context).colorScheme.secondaryContainer)),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Container(height: 20, color: Theme.of(context).colorScheme.secondaryContainer),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(height: 10, width: 70, color: Theme.of(context).colorScheme.secondaryContainer),
                              const SizedBox(width: 10),
                              Container(height: 10, width: 20, color: Theme.of(context).colorScheme.secondaryContainer),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OrderTypeButton extends StatelessWidget {
  final String? text;
  final int index;

  const OrderTypeButton({super.key, required this.text, required this.index});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
          Provider.of<OrderController>(context, listen: false).setIndex(context, index);
        },
        child: Consumer<OrderController>(builder: (context, order, child) {
          return Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge,),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: order.orderTypeIndex == index ? Theme.of(context).primaryColor : Provider.of<ThemeController>(context).darkTheme ?
              ColorHelper.blendColors(Colors.white, Theme.of(context).highlightColor, 0.9) :
              Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
            ),
            child: Text(text!, style: order.orderTypeIndex == index ? titilliumBold.copyWith(color: order.orderTypeIndex == index
                    ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).textTheme.bodyLarge?.color):
                robotoRegular.copyWith(color: order.orderTypeIndex == index
                ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).textTheme.bodyLarge?.color)),
          );
        },
        ),
      ),
    );
  }
}
