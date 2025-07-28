import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import '/utility.dart';

class ShowModalBottomHome extends StatefulWidget {
  const ShowModalBottomHome({super.key});

  @override
  State<ShowModalBottomHome> createState() => _ShowModalBottomHomeState();
}

class _ShowModalBottomHomeState extends State<ShowModalBottomHome> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RadioListTile(
                        title: const Text('Approved'),
                        value: 'approved',
                        groupValue: _selectedValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value as String?;
                          });
                        },
                        activeColor:
                            Colors.green, // Warna radio button saat terpilih
                        selected: _selectedValue == 'approved',
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                      RadioListTile(
                        title: const Text('Pending'),
                        value: 'pending',
                        groupValue: _selectedValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value as String?;
                          });
                        },
                        activeColor:
                            Colors.blue, // Warna radio button saat terpilih
                        selected: _selectedValue == 'pending',
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                      RadioListTile(
                        title: const Text('Rejected'),
                        value: 'rejected',
                        groupValue: _selectedValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value as String?;
                          });
                        },
                        activeColor:
                            Colors.red, // Warna radio button saat terpilih
                        selected: _selectedValue == 'rejected',
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                      const Gap(20),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            // Aksi ketika tombol ditekan di dalam BottomSheet
                            if (_selectedValue != null) {
                              print('Pilihan yang dipilih: $_selectedValue');
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorSet.mainBG,
                            elevation: 0,
                            side: BorderSide(width: 2, color: colorSet.mainBG),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Save',
                            style: ThisTextStyle.bold16MainGold,
                          ),
                        ),
                      ),
                      const Gap(40)
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      icon: Image.asset("assets/icons/sort3.png"),
    );
  }
}



class CustomDropdown extends StatefulWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  CustomDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget.value,
      onChanged: (newValue) {
        widget.onChanged(newValue);
        setState(() {
          _isOpen = false;
        });
      },
      onTap: () {
        setState(() {
          _isOpen = true;
        });
      },
      items: widget.items.map((String value) {
        TextStyle itemStyle = TextStyle(
          color: _isOpen ? getColorBasedOnStatus(value) : Colors.black,
        );
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: itemStyle),
        );
      }).toList(),
      underline: SizedBox.shrink(),
      isExpanded: true,
      icon: null,
    );
  }

   Color getColorBasedOnStatus(String status) {
    switch (status) {
      case 'Waiting':
        return Colors.yellow.withOpacity(1); // Light yellow
      case 'Approved':
        return Colors.green.withOpacity(0.75); // Light green
      case 'Rejected':
        return Colors.red.withOpacity(0.75); // Light red
      default:
        return Colors.grey.withOpacity(0.75); // Default color
    }
  }
}
