import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pacervtu/constants.dart';
import 'package:pacervtu/src/riverpod/riverpod.dart';
import 'package:pacervtu/src/services/vtpass_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AirtimePage extends ConsumerStatefulWidget {
  const AirtimePage({super.key});

  @override
  ConsumerState<AirtimePage> createState() => _AirtimePageState();
}

class _AirtimePageState extends ConsumerState<AirtimePage> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final vtuService = VtuService();

  bool isLoading = false;
  String selectedNetwork = "mtn";
  String result = "";

  int? _amount;
  int? _phone;

  bool _validate() {
    final amount = int.tryParse(_amountController.text);
    final phone = int.tryParse(_phoneController.text);

    if (phone == null || phone.toString().length < 10) {
      _showMessage("Enter a valid phone number");
      return false;
    }

    if (amount == null || amount <= 0) {
      _showMessage("Enter a valid amount");
      return false;
    }

    _amount = amount;
    _phone = phone;
    return true;
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _buyAirtime(String username) async {
    if (!_validate()) return;

    setState(() {
      isLoading = true;
      result = "";
    });

    try {
      final res = await vtuService.buyAirtime(
        network: selectedNetwork,
        phone: _phone!,
        amount: _amount!,
      );

      final supabase = Supabase.instance.client;

      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("No authenticated user");
      }

      await supabase.from('user_services').insert({
        'user_id': supabase.auth.currentUser!.id,
        'app_id': AppData.appId,  
        'username': username,
        'service_used': 'Airtime Purchase',
        'service_id': selectedNetwork,
        'amount': _amount,
      });

      setState(() =>
          result = "Success: ${res['message'] ?? 'Airtime sent successfully!'}");
    } catch (e) {
      setState(() => result = "Failed: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final themeColor = AppData.appTheme;
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:AppData.appTheme.withAlpha(50),
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Text("Buy Airtime",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(),
            const SizedBox(height: 30),

            /// BUY BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => _buyAirtime(userProfile!.username),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppData.appTheme,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : Text("Buy Airtime",
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
              ),
            ),

            const SizedBox(height: 20),

            if (result.isNotEmpty) _buildResultBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppData.appTheme.withAlpha(100),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label("Select Network"),
        _networkDropdown(),
        const SizedBox(height: 20),

        _label("Phone Number"),
        _inputField(
          controller: _phoneController,
          icon: Icons.phone_android,
          hint: "Enter phone number",
          type: TextInputType.phone,
        ),
        const SizedBox(height: 20),

        _label("Amount"),
        _inputField(
          controller: _amountController,
          icon: Icons.money_outlined,
          hint: "Enter amount (₦)",
          type: TextInputType.number,
        ),
      ]),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget _networkDropdown() {
    const networks = ["mtn", "airtel", "glo", "etisalat"];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: selectedNetwork,
          isExpanded: true,
          items: networks
              .map((n) =>
                  DropdownMenuItem(value: n, child: Text(n.toUpperCase())))
              .toList(),
          onChanged: (v) => setState(() => selectedNetwork = v!),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required TextInputType type,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: const Color.fromARGB(68, 245, 245, 245),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildResultBox() {
    final success = result.contains("Success");

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: success ? Colors.green.shade100 : Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          result,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: success ? Colors.green.shade800 : Colors.red.shade800,
          ),
        ),
      ),
    );
  }
}
