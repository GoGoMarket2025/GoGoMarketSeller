import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/profile_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/widgets/theme_changer_widget.dart';



class ProfileScreenView extends StatefulWidget {
  const ProfileScreenView({super.key});

  @override
  ProfileScreenViewState createState() => ProfileScreenViewState();
}

class ProfileScreenViewState extends State<ProfileScreenView> {



  @override
  void initState() {
    super.initState();
    if(Provider.of<ProfileController>(context, listen: false).userInfoModel == null) {
      Provider.of<ProfileController>(context, listen: false).getSellerInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(isBackButtonExist: true,title: getTranslated('my_profile', context)),
      body: Consumer<ProfileController>(
        builder: (context, profile, child) {

          return SingleChildScrollView(
            child: Column(children: [
                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Stack(children: [
                    Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeMedium, left: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall),
                      child: Container(height: 120,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)
                        ),child: Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                          child: Row(children: [
                            Padding(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall, 0, Dimensions.paddingSizeSmall, 0),
                              child: Container(
                                width: 60,height: 60,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).highlightColor,
                                  border: Border.all(color: Colors.white, width: 3),
                                  shape: BoxShape.circle,),
                                child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(50)),
                                  child: CustomImageWidget(width: 60, height: 60,
                                    image: '${profile.userInfoModel!.imageFullUrl?.path}',fit: BoxFit.cover,),
                                ),
                              ),
                            ),


                            Padding(padding: const EdgeInsets.fromLTRB( Dimensions.paddingSizeSmall, 0, Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('${profile.userInfoModel!.fName} ${profile.userInfoModel!.lName ?? ''}',
                                    maxLines: 2,textAlign: TextAlign.center,
                                    style: robotoBold.copyWith(color:  Theme.of(context).colorScheme.secondaryContainer,
                                        fontSize: Dimensions.fontSizeExtraLarge),),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                  Text('${profile.userInfoModel!.phone}',
                                    maxLines: 2,textAlign: TextAlign.center,
                                    style: titilliumRegular.copyWith(color:  Theme.of(context).colorScheme.secondaryContainer,
                                        fontSize: Dimensions.fontSizeSmall),),
                                ],
                              ),
                            ),
                          ],),
                        ),),
                    ),


                    Container(height: 135,
                      width: MediaQuery.of(context).size.width/1.3,
                      decoration: BoxDecoration(color: Theme.of(context).cardColor.withValues(alpha:.10),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(Provider.of<LocalizationController>(context, listen: false).isLtr? 0 : MediaQuery.of(context).size.width),
                              bottomRight: Radius.circular(Provider.of<LocalizationController>(context, listen: false).isLtr?MediaQuery.of(context).size.width : 0))),),

                    Align(alignment: Provider.of<LocalizationController>(context, listen: false).isLtr? Alignment.topRight: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                            child: SizedBox(width: Dimensions.iconSizeLarge,
                                child: Image.asset(Images.editProfileIcon)),
                          ),
                        ))
                  ],),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB( Dimensions.paddingSizeMedium,
                       Dimensions.paddingSeven, Dimensions.paddingSizeMedium, Dimensions.paddingSizeMedium),
                  child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [

                    Expanded(child: InfoItem(icon: Images.productIcon, title: 'products',amount: profile.userInfoModel!.productCount.toString())),
                    const SizedBox(width: Dimensions.paddingSizeSmall,),
                    Expanded(child: InfoItem(icon: Images.order, title: 'orders',amount: profile.userInfoModel!.ordersCount.toString())),
                    const SizedBox(width: Dimensions.paddingSizeSmall,),
                    Expanded(child: InfoItem(icon: Images.totalEarnIcon, title: 'withdrawable_balance',amount: profile.userInfoModel!.wallet!.totalEarning.toString(), isMoney: true)),

                  ],),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                  child: ThemeChangerWidget(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault,bottom: Dimensions.paddingSizeExtraLarge),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(getTranslated('app_version', context)!),
                      const Padding(
                        padding: EdgeInsets.only(left: Dimensions.fontSizeExtraSmall),
                        child: Text(AppConstants.appVersion),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final String? icon;
  final String? title;
  final String? amount;
  final bool isMoney;
  const InfoItem({super.key, this.icon, this.title, this.amount, this.isMoney = false});

  @override
  Widget build(BuildContext context) {
    return Container(height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:.05),
              spreadRadius: -3, blurRadius: 12, offset: Offset.fromDirection(0,6))],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: Dimensions.iconSizeExtraLarge,
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(Dimensions.iconSizeExtraLarge)
              ),
              child: Image.asset(icon!, color: Colors.white)),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            child: !isMoney? Text(amount!,
              style: robotoBold.copyWith(color:  Theme.of(context).primaryColor,
                  fontSize: Dimensions.fontSizeLarge),):
            Text('${Provider.of<SplashController>(context, listen: false).myCurrency!.symbol} ${NumberFormat.compact().format(double.parse(amount!))}',
              style: titilliumSemiBold.copyWith(color:  Theme.of(context).primaryColor,
                  fontSize: Dimensions.fontSizeLarge),),
          ),


          Text(getTranslated(title, context)!,
            textAlign: TextAlign.center,
            style: titilliumRegular.copyWith(color:  Theme.of(context).hintColor,
                fontSize: Dimensions.fontSizeDefault),),
        ],),
    );
  }
}
