import 'package:flutter/material.dart';

class MultipleSelection extends StatefulWidget {
  final List<String> items;
  final List<String> selectedSubject;

  const MultipleSelection({
    super.key,
    required this.items,
    required this.selectedSubject,
  });

  @override
  State<MultipleSelection> createState() => _MultipleSelectionState();
}

class _MultipleSelectionState extends State<MultipleSelection> {
  void _itemChange(String itemValue, bool isSelected) {
    if (isSelected) {
      widget.selectedSubject.add(itemValue);
      setState(() {});
    } else {
      widget.selectedSubject.remove(itemValue);
    }
  }

  void _canceled() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Select Subject'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map(
                (item) => CheckboxListTile(
                  value: widget.selectedSubject.contains(item),
                  title: Text(item),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) => _itemChange(item, isChecked!),
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: _canceled, child: Text('Cancel')),
            ElevatedButton(onPressed: _canceled, child: Text('Submit')),
          ],
        ),
      ],
    );
  }
}
