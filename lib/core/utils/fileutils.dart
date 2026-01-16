import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:wind_power_system/core/utils/print_utils.dart';


/// 将数据内容写入到指定文件中
void writeToFile(String fileName, String content) async{
  Directory documentsDir = await getApplicationDocumentsDirectory();
  String documentsPath = documentsDir.path;
  File file = File('$documentsPath/$fileName');
  if(!file.existsSync()) {
    file.createSync();
  }
  cjPrint("写入文件路径:${file.path}");
  await file.writeAsString(content,mode: FileMode.write);
}

/// 读取指定文件中的数据
Future<String> readContentFromFile(File file)async{
  if(!file.existsSync()){
    return "";
  }
  String notes = await file.readAsString();
  return notes;
}