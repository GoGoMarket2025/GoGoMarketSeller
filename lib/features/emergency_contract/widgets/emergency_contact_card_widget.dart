import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/emergency_contract/domain/models/emergency_contact_model.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/emergency_contract/controllers/emergency_contact_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/features/emergency_contract/widgets/add_emergency_contact_widget.dart';
import 'package:url_launcher/url_launcher.dart';


class EmergencyContactCardWidget extends StatelessWidget {
  final ContactList? contactList;
  final int? index;
  const EmergencyContactCardWidget({super.key, this.contactList, this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmergencyContactController>(
      builder: (context, emergencyContactProvider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeExtraSmall,0,Dimensions.paddingSizeExtraSmall,Dimensions.paddingSizeMedium),
          child: Slidable(
            key: const ValueKey(0),

            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              dragDismissible: false,
              children:  [
                SlidableAction(
                  onPressed: (value){
                    emergencyContactProvider.deleteEmergencyContact(context, contactList!.id);
                  },
                  backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha:.05),
                  foregroundColor: Theme.of(context).colorScheme.error,
                  icon: Icons.delete_forever_rounded,
                  label: getTranslated('delete', context),
                ),
                SlidableAction(
                  onPressed: (value){
                    showDialog(context: context, builder: (_){
                      return AddEmergencyContactWidget(index: index, contactList: contactList,);});
                  },
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha:.05),
                  foregroundColor: Theme.of(context).primaryColor,
                  icon: Icons.edit,
                  label: getTranslated('edit', context),
                ),
              ],
            ),
            // The end action pane is the one at the right or the bottom side.
            endActionPane: ActionPane(

              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (value){
                    emergencyContactProvider.deleteEmergencyContact(context, contactList!.id);
                  },
                  backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha:.05),
                  foregroundColor: Theme.of(context).colorScheme.error,
                  icon: Icons.delete_forever_rounded,
                  label: getTranslated('delete', context),

                ),
                SlidableAction(
                  onPressed: (value){
                    showDialog(context: context, builder: (_){
                      return AddEmergencyContactWidget(index: index, contactList: contactList,);});
                  },
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha:.05),
                  foregroundColor: Theme.of(context).primaryColor,
                  icon: Icons.edit,
                  label: getTranslated('edit', context),
                ),
              ],
            ),

            child: Stack(
              children: [
                Container(padding: const EdgeInsets.symmetric(vertical:Dimensions.paddingSizeMedium),
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                      boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:.05), blurRadius: 1,spreadRadius: 1,offset: const Offset(1,2))]),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: SizedBox(width: Dimensions.iconSizeExtraLarge,
                            child: Image.asset(Images.eCall))),

                      Expanded(
                        child: Column(children: [
                          Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(contactList!.name ?? '', style: robotoRegular.copyWith(
                                        color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),fontSize: Dimensions.fontSizeDefault),
                                        maxLines: 2, overflow: TextOverflow.ellipsis),

                                  ),

                                  const SizedBox(width: 100)
                                ],
                              ),

                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              InkWell(
                                onTap: () {
                                  _launchUrl(Platform.isIOS? 'tel://${contactList!.phone!}' : 'tel:${contactList!.phone!}');
                                },
                                child: Container(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),

                                  child: Text(contactList!.phone ?? '',
                                    style: robotoRegular.copyWith(color: Theme.of(context).cardColor),),
                                ),
                              )

                            ],),
                          ),
                        ],),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Row(mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Consumer<EmergencyContactController>(
                          builder: (context, emergencyContactProvider, _) {
                            return FlutterSwitch(value: contactList!.status == 1, activeColor: Theme.of(context).primaryColor,
                              width: 48,height: 25,toggleSize: 20,padding: 2,onToggle: (value){
                              emergencyContactProvider.statusOnOffEmergencyContact(context, contactList!.id, value ? 1 : 0, index);
                              },);
                          }
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }
}

Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}
