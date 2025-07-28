import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import '/utility.dart';

class AddUserPage extends StatefulWidget {
  AddUserPage({Key? key}) : super(key: key);

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedCompanyName = '';
  List<String> companyNameOptions = [];

  void _addUser(BuildContext context) async {
  // Periksa apakah ada data yang belum diisi
  if (_usernameController.text.isEmpty ||
      _passwordController.text.isEmpty ||
      _selectedCompanyName.isEmpty ||
      _telephoneController.text.isEmpty) {
    _showSnackbar(context, 'Please fill in all data', Colors.red);
    return;
  }

  final url = Uri.parse('https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/add_users.php');
  final response = await http.post(
    url,
    body: {
      'username': _usernameController.text,
      'password': _passwordController.text,
      'status': _selectedStatus, // Menggunakan nilai dari dropdown
      'lokasi': _locationController.text,
      'company_name': _selectedCompanyName,
      'telephone': _telephoneController.text,
      'email': _emailController.text,
    },
  );

  print(response.body); // Tambahkan pernyataan ini untuk menampilkan respons dari server

  if (response.statusCode == 200) {
    final responseData = response.body;
    _showSnackbar(context, responseData, colorSet.mainBG);
    if (responseData == "User added successfully") {
      // Pengguna berhasil ditambahkan, kembali ke halaman sebelumnya
      // Navigator.pop(context);
    }
    Navigator.pop(context, true);
  } else {
    _showSnackbar(context, 'Failed to add user. Please try again.', Colors.red);
  }

  //  if (response.statusCode == 200) {
  //   final responseData = response.body;
  //   // _showSnackbar(context, responseData, Colors.black);
  //   if (responseData == "User added successfully") {
  //     // Pengguna berhasil ditambahkan, kembali ke halaman sebelumnya
  //     // Navigator.pop(context);
  //     Navigator.pop(context, true);
  //   }
    
  // } else {
  //   // _showSnackbar(context, 'Failed to add user. Please try again.', Colors.red);
  // }
}

void _showSnackbar(BuildContext context, String message, Color backgroundColor) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ),
  );
}


  Future<void> fetchCompanyNames() async {
    final response = await http.get(
        Uri.parse('https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/get_dropdown.php'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      Set<String> uniqueCompanyNames = {};
      for (var companyName in data.cast<String>()) {
        uniqueCompanyNames.add(companyName);
      }
      setState(() {
        companyNameOptions = uniqueCompanyNames.toList();
      });
    } else {
      throw Exception('Failed to load company names');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCompanyNames(); // Call the function to fetch company names
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, true);
    return false; // Return 'false' untuk mencegah aksi pop default (opsional).
  }

  String _selectedStatus = 'vendor'; // Nilai default untuk dropdown

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: colorSet.pewter,
        appBar: AppBar(
          centerTitle: true,
          forceMaterialTransparency: true,
          backgroundColor: Colors.transparent,
          title: Text(
            "ADD USER",
            style: ThisTextStyle.bold20MainBg,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Gap(20),
                TextField(
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.characters,
                  controller: _usernameController,
                  cursorColor: colorSet.mainGold,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.account_box),
                    hintText: "Name...",
                    filled: true,
                    fillColor: colorSet.listTile1,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const Gap(20),
                TextField(
                  keyboardType: TextInputType.visiblePassword,
                  controller:
                      _passwordController, // Gunakan controller untuk email
                  cursorColor: colorSet.mainGold,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.password),
                    hintText: "Password...",
                    filled: true,
                    fillColor: colorSet.listTile1,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const Gap(20),
                // Dropdown untuk memilih status
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items: ['vendor', 'procurement', 'super admin']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.account_box),
                    filled: true,
                    fillColor: colorSet.listTile1,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const Gap(20),
                SizedBox(
                  width: double
                      .infinity, // Ensure the width takes up the available space
                  child: DropdownSearch<String>(
                    items: companyNameOptions,
                    selectedItem: _selectedCompanyName.isNotEmpty
                        ? _selectedCompanyName
                        : null,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        prefixIcon: Icon(Icons.business),
                        filled: true,
                        fillColor: colorSet.listTile1,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        hintText: 'Select Vendor',
                      ),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCompanyName =
                            newValue ?? ''; // Set to empty string if null
                      });
                    },
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      fit: FlexFit.loose,
                      menuProps: MenuProps(
                        backgroundColor: colorSet.listTile2,
                        elevation: 0,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      searchFieldProps: TextFieldProps(
                        cursorColor: Colors.black, // warna kursor
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(
                            // jenis border
                            borderSide:
                                BorderSide(color: Colors.black), // warna border
                            borderRadius:
                                BorderRadius.circular(15), // border radius
                          ),
                          focusedBorder: OutlineInputBorder(
                            // border saat fokus
                            borderSide: BorderSide(
                                color: Colors.black), // warna border saat fokus
                            borderRadius: BorderRadius.circular(
                                15), // border radius saat fokus
                          ),
                          prefixIcon: Icon(Icons.business),
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(20),
                TextField(
                  keyboardType: TextInputType.phone,
                  controller: _telephoneController,
                  cursorColor: colorSet.mainGold,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone),
                    hintText: "Phone Number...",
                    filled: true,
                    fillColor: colorSet.listTile1,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const Gap(20),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  cursorColor: colorSet.mainGold,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.mail),
                    hintText: "Email...",
                    filled: true,
                    fillColor: colorSet.listTile1,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const Gap(20),
                TextField(
                  keyboardType: TextInputType.streetAddress,
                  controller: _locationController,
                  cursorColor: colorSet.mainGold,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.pin_drop),
                    hintText: "Location...",
                    filled: true,
                    fillColor: colorSet.listTile1,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const Gap(20),
                Container(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorSet.mainBG,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      _addUser(
                          context); // Panggil metode _addUser saat tombol "Save" ditekan
                    },
                    child: Text(
                      "Save",
                      style: ThisTextStyle.bold16MainGold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
