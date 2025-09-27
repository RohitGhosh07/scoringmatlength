class EndStats {
  final List<int> ringCounts; // index 0..4
  final int wood;
  final Map<String, int> perPlayerShots;
  const EndStats({
    required this.ringCounts,
    required this.wood,
    required this.perPlayerShots,
  });
}
