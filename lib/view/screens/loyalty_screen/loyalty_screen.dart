import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/profile_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/wallet_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/base/not_login_screen.dart';
import 'package:flutter_grocery/view/base/title_widget.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/wallet/widget/convert_money_view.dart';
import 'package:flutter_grocery/view/screens/wallet/widget/history_item.dart';
import 'package:flutter_grocery/view/screens/wallet/widget/tab_button_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';


class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({Key? key}) : super(key: key);

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final ScrollController scrollController = ScrollController();
  final bool _isLoggedIn = Provider.of<AuthProvider>(Get.context!, listen: false).isLoggedIn();

  @override
  void initState() {
    super.initState();
    final walletProvide = Provider.of<WalletProvider>(context, listen: false);

    walletProvide.setCurrentTabButton(0, isUpdate: false);

    if(_isLoggedIn){
      Provider.of<ProfileProvider>(Get.context!, listen: false).getUserInfo();
      walletProvide.getLoyaltyTransactionList('1', false, false, isEarning: walletProvide.selectedTabButtonIndex == 1);

      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent
            && walletProvide.transactionList != null
            && !walletProvide.isLoading) {

          int pageSize = (walletProvide.popularPageSize! / 10).ceil();
          if (walletProvide.offset < pageSize) {
            walletProvide.setOffset = walletProvide.offset + 1;
            walletProvide.updatePagination(true);


            walletProvide.getLoyaltyTransactionList(
              walletProvide.offset.toString(), false, false, isEarning: walletProvide.selectedTabButtonIndex == 1,
            );
          }
        }
      });
    }

  }
  @override
  void dispose() {
    super.dispose();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark, // dark text for status bar
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
    ));


    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).primaryColor.withOpacity(0.2),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).cardColor,
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(preferredSize: Size.fromHeight(100), child: WebAppBar())
            : null,

        body: Consumer<ProfileProvider>(builder: (context, profileProvider, _) {
          return configModel.loyaltyPointStatus!? _isLoggedIn ? profileProvider.userInfoModel != null ? SafeArea(
                child: Consumer<WalletProvider>(builder: (context, walletProvider, _) => RefreshIndicator(
                  onRefresh: () async{
                    walletProvider.getLoyaltyTransactionList('1', true, false, isEarning: walletProvider.selectedTabButtonIndex == 1);
                    profileProvider.getUserInfo();
                  },
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(children: [
                      Center(child: Container(
                          width: Dimensions.webScreenWidth,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30), bottomLeft: Radius.circular(30)),
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                          child: Column(
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Image.asset(
                                  Images.loyal, width: 40, height: 40,
                                ),
                                const SizedBox(width: Dimensions.paddingSizeDefault,),

                                CustomDirectionality(child: Text(
                                  '${profileProvider.userInfoModel!.point ?? 0}',
                                  style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeOverLarge),
                                )),

                              ],),
                              const SizedBox(height: Dimensions.paddingSizeDefault,),

                              Text( getTranslated('withdrawable_point', context),
                                style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault,),

                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: tabButtonList.map((tabButtonModel) =>
                                      TabButtonView(tabButtonModel: tabButtonModel,)).toList(),
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge,),

                            ],
                          ),
                        )),

                      SingleChildScrollView(child: Column(children: [
                        SizedBox(width: Dimensions.webScreenWidth, child: Column(
                          children: [

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [


                                if(walletProvider.selectedTabButtonIndex == 0)
                                  const ConvertMoneyView(),

                                if(walletProvider.selectedTabButtonIndex != 0)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                    child: Center(
                                      child: SizedBox(
                                        width: Dimensions.webScreenWidth,
                                        child: Consumer<WalletProvider>(
                                            builder: (context, walletProvider, _) {
                                              return Column(children: [
                                                Column(children: [

                                                  Padding(
                                                    padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge),
                                                    child: TitleWidget(title: getTranslated(
                                                      walletProvider.selectedTabButtonIndex == 0
                                                          ? 'enters_point_amount' : walletProvider.selectedTabButtonIndex == 1
                                                          ? 'point_earning_history' : 'point_converted_history', context,

                                                    )),
                                                  ),
                                                  walletProvider.transactionList != null ? walletProvider.transactionList!.isNotEmpty ? GridView.builder(
                                                    key: UniqueKey(),
                                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisSpacing: 50,
                                                      mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
                                                      childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4,
                                                      crossAxisCount: ResponsiveHelper.isMobile() ? 1 : 2,
                                                    ),
                                                    physics:  const NeverScrollableScrollPhysics(),
                                                    shrinkWrap:  true,
                                                    itemCount: walletProvider.transactionList!.length ,
                                                    padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
                                                    itemBuilder: (context, index) {
                                                      return HistoryItem(
                                                        index: index,formEarning: walletProvider.selectedTabButtonIndex == 1,
                                                        data: walletProvider.transactionList,
                                                      );
                                                    },
                                                  ) : const NoDataScreen(isSearch: true) : WalletShimmer(walletProvider: walletProvider),

                                                  walletProvider.paginationLoader ? Center(child: Padding(
                                                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                    child: CustomLoader(color: Theme.of(context).primaryColor),
                                                  )) : const SizedBox(),
                                                ])
                                              ]);
                                            }
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),),

                        if(ResponsiveHelper.isDesktop(context))  const SizedBox(height: Dimensions.paddingSizeDefault),

                        if(ResponsiveHelper.isDesktop(context))  const FooterView(),
                      ])),
                    ]),
                  ),
                )),
              ) : Center(child: CustomLoader(color: Theme.of(context).primaryColor)) : const NotLoggedInScreen() : const NoDataScreen();
        }),
      ),
    );
  }
}


class TabButtonModel{
  final String? buttonText;
  final String buttonIcon;
  final Function onTap;

  TabButtonModel(this.buttonText, this.buttonIcon, this.onTap);


}

class WalletShimmer extends StatelessWidget {
  final WalletProvider walletProvider;
  const WalletShimmer({Key? key, required this.walletProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 50,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 4.6 : 3.5,
        crossAxisCount: ResponsiveHelper.isMobile() ? 1 : 2,
      ),
      physics:  const NeverScrollableScrollPhysics(),
      shrinkWrap:  true,
      itemCount: 10,
      padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.08))
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: walletProvider.transactionList == null,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 10, width: 20, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),

                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(height: 12, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                ],
              ),
              Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault), child: Divider(color: Theme.of(context).disabledColor)),
            ],
            ),
          ),
        );
      },
    );
  }
}