// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pacervtu/constants.dart';
import 'package:pacervtu/src/model/datamodel.dart';
import 'package:pacervtu/src/riverpod/riverpod.dart';
import 'package:pacervtu/src/services/vtpass_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class BuyDataPage extends ConsumerStatefulWidget {
  final String serviceID; // e.g. "mtn-data", "airtel-data"
  const BuyDataPage({super.key, required this.serviceID});

  @override
  ConsumerState<BuyDataPage> createState() => _BuyDataPageState();
}

class _BuyDataPageState extends ConsumerState<BuyDataPage> {
  final _vtuService = VtuService();
  List<DataVariation> bundles = [];
  DataVariation? selectedBundle;
  bool isLoading = false;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  
  @override
  void initState() {
    super.initState();
    loadBundles();
  }

Future<void> loadBundles() async {
  setState(() => isLoading = true);

  try {
    final List<DataVariation> result = await _vtuService.getDataBundles(widget.serviceID);

    setState(() {
      bundles = result;
      isLoading = false;
    });
  } catch (e) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading bundles: $e')),
    );
  }
}




  void purchaseData(String username) async {
    if (selectedBundle == null || phoneController.text.isEmpty) return;

    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await _vtuService.buyData(
        serviceID: widget.serviceID,
        variationCode: selectedBundle!.variationCode,
        phone: phoneController.text,
        requestId: DateTime.now().millisecondsSinceEpoch.toString(), 
        amount: amountController.text
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
        'service_used': 'Mobile Data Purchase',
        'service_id': widget.serviceID,
        'amount': amountController.text,
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['response_description'] ?? 'Success')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final userName = user?.username ?? '';

    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:AppData.appTheme.withAlpha(50),
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, size: 13),
        ),
        title: Text(
          "${widget.serviceID.toUpperCase()} Data",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 13
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Phone Number",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Enter phone number",
                            filled: true,
                            fillColor: const Color.fromARGB(60, 250, 250, 250),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppData.appTheme.withAlpha(60)
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Select Bundle",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(91, 250, 250, 250),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: AppData.appTheme.withAlpha(60), width: 1),
                          ),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: DropdownButton<DataVariation>(
                          isExpanded: true,
                          value: selectedBundle,
                          underline: const SizedBox(),
                          hint: const Text(
                            "Choose your data plan",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          items: bundles.map((bundle) {
                            return DropdownMenuItem<DataVariation>(
                              value: bundle,
                              child: Text(
                                "${bundle.name} - ₦${bundle.variationAmount.toStringAsFixed(0)}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedBundle = value;
                            });
                          },
                        ),
                        
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Enter Preffered amount",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),
                        TextField(
                          controller: amountController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Enter Amount",
                            filled: true,
                            fillColor: const Color.fromARGB(60, 250, 250, 250),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppData.appTheme.withAlpha(60)
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () => purchaseData(userName),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppData.appTheme,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              "Buy Data",
                              style: TextStyle(
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
                  const SizedBox(height: 30),
                  Text(
                    "Ensure the phone number is correct before proceeding.",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
