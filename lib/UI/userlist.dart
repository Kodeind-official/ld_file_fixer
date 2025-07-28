import 'dart:async';
import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import '/UI/addUser.dart';
import '/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String username;
  final String password;
  final String status;
  final String lokasi;
  final String companyName;
  final String telephone;
  final String email;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.status,
    required this.lokasi,
    required this.companyName,
    required this.telephone,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic>? json) {
    return User(
      id: json?['id'] ?? '',
      username: json?['username'] ?? '',
      password: json?['password'] ?? '',
      status: json?['status'] ?? '',
      lokasi: json?['lokasi'] ?? '',
      companyName: json?['company_name'] ?? '',
      telephone: json?['telephone'] ?? '',
      email: json?['email'] ?? '',
    );
  }
}

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool isSearching = false;
  Timer? _debounce;
  String _searchText = '';
  int? userId;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });

    print('Id: $userId');
  }

  void _startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      isSearching = false;
      _searchController.clear();
    });
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse(
        'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/get_users.php'));

    if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    List<User> users = data.map((user) => User.fromJson(user)).toList();
    if (!mounted) return;
    setState(() {
      // Filter users to exclude the one with the same id as userId
      _users = users.where((user) => user.id != userId.toString()).toList();
      // Urutkan daftar pengguna berdasarkan nama pengguna
      _users.sort((a, b) => a.username.compareTo(b.username));
    });
  } else {
    throw Exception('Failed to load users');
  }
}

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _loadUserInfo();
  }

  Future<void> deleteUser(String id, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/delete_user.php'),
        body: {'id': id},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorSet.mainGold,
            content: Text('User deleted successfully'),
          ),
        );

        // Tampilkan Snackbar dengan warna hijau untuk berhasil
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (error) {
      // Tampilkan Snackbar dengan warna merah untuk kegagalan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to delete user'),
        ),
      );
    }
  }

  Future<void> editUser(User user) async {
    // Navigate to edit page and pass the user object
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserPage(user: user),
      ),
    ).then((_) {
      // Refresh user list after edit page is popped
      fetchUsers();
    });
  }

  void _searchUsers(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      setState(() {
        _filteredUsers = _users
            .where((user) =>
                user.username.toLowerCase().contains(query.toLowerCase()) ||
                user.companyName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  void _navigateToAddUserPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => AddUserPage(),
      ),
    );
    if (result != null && result == true) {
      // Perbarui daftar pengguna jika pengguna ditambahkan dari halaman Add User
      fetchUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    var scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      backgroundColor: colorSet.pewter,
      key: scaffoldKey,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateToAddUserPage(context);
        },
        label: Text(
          "Add User",
          style: ThisTextStyle.bold16MainGold,
        ),
        backgroundColor: colorSet.mainBG,
        icon: Icon(
          Icons.add,
          color: colorSet.mainGold,
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        title: isSearching
            ? TextField(
                autofocus: true,
                controller: _searchController,
                onChanged: _searchUsers,
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: colorSet.mainBG),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: colorSet.mainBG),
              )
            : Text(
                'USERS',
                style: ThisTextStyle.bold22MainBg,
              ),
        actions: <Widget>[
          isSearching
              ? IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color: colorSet.mainBG,
                  ),
                  onPressed: () {
                    _stopSearch();
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search, color: colorSet.mainBG),
                  onPressed: () {
                    _startSearch();
                  },
                ),
        ],
      ),
      body: ListView.builder(
        itemCount: isSearching ? _filteredUsers.length : _users.length,
        itemBuilder: (context, index) {
          final user = isSearching ? _filteredUsers[index] : _users[index];
          return Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: colorSet.listTile1),
              child: ListTile(
                contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                leading: CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    user.username,
                    style: ThisTextStyle.bold18MainBg,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(user.companyName),
                ),
                onTap: () {
                  // Navigator.pop(context);
                  editUser(user);
                  // Handle tap event
                },
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: colorSet.mainGold,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: colorSet.listTile2, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      title: Text('Delete'),
                      content: Text(
                          'Are you sure you want to delete ${user.username}?'),
                      actions: [
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
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: colorSet.mainBG),
                              ),
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
                                deleteUser(user.id, context);
                                Navigator.pop(context);
                                fetchUsers();
                              },
                              child: Text(
                                'Delete',
                                style: TextStyle(color: colorSet.mainGold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class EditUserPage extends StatefulWidget {
  final User user;

  const EditUserPage({Key? key, required this.user}) : super(key: key);

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  // final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _passwordReset = false;
  String _selectedCompanyName = '';
  List<String> companyNameOptions = [];

  @override
  void initState() {
    super.initState();
    fetchCompanyNames();
    // Set initial values for editing
    _usernameController.text = widget.user.username;
    //  _passwordController.text = widget.user.password;
    if (widget.user.password != null && widget.user.password.isNotEmpty) {
      _passwordController.text = widget.user.password;
    }
    _statusController.text = widget.user.status;
    _lokasiController.text = widget.user.lokasi;
    _selectedCompanyName = widget.user.companyName;
    _telephoneController.text = widget.user.telephone;
    _emailController.text = widget.user.email;
  }

  Future<void> saveChanges() async {
    final String userId = widget.user.id; // Get the user ID

    // Prepare the updated user data from the text controllers
    final String updatedUsername = _usernameController.text;
    final String updatedPassword = _passwordController.text;
    final String updatedStatus = _statusController.text;
    final String updatedLokasi = _lokasiController.text;
    final String updatedTelephone = _telephoneController.text;
    final String updatedEmail = _emailController.text;

    // Make a POST request to update the user data
    final response = await http.post(
      Uri.parse(
          'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/edit_user.php'),
      body: {
        'id': userId,
        'username': updatedUsername,
        'password': updatedPassword,
        'status': updatedStatus,
        'lokasi': updatedLokasi,
        'company_name': _selectedCompanyName,
        'telephone': updatedTelephone,
        'email': updatedEmail,
      },
    );

    if (response.statusCode == 200) {
      if (response.body.contains('Username atau Company Name sudah ada.')) {
        // Handle duplicate username or company name warning
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Username atau Company Name sudah ada. Silakan coba yang lain.')),
        );
      } else {
        // Handle success, e.g., show a success message
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data updated successfully')),
        );
      }
    } else {
      // Handle failure, e.g., show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user')),
      );
    }
  }

  Future<void> fetchCompanyNames() async {
    final response = await http.get(Uri.parse(
        'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/get_dropdown.php'));
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "UPDATE USER",
          style: ThisTextStyle.bold20MainBg,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
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
                readOnly: true,
                obscureText: !_passwordReset,
                onTap: () {
                  _showResetPasswordDialog(); // Show dialog on tap
                },
                controller: _passwordController,
                cursorColor: colorSet.mainGold,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.account_box),
                  hintText: "password...",
                  filled: true,
                  fillColor: colorSet.listTile1,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const Gap(20),
              Padding(
                padding: const EdgeInsets.only(left: 0.0, right: 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorSet.listTile1,
                    borderRadius: BorderRadius.circular(15), // Tambahkan radius
                  ),
                  child: DropdownButtonFormField<String>(
                    value: widget.user.status,
                    onChanged: (String? newValue) {
                      setState(() {
                        _statusController.text = newValue!;
                      });
                    },
                    items: <String>['vendor', 'procurement', 'super admin']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.arrow_right),
                        filled: true,
                        fillColor: colorSet.listTile1,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15),
                        )),
                  ),
                ),
              ),
              const Gap(20),
              TextField(
                controller: _lokasiController,
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
              // TextField(
              //   controller: _companyNameController,
              //   decoration: InputDecoration(
              //     prefixIcon: const Icon(Icons.house),
              //     hintText: "Company Name...",
              //     filled: true,
              //     fillColor: colorSet.listTile1,
              //     border: OutlineInputBorder(
              //       borderSide: BorderSide.none,
              //       borderRadius: BorderRadius.circular(15),
              //     ),
              //   ),
              // ),
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
              const Gap(30),
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
                  onPressed: saveChanges,
                  child: Text(
                    "Save",
                    style: ThisTextStyle.bold16MainGold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorSet.mainGold,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colorSet.listTile2, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text('Reset Password'),
        content:
            Text('Do you want to reset the password to the default value?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              setState(() {
                _passwordController.text =
                    'passwordAwal'; // Set default password
                _passwordReset = true; // Set password reset status
              });
            },
            child: Container(
              width: 90,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorSet.mainBG,
              ),
              child: Center(
                child: Text(
                  "Yes",
                  style: TextStyle(color: colorSet.mainGold),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Container(
              width: 90,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorSet.listTile2,
              ),
              child: Center(
                child: Text(
                  "Cancel",
                  style: TextStyle(color: colorSet.mainBG),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
