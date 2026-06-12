class DeterministicRandom {
  DeterministicRandom(int seed) : _state = seed & _mask;

  static const int _mask = 0x7fffffff;
  static const int _multiplier = 1103515245;
  static const int _increment = 12345;

  int _state;

  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(max, 'max', 'Must be positive.');
    }
    _state = ((_state * _multiplier) + _increment) & _mask;
    return _state % max;
  }

  int nextOneBasedRoll(int max) {
    return nextInt(max) + 1;
  }
}
