import 'package:flutter/material.dart';

const vtpassElectricityServices = {
  "Ikeja Electric": "ikeja-electric",
  "Eko Electric": "eko-electric",
  "Abuja Electric": "abuja-electric",
  "Kano Electric": "kano-electric",
  "Port Harcourt Electric": "portharcourt-electric",
  "Jos Electric": "jos-electric",
  "Ibadan Electric": "ibadan-electric",
  "Kaduna Electric": "kaduna-electric",
  "Enugu Electric": "enugu-electric",
  "Benin Electric": "benin-electric",
  "Yola Electric": "yola-electric",
  "Aba Electric": "aba-electric",
};

class DiscoDropdown extends StatefulWidget {
  final Function(String serviceID) onSelected;

  const DiscoDropdown({super.key, required this.onSelected});

  @override
  State<DiscoDropdown> createState() => _DiscoDropdownState();
}

class _DiscoDropdownState extends State<DiscoDropdown> {
  String? selectedDisco;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: 'Select Distributor'
      ),
      value: selectedDisco,
      items: vtpassElectricityServices.keys.map((name) {
        return DropdownMenuItem<String>(
          value: name,
          child: Text(name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => selectedDisco = value);
        widget.onSelected(vtpassElectricityServices[value]!);
      },
    );
  }
}
