import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';



class ImageDialogWidget extends StatelessWidget {
  final String imageUrl;
  const ImageDialogWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).primaryColor.withValues(alpha:0.20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FadeInImage.assetNetwork(
                  placeholder: Images.placeholderImage, image: imageUrl, fit: BoxFit.contain,
                  imageErrorBuilder: (c, o, s) => Image.asset(
                    Images.placeholderImage, height: MediaQuery.of(context).size.width - 130,
                    width: MediaQuery.of(context).size.width, fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

          ],
        ),
      ),
    );
  }
}
