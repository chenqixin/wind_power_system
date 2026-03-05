import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:wind_power_system/core/utils/print_utils.dart';


/// 将数据内容写入到指定文件中
void writeToFile(String fileName, String content, {FileMode mode = FileMode.write}) async {
  Directory documentsDir = await getApplicationDocumentsDirectory();
  String documentsPath = documentsDir.path;
  File file = File('$documentsPath/$fileName');
  if (!file.existsSync()) {
    file.createSync(recursive: true);
  }
  cjPrint("写入文件路径:${file.path}");
  await file.writeAsString(content, mode: mode);
}

/// 追加数据到指定文件中
void appendToFile(String fileName, String content) async {
  writeToFile(fileName, content, mode: FileMode.append);
}

/// 读取指定文件中的数据
Future<String> readContentFromFile(File file)async{
  if(!file.existsSync()){
    return "";
  }
  String notes = await file.readAsString();
  return notes;
}