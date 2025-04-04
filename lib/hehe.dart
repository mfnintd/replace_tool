import 'dart:io';
import 'dart:convert';

String cleanJsonString(String input) {
  return input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ''); // Xóa các ký tự điều khiển
}

void saveJsonToFile(String outputFolder, String fileName, Object res) async {
  final filePath = "$outputFolder${Platform.pathSeparator}$fileName";
  final jsonString = json.encode(res);
  final cleanedJson = cleanJsonString(jsonString);  // Lọc bỏ ký tự điều khiển
  
  await File(filePath).writeAsString(cleanedJson);
}