part of flutter_parse_sdk;

class ParseDecoder {

  List<dynamic> _convertJSONArrayToList(List<dynamic> array) {
    List<dynamic> list = new List();
    array.forEach((value) {
      list.add(decode(value));
    });
    return list;
  }

  Map<String, dynamic> _convertJSONObjectToMap(Map<String, dynamic> object) {
    Map<String, dynamic> map = new Map();
    object.forEach((key, value) {
      map.putIfAbsent(key, () => decode(value));
    });
    return map;
  }

  /// Decode any type value
  dynamic decode(dynamic value) {
    if (value is List) {
      return _convertJSONArrayToList(value);
    }

    if (value is bool) {
      return value;
    }

    if (value is int) {
      return value.toInt();
    }

    if (value is double) {
      return value.toDouble();
    }

    if (value is num) {
      return value;
    }

    if (!(value is Map)) {
      return value;
    }

    Map map = value;
    if (!map.containsKey("__type")) {
      return _convertJSONObjectToMap(map);
    }

    switch (map["__type"]) {
      case "Date":
        String iso = map["iso"];
        return stringToDateTime(iso);
      case "Bytes":
        String val = map["base64"];
        return base64.decode(val);
      case "Pointer":
        String className = map["className"];
        return new ParseObject(className)..fromJson(map);
      case "Object":
        String className = map["className"];
        if (className == '_User') {
          return new ParseUser(map['username'], map['password'], map['emailaddress'])..fromJson(map);
        }
        return new ParseObject(className)..fromJson(map);
      case "GeoPoint":
        num latitude = map["latitude"] ?? 0.0;
        num longitude = map["longitude"] ?? 0.0;
        return new ParseGeoPoint(latitude: latitude.toDouble(), longitude: longitude.toDouble());
    }

    return null;
  }
}