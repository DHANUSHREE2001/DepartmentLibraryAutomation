import 'dart:convert';
import 'dart:io';
import 'package:library_management/Constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

String parser(String data) {
  return data.length.toString() + Header.Split + data;
}

String packet(String id, String handler, String header,
    {String username = "",
    String password = "",
    int permission = 0,
    String isbn = "",
    String bookName = "",
    List<String> author = const [],
    int type = 0,
    int availability = 0,
    String thumbnail = "",
    List<String> searchFilter = const [],
    String category = "",
    String book = "",
    int count = 10,
    String misc = "",
    String sort = "ASC",
    String status = "",
    List<int> range = const [],
    String email = "",
    String volume = "",
    String issue = "",
    String reasons = "",
    int budgetAmt = 0,
    int usedBudgetAmt = 0,
    String budgetType = "",
    String investedOn = "",
    String budgetID = "",
    int expAmt = 0,
    String src = ""}) {
  var data = {
    "ID": id,
    "Handler": handler,
    "Header": header,
    "UserName": username.toLowerCase(),
    "Password": password,
    "Permission": permission,
    "ISBN": isbn,
    "BookName": bookName,
    "Author": author,
    "Type": type,
    "Availability": availability,
    "Thumbnail": thumbnail,
    "SearchFilter": searchFilter,
    "Category": category,
    "Book": book,
    "Count": count,
    "Misc": misc,
    "Sort": sort,
    "Range": range,
    "Status": status,
    "Email": email,
    "Volume": volume,
    "Issue": issue,
    "Reason": reasons,
    "BudgetAmt": budgetAmt,
    "UsedBudgetAmt": usedBudgetAmt,
    "BudgetType": budgetType,
    "InvestedOn": investedOn,
    "BudgetID": budgetID,
    "ExpAmt": expAmt,
    "Src":src
  };

  return jsonEncode(data);
}

Uri webSocket() {
  return Uri.parse("ws:" + ip + ":" + WebPort.toString());
}

void communicate(String packet, Function process) {
  final channel = WebSocketChannel.connect(webSocket());
  channel.sink.add(parser(packet));
  channel.stream.listen((event) async {
    event = event.split(Header.Split)[1];
    var out = jsonDecode(event);
    await process(out);
    channel.sink.close();
  });
}
