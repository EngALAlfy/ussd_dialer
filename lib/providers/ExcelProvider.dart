import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ExcelProvider extends ChangeNotifier {
  String fileName = "N/A";
  List numbers;

  getExcel() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['xlsx', 'csv', 'xls']);
    fileName = result.files.single.name;
    var bytes = File(result.files.single.path).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    numbers = excel.sheets.values.first.rows.map((e) => e.first).toList();

    notifyListeners();
  }
}
