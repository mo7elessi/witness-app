class ResponseError {
  ResponseError({this.error});

  ResponseError.fromJson(dynamic json) {
    error = json['error'];
  }

  String? error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = error;
    return map;
  }
}
