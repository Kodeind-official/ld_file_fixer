import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/utility.dart';

class AddCompanyPage extends StatefulWidget {
  @override
  State<AddCompanyPage> createState() => _AddCompanyPageState();
}

class _AddCompanyPageState extends State<AddCompanyPage> {
  final TextEditingController _companyNameController = TextEditingController();
  String _errorMessage = '';

  Future<void> _addCompany(String companyName) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/add_company_name.php'),
        body: json.encode({'company_name': companyName}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // If the server returns a success status code,
        // handle the success response here.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorSet.mainGold,
            content: Text('Company added successfully'),
            duration: Duration(seconds: 2), // Atur durasi snackbar di sini
          ),
        );

        print('Company added successfully');
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to add Company'),
            duration: Duration(seconds: 2), // Atur durasi snackbar di sini
          ),
        );
        // If the server returns an error status code,
        // display an error message to the user.
        setState(() {
          _errorMessage = 'Failed to add Company ${response.body}';
          print(
            _errorMessage,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to add Company'),
          duration: Duration(seconds: 2), // Atur durasi snackbar di sini
        ),
      );
      // Display error message to the user in case of any exceptions.
      print('Exception while adding Company: $e');
      setState(() {
        _errorMessage = 'Failed to add Company. Please try again later.';
      });
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, true);
    return false; // Return 'false' untuk mencegah aksi pop default (opsional).
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/bg_ld2.jpg"), fit: BoxFit.cover),
      ),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: colorSet.listTile1,
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            title: Text(
              'Add Company',
              style: ThisTextStyle.bold20listTile1,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  controller: _companyNameController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 32.0, bottom: 32),
                    // labelText: 'Company Name',
                    prefixIcon: Icon(Icons.account_box),
                    hintText: "Company Name...",
                    filled: true,
                    fillColor: colorSet.listTile1,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                SizedBox(height: 20),
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
                      String companyName = _companyNameController.text;
                      if (companyName.isNotEmpty) {
                        _addCompany(companyName);
                      }
                    },
                    child: Text(
                      'Add Company',
                      style: ThisTextStyle.bold16MainGold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // if (_errorMessage.isNotEmpty)
                //   Text(
                //     _errorMessage,
                //     style: TextStyle(color: Colors.red),
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
