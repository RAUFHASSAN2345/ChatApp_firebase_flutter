class Message {
  Message({
    required this.msg,
    required this.toid,
    required this.read,
    required this.type,
    required this.sent,
    required this.fromid,
  });
  late String msg;
  late String toid;
  late String read;
  late Type type;
  late String sent;
  late String fromid;

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    toid = json['toid'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    sent = json['sent'].toString();
    fromid = json['fromid'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['toid'] = toid;
    data['read'] = read;
    data['type'] = type.name;
    data['sent'] = sent;
    data['fromid'] = fromid;
    return data;
  }
}

enum Type { text, image }
