// ignore_for_file: strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pacervtu/constants.dart';
import 'package:pacervtu/src/components/account_display.dart';
import 'package:pacervtu/src/components/add_money.dart';
import 'package:pacervtu/src/components/ads.dart';
import 'package:pacervtu/src/components/iconaction.dart';
import 'package:pacervtu/src/components/useravatar.dart';
import 'package:pacervtu/src/riverpod/riverpod.dart';
import 'package:pacervtu/src/utils/buyairtime.dart';
import 'package:pacervtu/src/utils/buydata.dart';
import 'package:pacervtu/src/utils/cabletvsub.dart';
import 'package:pacervtu/src/utils/electricalbill.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  unavailable() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Feature is unavailable")));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final displayName = user?.username ?? "User";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4,
                color: AppData.appTheme,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              UserAvatar(name: displayName),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, Again!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: AppData.leadingfontTheme,
                                    ),
                                  ),

                                  Text(
                                    displayName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppData.supportingfontTheme,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 14,
                            child: Icon(
                              Icons.notifications,
                              color: AppData.appTheme,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),

                    Consumer(
                      builder: (context, ref, child) {
                        final userAsync = ref.watch(userProfileStreamProvider);
                      
                        return userAsync.when(
                          data: (user) => BalanceBanner(
                            // balance: user.balance,
                            bankName: user.bankname,
                            accountNumber: user.accountnumber,
                            onAddMoney: () => addMoney(context),
                          ),
                          loading: () => Center(child: const CircularProgressIndicator(color: Colors.white,)),
                          error: (err, stack) => Text('Error: $err'),
                        );
                      },
                    )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 8, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Advertisements",
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 37, 37, 37),
                      ),
                    ),
                  ],
                ),
              ),
              RandomImageCarousel(
                imageUrls: [
                  "https://kbnrbptcysovqbrmgxln.supabase.co/storage/v1/object/public/image_bucket/img1.png",
                  "https://kbnrbptcysovqbrmgxln.supabase.co/storage/v1/object/public/image_bucket/img2.png",
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Our services",
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 37, 37, 37),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 4,
                  childAspectRatio: 0.8,
                  padding: EdgeInsets.zero,
                  children: [
                    IconAction(
                      icon: 'assets/icons/icon-airtime.svg',
                      label: "Airtime",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AirtimePage(),
                          ),
                        );
                      },
                    ),
                    IconAction(
                      icon: 'assets/icons/icon-data.svg',
                      label: "Data",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BuyDataPage(serviceID: "mtn-data"),
                          ),
                        );
                      },
                    ),
                    IconAction(
                      icon: 'assets/icons/icon-electricity.svg',
                      label: "Electric bill",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ElectricityBillPage(),
                          ),
                        );
                      },
                    ),
                    IconAction(
                      icon: 'assets/icons/icon-cable-sub.svg',
                      label: "Cable Sub",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TvSubscriptionPage(),
                          ),
                        );
                      },
                    ),
                    IconAction(
                      icon: 'assets/icons/icon-flight.svg',
                      label: "Flight",
                      onTap: () {
                        unavailable();
                      },
                    ),
                    IconAction(
                      icon: 'assets/icons/icon-betting.svg',
                      label: "Betting",
                      onTap: () {
                        unavailable();
                      },
                    ),
                    IconAction(
                      icon: 'assets/icons/icon-result.svg',
                      label: "Result token",
                      onTap: () {
                        unavailable();
                      },
                    ),
                    IconAction(
                      icon: 'assets/icons/icon-shopping.svg',
                      label: "Shopping",
                      onTap: () {
                        unavailable();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


