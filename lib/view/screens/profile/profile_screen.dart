
import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/profile_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/not_login_screen.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if(_isLoggedIn) {
      Provider.of<ProfileProvider>(context, listen: false).getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: ResponsiveHelper.isDesktop(context)? ColorResources.getTryBgColor(context) : Theme.of(context).cardColor,
      appBar: ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()): AppBar(
        backgroundColor: Theme.of(context).cardColor,
        leading: IconButton(
            icon: Image.asset(Images.moreIcon, color: Theme.of(context).primaryColor),
            onPressed: () {
              Provider.of<SplashProvider>(context, listen: false).setPageIndex(0);
              Navigator.of(context).pop();
            }),
        title: Text(getTranslated('profile', context),
            style: poppinsMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            )),
      ),
      body: SafeArea(
        child: _isLoggedIn ? Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
            child: Scrollbar(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ResponsiveHelper.isDesktop(context)
                    ? Center(
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.7),
                        child: SizedBox(
                          width: 1170,
                          child: Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none, children: [
                                  Container(
                                    height: 150,  color:  Theme.of(context).primaryColor.withOpacity(0.5),
                                  ),
                                  Positioned(
                                    left: 30,
                                    top: 45,
                                    child: Container(
                                      height: 180, width: 180,
                                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4),
                                          boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 22, offset: const Offset(0, 8.8) )]),
                                      child: ClipOval(
                                        child: FadeInImage.assetNetwork(
                                          placeholder: Images.getPlaceHolderImage(context), height: 170, width: 170, fit: BoxFit.cover,
                                          image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.customerImageUrl}/'
                                              '${profileProvider.userInfoModel != null ? profileProvider.userInfoModel!.image : ''}',
                                          imageErrorBuilder: (c, o, s) => Image.asset(Images.getPlaceHolderImage(context), height: 170, width: 170, fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                    bottom: -10,
                                    right: 10,
                                    child: InkWell(
                                      onTap: (){
                                        Navigator.pushNamed(
                                          context,
                                          RouteHelper.getProfileEditRoute(profileProvider.userInfoModel),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        padding: const EdgeInsets.all(5),
                                        child: Row(
                                        children: [
                                            const Icon(Icons.edit,size: 16,color: Colors.white),
                                            Text(getTranslated('edit', context),
                                              style: poppinsMedium.copyWith(
                                                fontSize: Dimensions.fontSizeSmall,
                                                color: Colors.white
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ))
                                ],
                              ),

                              /*Center(
                                  child: Text(
                                    '${profileProvider.userInfoModel.fName ?? ''} ${profileProvider.userInfoModel.lName ?? ''}',
                                    style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                                  )),*/

                              //mobileNumber,email,gender
                              const SizedBox(height: 100),
                             profileProvider.isLoading ? CustomLoader(color: Theme.of(context).primaryColor) : Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getTranslated('mobile_number', context),
                                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor.withOpacity(0.6)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${profileProvider.userInfoModel!.fName ?? ''} ${profileProvider.userInfoModel!.lName ?? ''}',
                                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                    ),
                                    const Divider(),
                                    const SizedBox(height: 25),
                                    // for first name section
                                    Text(
                                      getTranslated('mobile_number', context),
                                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor.withOpacity(0.6)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      profileProvider.userInfoModel!.phone ?? '',
                                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                    ),
                                    const Divider(),
                                    const SizedBox(height: 25),

                                    // for email section
                                    Text(
                                      getTranslated('email', context),
                                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor.withOpacity(0.6)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      profileProvider.userInfoModel!.email ?? '',
                                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                    ),
                                    const Divider(),
                                    const SizedBox(height: 25),

                                  ],
                                ),
                              ),


                            ],
                          ),
                        ),
                      ),
                      const FooterView(),
                    ],
                  ),
                )
                : Center(
                  child: SizedBox(
                    width: 1170,
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 12, bottom: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: ColorResources.getGreyColor(context), width: 2),
                                shape: BoxShape.circle),

                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: profileProvider.file == null ? FadeInImage.assetNetwork(
                                      placeholder: Images.getPlaceHolderImage(context),
                                      width: 100, height: 100, fit: BoxFit.cover,
                                      image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.customerImageUrl}/${profileProvider.userInfoModel!.image}',
                                        imageErrorBuilder: (c, o, s) => Image.asset(Images.getPlaceHolderImage(context), height: 100, width: 100, fit: BoxFit.cover)
                                    ) : Image.file(profileProvider.file!, width: 100, height: 100, fit: BoxFit.fill),
                                  )
                            ),
                            Positioned(
                              right: -10,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    RouteHelper.getProfileEditRoute(profileProvider.userInfoModel),
                                  );
                                },
                                child: Text(
                                  getTranslated('edit', context),
                                  style: poppinsMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // for name
                        Center(
                            child: Text(
                          '${profileProvider.userInfoModel!.fName ?? ''} ${profileProvider.userInfoModel!.lName ?? ''}',
                          style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                        )),

                        //mobileNumber,email,gender
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // for first name section
                              Text(
                                getTranslated('mobile_number', context),
                                style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor.withOpacity(0.6)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                profileProvider.userInfoModel!.phone ?? '',
                                style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                              ),
                              const Divider(),
                              const SizedBox(height: 25),

                              // for email section
                              Text(
                                getTranslated('email', context),
                                style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor.withOpacity(0.6)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                profileProvider.userInfoModel!.email ?? '',
                                style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ) : const NotLoggedInScreen()
      ),
    );
  }
}
