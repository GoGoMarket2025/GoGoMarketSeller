import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/features/chat/controllers/chat_controller.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';

class ChatShimmerWidget extends StatelessWidget {
  const ChatShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      shrinkWrap: true,
      reverse: true,
      itemBuilder: (context, index) {
        bool isMe = index % 2 == 0;

        return Shimmer.fromColors(
          baseColor: isMe ? Colors.grey[300]! : ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.titleMedium!.color!, 0.40),
          highlightColor: isMe ? Colors.grey[100]! : ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.titleMedium!.color!, 0.40).withValues(alpha:0.9),
          enabled: Provider.of<ChatController>(context).chatList == null,
          child: Row( mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start, children: [
              isMe ? const SizedBox.shrink() : const InkWell(splashColor: Colors.transparent, child: CircleAvatar(child: Icon(Icons.person))),
              Expanded(
                child: Container(
                  margin: isMe ?  const EdgeInsets.fromLTRB(50, 5, 10, 5) : const EdgeInsets.fromLTRB(10, 5, 50, 5),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(10),
                        bottomLeft: isMe ? const Radius.circular(10) : const Radius.circular(0),
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(10),
                        topRight: const Radius.circular(10),
                      ),
                      color: isMe ? ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.titleMedium!.color!, 0.40): Theme.of(context).colorScheme.secondaryContainer
                  ),
                  child: Container(height: 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}