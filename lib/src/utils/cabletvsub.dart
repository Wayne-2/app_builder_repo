// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pacervtu/constants.dart';
import 'package:pacervtu/src/components/loadingbox.dart';
import 'package:pacervtu/src/services/vtpass_service.dart';

class TvSubscriptionPage extends StatefulWidget {
  const TvSubscriptionPage({super.key});

  @override
  State<TvSubscriptionPage> createState() => _TvSubscriptionPageState();
}

class _TvSubscriptionPageState extends State<TvSubscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _smartCardController = TextEditingController();
  final _phoneController = TextEditingController();

  final VtuService _vtuService = VtuService();

  String? selectedProvider;
  String? selectedPlanCode;
  double? selectedAmount;

  List<dynamic> tvPlans = [];
  Map<String, dynamic>? verifiedCustomer;

  bool isLoading = false;

  final List<Map<String, String>> providers = [
    {"id": "dstv", "name": "DStv"},
    {"id": "gotv", "name": "GOtv"},
    {"id": "startimes", "name": "Startimes"},
  ];

  Future<void> verifyDecoder() async {
    if (_smartCardController.text.isEmpty || selectedProvider == null) {
      showAlertBox(
        context,
        "Error",
        "Please select a provider and enter your Smartcard number",
      );
      return;
    }

    showLoadingPopup(context, "Verifying Smartcard...");

    try {
      final result = await _vtuService.verifyTvDecoder(
        serviceID: selectedProvider!,
        smartCardNumber: _smartCardController.text.trim(),
      );

      Navigator.pop(context);
      setState(() {
        verifiedCustomer = result["content"];
      });

      showAlertBox(
        context,
        "Verification Successful",
        "Customer: ${verifiedCustomer?["Customer_Name"] ?? "Unknown"}",
      );

      await loadTvPlans(selectedProvider!);
    } catch (e) {
      Navigator.pop(context);
      showAlertBox(context, "Error", e.toString());
    }
  }

  Future<void> loadTvPlans(String provider) async {
    showLoadingPopup(context, "Loading plans...");

    try {
      final result = await _vtuService.getTvVariations(provider);
      Navigator.pop(context);
      setState(() {
        tvPlans = result["content"]["variations"] ?? [];
      });
    } catch (e) {
      Navigator.pop(context);
      showAlertBox(context, "Error", e.toString());
    }
  }

  Future<void> payTv() async {
    if (selectedPlanCode == null || verifiedCustomer == null) {
      showAlertBox(
        context,
        "Error",
        "Please verify your Smartcard and select a plan",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await _vtuService.payTvSubscription(
        serviceID: selectedProvider!,
        smartCardNumber: _smartCardController.text.trim(),
        variationCode: selectedPlanCode!,
        amount: selectedAmount!,
        phoneNumber: _phoneController.text.trim(),
      );

      print(result);

      showAlertBox(
        context,
        "Payment Successful",
        "Subscription for ${verifiedCustomer?["Customer_Name"] ?? "customer"} was successful!",
      );
    } catch (e) {
      showAlertBox(context, "Payment Failed", e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final themeColor = AppData.appTheme //

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppData.appTheme.withAlpha(50),
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, size: 18),
        ),
        title: Text(
          "TV Subscription",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppData.appTheme.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider Selection
                    Text(
                      "Select Provider",
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
                          value: selectedProvider,
                          hint: Text(
                            "Choose Provider",
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          icon: const Icon(Icons.arrow_drop_down),
                          isExpanded: true,
                          onChanged: (v) =>
                              setState(() => selectedProvider = v),
                          items: providers
                              .map(
                                (n) => DropdownMenuItem(
                                  value: n["id"],
                                  child: Text(
                                    n["name"]!,
                                    style: GoogleFonts.poppins(fontSize: 15),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Smartcard
                    Text(
                      "Smartcard Number",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _smartCardController,
                      decoration: InputDecoration(
                        hintText: "Enter smartcard number",
                        prefixIcon: const Icon(Icons.tv_outlined),
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
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: verifyDecoder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppData.appTheme,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          "Verify Smartcard",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    if (verifiedCustomer != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Customer: ${verifiedCustomer?["Customer_Name"] ?? "N/A"}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Meter Type: ${verifiedCustomer?["Meter_Type"] ?? "N/A"}",
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (tvPlans.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        "Select Plan",
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
                            value: selectedPlanCode,
                            hint: Text(
                              "Choose Plan",
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            icon: const Icon(Icons.arrow_drop_down),
                            isExpanded: true,
                            onChanged: (value) {
                              final selected = tvPlans.firstWhere(
                                (plan) =>
                                    plan["variation_code"]?.toString() == value,
                                orElse: () => {},
                              );
                              setState(() {
                                selectedPlanCode = value;
                                selectedAmount = double.tryParse(
                                  selected["variation_amount"].toString(),
                                );
                              });
                            },
                            items: tvPlans
                                .map<DropdownMenuItem<String>>(
                                  (plan) => DropdownMenuItem<String>(
                                    value:
                                        plan["variation_code"]?.toString() ??
                                        '',
                                    child: Text(
                                      plan["name"]?.toString() ?? '',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    Text(
                      "Phone Number",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Enter phone number",
                        prefixIcon: const Icon(Icons.phone_android_outlined),
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
                  onPressed: isLoading ? null : payTv,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
                      : Text(
                          "Pay Subscription",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
