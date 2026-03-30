// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pacervtu/constants.dart';
import 'package:pacervtu/src/riverpod/riverpod.dart';

class BalanceBanner extends ConsumerWidget {
  // final double balance;
  final String bankName;
  final String accountNumber;
  final VoidCallback onAddMoney;

  const BalanceBanner({
    super.key,
    // required this.balance,
    required this.bankName,
    required this.accountNumber,
    required this.onAddMoney,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref ) {
    ref.watch(fetchBalanceOnLoginProvider);

    final balanceAsync = ref.watch(userBalanceStreamProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // WHITE BACKGROUND
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Available Balance",
            style: GoogleFonts.roboto(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 4),

          Consumer(
            builder: (context, ref, child) {
              return balanceAsync.when(
                data: (balance) => Text(
                  '₦ $balance',
                  style: GoogleFonts.roboto(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                loading: () => Center(child: const CircularProgressIndicator(color: Colors.white,)),
                error: (err, stack) => Text('Error: $err'),
              );
            },
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bankName,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    accountNumber,
                    style: GoogleFonts.roboto(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // Add Money Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppData.appTheme,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onAddMoney,
                child: const Text(
                  "Add Money",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
