/// 2D QuadTree — viewport-based node culling (O(log n) queries)
library;

/// Axis-aligned bounding rectangle
class QRect {
  const QRect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get midX => (left + right) / 2;
  double get midY => (top + bottom) / 2;

  bool contains(double x, double y) =>
      x >= left && x <= right && y >= top && y <= bottom;

  bool intersects(QRect other) =>
      left < other.right &&
      right > other.left &&
      top < other.bottom &&
      bottom > other.top;

  QRect get nw => QRect(left: left, top: top, right: midX, bottom: midY);
  QRect get ne => QRect(left: midX, top: top, right: right, bottom: midY);
  QRect get sw => QRect(left: left, top: midY, right: midX, bottom: bottom);
  QRect get se => QRect(left: midX, top: midY, right: right, bottom: bottom);
}

class _Entry<T> {
  const _Entry(this.item, this.x, this.y);
  final T item;
  final double x;
  final double y;
}

/// Generic QuadTree — insert by point, query by rect.
/// Insert item by (x, y) point.
/// Query all items whose point falls within a QRect.
class QuadTree<T> {
  QuadTree(this.boundary, {this.capacity = 8});

  final QRect boundary;

  /// Max items per node before subdivision
  final int capacity;

  final List<_Entry<T>> _items = [];
  QuadTree<T>? _nw, _ne, _sw, _se;
  bool _divided = false;

  void insert(T item, double x, double y) {
    if (!boundary.contains(x, y)) return;
    if (!_divided && _items.length < capacity) {
      _items.add(_Entry(item, x, y));
      return;
    }
    if (!_divided) _subdivide();
    _nw!.insert(item, x, y);
    _ne!.insert(item, x, y);
    _sw!.insert(item, x, y);
    _se!.insert(item, x, y);
  }

  void _subdivide() {
    _nw = QuadTree(boundary.nw, capacity: capacity);
    _ne = QuadTree(boundary.ne, capacity: capacity);
    _sw = QuadTree(boundary.sw, capacity: capacity);
    _se = QuadTree(boundary.se, capacity: capacity);
    _divided = true;
    // Migrate existing items into children
    for (final e in _items) {
      _nw!.insert(e.item, e.x, e.y);
      _ne!.insert(e.item, e.x, e.y);
      _sw!.insert(e.item, e.x, e.y);
      _se!.insert(e.item, e.x, e.y);
    }
    _items.clear();
  }

  /// Returns all items whose insertion point falls inside [range]
  List<T> query(QRect range) {
    final result = <T>[];
    if (!boundary.intersects(range)) return result;
    for (final e in _items) {
      if (range.contains(e.x, e.y)) result.add(e.item);
    }
    if (_divided) {
      result.addAll(_nw!.query(range));
      result.addAll(_ne!.query(range));
      result.addAll(_sw!.query(range));
      result.addAll(_se!.query(range));
    }
    return result;
  }
}
