class BatteryLevel {
  String _id;
  String _status;
  int _level;

  BatteryLevel(this._id, this._status, this._level);

  BatteryLevel.map(dynamic battery) {
    this._id = battery['id'];
    this._status = battery['status'];
    this._level = battery['level'];
  }

  String get id => _id;
  String get status => _status;
  int get level => _level;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['status'] = _status;
    map['level'] = _level;

    return map;
  }

  BatteryLevel.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._status = map['status'];
    this._level = map['level'];
  }
}