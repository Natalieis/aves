/// Width of the screen edge that responds to a single tap,
/// as a ratio of the screen width.
enum SideTapArea { auto, ten, fifteen, twenty, thirty }

extension ExtraSideTapArea on SideTapArea {
  /// `auto` keeps the historical values: 1/6 in portrait, 1/8 in landscape.
  double ratio({required bool portrait}) => switch (this) {
    .auto => portrait ? 1 / 6 : 1 / 8,
    .ten => .10,
    .fifteen => .15,
    .twenty => .20,
    .thirty => .30,
  };
}
