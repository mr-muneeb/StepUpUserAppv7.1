import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:provider/provider.dart';

import 'footer_view.dart';

class NoDataScreen extends StatelessWidget {
  final bool isSearch;
  final bool isShowButton;
  final String? title;
  final String? subTitle;
  final String? image;
  const NoDataScreen({Key? key,  this.isShowButton = true, this.isSearch = false, this.title, this.image, this.subTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return ResponsiveHelper.isDesktop(context) ? SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: height * 0.7, width: double.infinity, child: NoDataView(
            image: image, title: title, subTitle: subTitle, isShowButton: isShowButton,
          )),
          !isSearch ? const FooterView() : const SizedBox(),
        ],
      ),
    ) : NoDataView(image: image, title: title, subTitle: subTitle, isShowButton: isShowButton);


  }
}

class NoDataView extends StatelessWidget {
  const NoDataView({
    Key? key,
    this.image,
    this.title,
    this.subTitle,
    this.isShowButton = true,
  }) : super(key: key);

  final String? image;
  final String? title;
  final String? subTitle;
  final bool isShowButton;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

          Image.asset(
           image ?? Images.notFound,
            // isOrder ? Images.box : isCart ? Images.shoppingCart : Images.notFound,
            width: height * 0.17, height: height * 0.17,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: height*0.03),

          Text(
            title ?? getTranslated('no_result_found', context) ,
            // title != null ? title! : isOrder ? 'no_order_history'.tr : isCart ? 'empty_shopping_bag'.tr : isProfile ? 'no_address_found'.tr : 'no_result_found'.tr,
            style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: height*0.02),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: height*0.01),

          if(subTitle != null) Text(
            subTitle!,
            // isOrder ? 'buy_something_to_see'.tr : isCart ? 'look_like_you_have_not_added'.tr : '',
            style: poppinsRegular.copyWith(fontSize: height*0.02),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: height*0.01),

         if(isShowButton) SizedBox(height: 40, width: 150, child: CustomButton(
            buttonText: 'lets_shop'.tr,
            onPressed: () {
              Provider.of<SplashProvider>(context, listen: false).setPageIndex(0);
              // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MenuScreen()), (route) => false);
              Navigator.pushNamed(context, RouteHelper.getMainRoute());
            },
          )),

        ]),
      ),
    );
  }
}
