class Yarn {
  Yarn({
    required this.color,
    this.brand = "Unknown",
    this.material = "Unknown",
    this.minHook = 0,
    this.maxHook = 0,
    this.thickness = 0,
    this.nbOfSkeins = 1,
  });
  String brand; // ex : "my brand"
  String material; // ex : "coton"
  double thickness; // ex : "3mm"
  double minHook; // ex : "2.5mm"
  double maxHook; // ex : "3.5mm"
  int color; // ex : 0xFFFFC107
  int nbOfSkeins; // ex : 1
}
