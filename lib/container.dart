import 'package:google_maps_flutter/google_maps_flutter.dart';

class Bin {
  MarkerId markerId;
  int fullness;
  DateTime nextCollection;

  Bin(this.markerId, this.fullness, this.nextCollection);
}