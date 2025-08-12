class Brand {
  Brand({this.id = 0, required this.name});
  int id;
  String name;

  Map<String, dynamic> toMap() {
    return {'name': name, "hash": hashCode};
  }

  @override
  int get hashCode => Object.hash(name.toLowerCase(), 0);
}