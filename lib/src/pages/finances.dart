import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pacervtu/src/components/account_credential.dart';
import 'package:pacervtu/src/components/ads.dart';
import 'package:pacervtu/src/components/recent_transaction.dart';

class Finances extends StatelessWidget {
  const Finances({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:Column(
        children: [
          SizedBox(height:10),
          RandomImageCarousel(
            imageUrls: [
              "https://kbnrbptcysovqbrmgxln.supabase.co/storage/v1/object/public/image_bucket/img1.png",
              "https://kbnrbptcysovqbrmgxln.supabase.co/storage/v1/object/public/image_bucket/img2.png", 
            ],
          ),
          AccountCredential(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Recent Activities", style: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 70, 70, 70))),
              ],
            ),
          ),
          RecentTransaction()
        ],
      
      )
    );
  }
}