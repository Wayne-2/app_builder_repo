import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pacervtu/constants.dart';
import 'package:pacervtu/src/riverpod/riverpod.dart';

class AccountCredential extends ConsumerStatefulWidget {
  const AccountCredential({super.key});

  @override
  ConsumerState<AccountCredential> createState() => _AccountCredentialState();
}

class _AccountCredentialState extends ConsumerState<AccountCredential> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final accountName = user?.username ?? "User";
    final bankname = user?.bankname ?? "Unavailable";
    final accountNumber = user?.accountnumber ?? "N/A";
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppData.appTheme.withAlpha(40),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            AccountInfo(
              icon: Icons.account_balance,
              title: 'Bank Name',
              value: bankname,
            ),
            const Divider(height: 1, color: AppData.appTheme,),
            AccountInfo(
              icon: Icons.person_outline,
              title: 'Account Name',
              value: accountName,
            ),
            const Divider(height: 1, color: AppData.appTheme,),
            AccountInfo(
              icon: Icons.numbers,
              title: 'Account Number',
              value: accountNumber,
            ),
          ],
        ),
      ),
    );
  }
}

class AccountInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const AccountInfo({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Icon Bubble
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppData.appTheme.withAlpha(60),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),

          const SizedBox(width: 15),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
