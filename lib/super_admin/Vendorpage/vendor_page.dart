import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/super_admin/Vendorpage/add.dart';
import '/utility.dart';

class Company {
  final String id;
  final String companyName;

  Company({required this.id, required this.companyName});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      companyName: json['company_name'],
    );
  }
}

class CompanyPage extends StatefulWidget {
  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  List<Company> companies = [];

  Future<void> fetchCompanies() async {
    final response = await http.get(Uri.parse(
        'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/get_company_list.php'));
     if (response.statusCode == 200) {
    final List<dynamic> responseData = json.decode(response.body);
    setState(() {
      companies = responseData.map((data) => Company.fromJson(data)).toList();
      companies.sort((a, b) => a.companyName.compareTo(b.companyName)); // Urutkan berdasarkan nama perusahaan
    });
  } else {
    throw Exception('Failed to load companies');
  }
}

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  Future<void> navigasiAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCompanyPage()),
    );

    // Jika hasilnya true, lakukan refresh.
    if (result == true) {
      fetchCompanies(); // Fungsi refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        title: Text(
          'COMPANY LIST',
          style: ThisTextStyle.bold20MainBg,
        ),
      ),
      body: ListView.builder(
        itemCount: companies.length,
        itemBuilder: (context, index) {
          // Color containerColor =
          //     index.isOdd ? colorSet.listTile2 : colorSet.listTile1;
          return GestureDetector(
            onLongPress: () {
              // Saat tap lama, tampilkan dialog konfirmasi untuk menghapus
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: colorSet.mainGold,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: colorSet.listTile2, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: Text('Delete Company?'),
                    content: Text(
                        'Are you sure you want to delete ${companies[index].companyName}?'),
                    actions: <Widget>[
                      Container(
                        width: 90,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: colorSet.listTile2,
                        ),
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              // Tutup dialog
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel',
                                style: TextStyle(color: colorSet.mainBG)),
                          ),
                        ),
                      ),
                      Container(
                        width: 90,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: colorSet.mainBG,
                        ),
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              // Panggil fungsi untuk menghapus item
                              deleteCompany(companies[index].id);
                              // Tutup dialog
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete',
                                style: TextStyle(color: colorSet.mainGold)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.only(
                  top: 12, bottom: 12, left: 20, right: 20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: colorSet.listTile1,
                      // border: Border.all(
                      //   color: containerColor == Colors.green.withOpacity(0.5)
                      //       ? Colors.green
                      //       : Colors.transparent,
                      //   width: containerColor == Colors.green.withOpacity(0.5)
                      //       ? 2.0
                      //       : 0.0,
                      // )
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.only(
                          top: 12, bottom: 12, left: 12, right: 15),
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.business,
                          color: colorSet.mainBG,
                        ),
                        backgroundColor: colorSet.listTile2,
                      ),
                      title: Text(companies[index].companyName,
                          style: ThisTextStyle.bold16MainBg),
                      // You can add more details here if needed
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigasiAdd();
        },
        label: Text(
          "Add Company",
          style: ThisTextStyle.bold16MainGold,
        ),
        backgroundColor: colorSet.mainBG,
        icon: Icon(
          Icons.add,
          color: colorSet.mainGold,
        ),
      ),
    );
  }

  // Fungsi untuk menghapus perusahaan
  void deleteCompany(String companyId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/delete_company.php'), // Update URL ke lokasi baru
        body: json.encode({'company_id': companyId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Jika server merespons dengan kode 200 (OK),
        // hapus perusahaan dari daftar
        setState(() {
          companies.removeWhere((company) => company.id == companyId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorSet.mainGold,
            content: Text('Company deleted successfully'),
          ),
        );
        print('Company deleted successfully');
      } else {
        // Jika server merespons dengan kode selain 200,
        // tampilkan pesan kesalahan
        print('Failed to delete company: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to delete company'),
          ),
        );
      }
    } catch (e) {
      // Tangani kesalahan jika terjadi kesalahan selama proses penghapusan
      print('Exception while deleting company: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to delete company'),
        ),
      );
    }
  }
}
