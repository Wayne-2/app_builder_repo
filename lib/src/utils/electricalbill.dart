import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pacervtu/constants.dart';
import 'package:pacervtu/src/components/discodropdown.dart';
import 'package:pacervtu/src/riverpod/riverpod.dart';
import 'package:pacervtu/src/services/vtpass_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ElectricityBillPage extends ConsumerStatefulWidget {
  const ElectricityBillPage({super.key});

  @override
  ConsumerState<ElectricityBillPage> createState() => _ElectricityBillPageState();
}

class _ElectricityBillPageState extends ConsumerState<ElectricityBillPage> {
  final _vtuService = VtuService();
  final TextEditingController meterNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String selectedServiceID = "Ikeja Electric";
  String selectedMeterType = "prepaid";
  bool isLoading = false;
  String result = "";





  Future<void> payBill(String userName) async {
    if (meterNumberController.text.isEmpty || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await _vtuService.payElectricityBill(
        meterNumber: meterNumberController.text,
        amount: double.parse(amountController.text),
        meterType: selectedMeterType, 
        serviceID: selectedServiceID,
      );

      final supabase = Supabase.instance.client;

      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("No authenticated user");
      }

      await supabase.from('user_services').insert({
        'user_id': supabase.auth.currentUser!.id,
        'app_id': AppData.appId,  
        'username': userName,
        'service_used': 'Electric Bill Payment',
        'service_id': selectedServiceID,
        'amount': amountController.text,
      });
      setState(() {
        isLoading = false;
        result =
            "Success — ${response['content']['Customer_Name'] ?? 'Payment Complete!'}";
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        result = " Failed: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final userName = user?.username ?? '';
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        backgroundColor:AppData.appTheme.withAlpha(50),
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, size: 18),
        ),
        title: Text(
          "Electricity Bill",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            // Card Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppData.appTheme.withAlpha(100),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text(
                    "Select Disco",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DiscoDropdown(
                        onSelected: (serviceID) {
                          selectedServiceID = serviceID;
                          print("Selected serviceID: $serviceID");
                        },
                      ),
                  ),

                  const SizedBox(height: 20),

                 
                  Text(
                    "Meter Type",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMeterType,
                        icon: const Icon(Icons.arrow_drop_down),
                        isExpanded: true,
                        onChanged: (v) => setState(() => selectedMeterType = v!),
                        items: const [
                          DropdownMenuItem(
                              value: "prepaid", child: Text("Prepaid")),
                          DropdownMenuItem(
                              value: "postpaid", child: Text("Postpaid")),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Meter Number",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: meterNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter meter number",
                      hintStyle: GoogleFonts.poppins(fontSize: 14),
                      filled: true,
                      fillColor: const Color.fromARGB(68, 245, 245, 245),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Amount",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter amount (₦)",
                      hintStyle: GoogleFonts.poppins(fontSize: 14),
                      filled: true,
                      fillColor: const Color.fromARGB(68, 245, 245, 245),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppData.appTheme,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                onPressed: isLoading ? null : () => payBill(userName),
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : Text(
                        "Pay Bill",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            if (result.isNotEmpty)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: result.contains("Success")
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: result.contains("Success")
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
