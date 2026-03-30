// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:pacervtu/src/riverpod/riverpod.dart';

Future<void> addMoney(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => const AddMoneyDialog(),
  );
}

class AddMoneyDialog extends ConsumerStatefulWidget {
  const AddMoneyDialog({super.key});

  @override
  ConsumerState<AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends ConsumerState<AddMoneyDialog> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final accountName = user?.username ?? '';
    final bankName = user?.bankname ?? '';
    final accountNumber = user?.accountnumber ?? '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 248, 236, 255),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset("assets/logo.png", width: 26, height: 26),
                ),
                const SizedBox(width: 12),
                Text(
                  "Add Money",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F0033),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.05),
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              "Fund this account",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoRow("Account", accountName),
            _buildInfoRow("Bank Name", bankName),
            _buildCopyRow("Account Number", accountNumber),

            const Divider(height: 40, thickness: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 15),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 15),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              HapticFeedback.mediumImpact();
              Clipboard.setData(ClipboardData(text: value));

              // Show toast
              ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                const SnackBar(
                  content: Text("Copied"),
                  duration: Duration(milliseconds: 900),
                ),
              );
            },
            child: Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: Color(0xFF740690),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
