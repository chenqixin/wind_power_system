class PageModel<T> {
  int hasNext =0;
  int total = 0;
  int pageSize = 0;
  int pageNumber = 0;
  List<T>? list;

  PageModel({
    this.total = 0,
    this.pageSize = 0,
    this.pageNumber = 0,
    this.list,
    this.hasNext =0,
  });

  PageModel.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    if (json["total"] is int) {
      total = json["total"];
    }
    if (json["pageSize"] is int) {
      pageSize = json["pageSize"];
    }

    if (json["currPage"] is int) {
      pageNumber = json["currPage"];
    }
    if (json["list"] is List) {
      list = json["list"] == null
          ? null
          : (json["list"] as List)
              .map((e) => fromJsonT(e as Map<String, dynamic>))
              .toList();
    }
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["total"] = total;
    data["pageSize"] = pageSize;
    data["currPage"] = pageNumber;
    if (list != null) {
      data["list"] = list?.map((e) => toJsonT(e)).toList();
    }
    return data;
  }
}
