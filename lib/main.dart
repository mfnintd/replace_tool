import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:replace_tool/config.dart';
import 'package:replace_tool/hehe.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainApp());
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  TextEditingController inputController = TextEditingController();
  TextEditingController outputController = TextEditingController();

  Future<List<FileSystemEntity>> getFilesInFolder(String folderPath) async {
    final directory = Directory(folderPath);
    if (await directory.exists()) {
      return directory.listSync(); // Lấy danh sách tệp và thư mục con
    }
    return [];
  }

  Future<void> _pickFolder(TextEditingController controller) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        controller.text = selectedDirectory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Replace tool')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: inputController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Input Folder',
                suffixIcon: IconButton(icon: Icon(Icons.folder_open), onPressed: () => _pickFolder(inputController)),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: outputController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Output Folder',
                suffixIcon: IconButton(icon: Icon(Icons.folder_open), onPressed: () => _pickFolder(outputController)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                debugPrint("replace");
                replace(context, inputController.text, outputController.text);
              },
              child: Text("Replace!"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> replace(BuildContext context, String inputFolder, String outputFolder) async {
    final files = await getFilesInFolder(inputFolder);
    for (var file in files) {
      handleFile(file, outputFolder);
    }
  }

  Future<void> handleFile(FileSystemEntity file, String outputFolder) async {
    if (file is File) {
      try {
        List<Map<String, Object>> res = [];
        String content = (await file.readAsString());
        var jsonData = json.decode(content);
        for (var obj in jsonData) {
          Map<String, String> newObj = {};
          for (var key in obj.keys) {
            newObj[key] = obj[key] as String? ?? "";
          }
          newObj['content'] = cleanJsonString(newObj['content']!);
          newObj['value'] = cleanJsonString(newObj['value']!);
          if (newObj["value"]?.isNotEmpty == true) {
            var configRandomValue = configRandom[newObj["value"]!];
            if (configRandomValue != null) {
              final tmp = configRandomValue[Random().nextInt(configRandomValue.length)];
              newObj["content"] = newObj["content"]!.replaceFirst(newObj["value"]!, tmp);
              newObj["value"] = tmp;
            }
            newObj["money_value"] = configValue[newObj["value"]!] ?? "";
          }
          res.add(newObj);
        }
        debugPrint(file.path.split("/").last);
        if (outputFolder.isNotEmpty) {
          saveJsonToFile(outputFolder, file.path.split(Platform.pathSeparator).last, res);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return;
  }
}

//   Future<void> exportConfig() async {
//     Map<String, Object> res = {};
//     res["content"] = contentController.text;
//     res["type"] = typeController.text;
//     res["category"] = categoryDropdownValue;
//     res["subcategory"] = subcategoryDropdownValue;
//     res["ratio"] = ratio;
//     res["title"] = title.map((e) => e.text).toList();
//     res["titleSelected"] = titleSelected;
//     res["words"] = arrs.map((e) => e.map((e2) => e2.text).toList()).toList();
//     res["deletes"] = deletes.map((e) => e.map((e2) => e2.map((e3) => e3).toList()).toList()).toList();
//     res["version"] = versionController.text;
//     res["quantity"] = quantityController.text;

//     fileName = "${versionController.text}_${categoryDropdownValue}_${subcategoryDropdownValue}_${quantityController.text}";

//     String? resultPath = await FilePicker.platform.saveFile(fileName: "$fileName.tdcf", type: FileType.any);
//     if (resultPath != null) {
//       File(resultPath).writeAsStringSync(json.encode(res));
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lưu cài đặt thành công")));
//     }
//   }

//   Future<void> exportFile() async {
//     String? resultPath = await FilePicker.platform.saveFile(
//       fileName: "${fileName ?? "${versionController.text}_${categoryDropdownValue}_${subcategoryDropdownValue}_${quantityController.text}"}.json",
//       type: FileType.any,
//     );

//     if (resultPath != null) {
//       showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));
//       await gen(
//         context,
//         arrs,
//         ratio,
//         contentController,
//         typeController,
//         categoryDropdownValue,
//         subcategoryDropdownValue,
//         title,
//         titleSelected,
//         resultPath,
//         int.tryParse(quantityController.text) ?? 0,
//         deletes,
//       );
//       Navigator.pop(context);
//     }
//   }

//   Future<void> loadConfig() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     try {
//       if (result != null) {
//         var file = File(result.files.single.path!);
//         fileName = result.files.single.name.split('.').first;
//         final String response = await file.readAsString(); //await rootBundle.loadString(result.files.single.path!);
//         final data = await json.decode(response) as Map<String, dynamic>;
//         // print(data["words"]);
//         arrs =
//             (data["words"] as List<dynamic>).map((e) {
//               return (e as List<dynamic>).map((e2) => TextEditingController(text: e2 as String)).toList();
//             }).toList();
//         contentController.text = data["content"] as String;
//         typeController.text = data["type"] as String;
//         categoryDropdownValue = data["category"] as String;
//         subcategoryDropdownValue = data["subcategory"] as String;
//         ratio = (data["ratio"] as List<dynamic>).map((e) => e as int).toList();
//         title = (data["title"] as List<dynamic>).map((e) => TextEditingController(text: e as String)).toList();
//         titleSelected = (data["titleSelected"] as List<dynamic>? ?? (List.generate(title.length, (_) => true))).map((e) => e as bool).toList();
//         deletes =
//             (data["deletes"] as List<dynamic>? ?? List.generate(arrs.length, (index) => List.generate(arrs[index].length, (index2) => [])))
//                 .map((e1) => (e1 as List<dynamic>).map((e2) => (e2 as List<dynamic>).map((e3) => (e3 as String)).toList()).toList())
//                 .toList();
//         versionController.text = data["version"] as String;
//         quantityController.text = data["quantity"] as String;
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Không hợp lệ")));
//     }
//     setState(() {});
//   }
// }

// Future<void> gen(
//   BuildContext context,
//   List<List<TextEditingController>> arrs,
//   List<int> ratio,
//   TextEditingController contentController,
//   TextEditingController typeController,
//   String categoryDropdownValue,
//   String subcategoryDropdownValue,
//   List<TextEditingController> title,
//   List<bool> titleSelected,
//   String resultPath,
//   int quantity,
//   List<List<List<String>>> deletes,
// ) async {
//   List<List<String>> realArrs = [];
//   for (int i = 0; i < arrs.length; i++) {
//     var arr = arrs[i];
//     arr.shuffle();
//     arr = arr.sublist(0, (arr.length * ratio[i] + 99) ~/ 100);
//     realArrs.add(arr.map((e) => e.text).toList());
//   }
//   var indexLst = List.generate(realArrs.length, (_) => 0);
//   List<Map<String, Object>> result = [];

//   var curDelete = <String>[];

//   while (quantity > 0) {
//     quantity--;
//     // double progress = 1;
//     // for (int i = 0; i < indexLst.length; i++) {
//     //   progress *= (indexLst[i] + 1) / (realArrs.length + 1);
//     // }
//     // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$progress%")));

//     //print(List.generate(indexLst.length, (index) => realArrs[index][indexLst[index]]));
//     Map<String, Object> tmp = {};
//     var content = List.generate(
//       indexLst.length,
//       // (index) => (takeRatio(ratio[index])) ? realArrs[index][indexLst[index]] : "",
//       (index) {
//         final tmp = Random().nextInt(realArrs[index].length);
//         final tmp2 = realArrs[index][tmp];
//         if (curDelete.contains(tmp2)) {
//           curDelete = [];
//           return "";
//         }
//         if (!takeRatio(ratio[index])) {
//           curDelete = [];
//           return "";
//         }
//         curDelete = deletes[index][tmp];
//         return tmp2;
//       },
//     );
//     // for (int i = 0; i < content.length; i++) {
//     //   content[i] = (Random().nextInt(10) < ratio[i] ~/ 10) ? content[i] : "";
//     // }
//     // print(content);
//     tmp["content"] = content.where((e) => e != "").join(" ");
//     tmp["type"] = typeController.text;
//     tmp["category"] = categoryDropdownValue;
//     tmp["subcategory"] = subcategoryDropdownValue;
//     for (int i = 0; i < indexLst.length; i++) {
//       // tmp[title[i].text] = realArrs[i][indexLst[i]];
//       if (titleSelected[i]) {
//         tmp[title[i].text] = content[i];
//       }
//     }
//     result.add(tmp);
//     // int cur = 0;
//     // while (cur < realArrs.length && realArrs[cur].length - 1 == indexLst[cur]) {
//     //   indexLst[cur] = 0;
//     //   cur++;
//     // }
//     // if (cur == realArrs.length) {
//     //   break;
//     // }
//     // indexLst[cur]++;
//   }
//   await Isolate.run(() => File(resultPath).writeAsStringSync(json.encode(result)));
//   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Xuất thành công")));
// }

// extension SwappableList<E> on List<E> {
//   void swap(int first, int second) {
//     final temp = this[first];
//     this[first] = this[second];
//     this[second] = temp;
//   }
// }

// bool takeRatio(int ratio) {
//   return Random().nextInt(100) < ratio;
// }
