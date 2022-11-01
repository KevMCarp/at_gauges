part of at_time_series_chart;

/// Main state of the charts. Painter will use this as state and it will format
/// chart depending on options.
///
/// [itemOptions] Contains all modifiers for separate bar item
///
/// [behaviour] How chart reacts and sizes itself
///
/// [foregroundDecorations] and [backgroundDecorations] decorations that aren't
/// connected directly to the chart but can show important info (Axis, target line...)
///
/// More different decorations can be added by extending [DecorationPainter]
class ChartState<T> {
  /// Chart state constructor
  ChartState(
    this.data, {
    this.itemOptions = const BarItemOptions(),
    this.behaviour = const ChartBehaviour(),
    this.backgroundDecorations = const <DecorationPainter>[],
    this.foregroundDecorations = const <DecorationPainter>[],
    ChartDataRendererFactory<T?>? dataRenderer,
  })  : assert(data.isNotEmpty, 'No items!'),
        defaultPadding = EdgeInsets.zero,
        defaultMargin = EdgeInsets.zero,
        dataRenderer = dataRenderer ?? defaultItemRenderer<T>(itemOptions) {
    /// Set default padding and margin, decorations padding and margins will be added to this value
    _setUpDecorations();
  }

  ChartState._lerp(
    this.data, {
    this.itemOptions = const BarItemOptions(),
    this.behaviour = const ChartBehaviour(),
    this.backgroundDecorations = const [],
    this.foregroundDecorations = const [],
    required this.dataRenderer,
    required this.defaultMargin,
    required this.defaultPadding,
  }) {
    _initDecorations();
  }

  // Data layer
  /// [ChartData] data that chart will show
  final ChartData<T> data;

  final ChartDataRendererFactory<T?> dataRenderer;

  // Geometry layer
  /// [ItemOptions] define how each item is painted
  final ItemOptions itemOptions;

  /// [ChartBehaviour] define how chart behaves and how it should react
  final ChartBehaviour behaviour;

  /// ------

  // Theme layer
  /// Decorations for chart background, the go below the items
  final List<DecorationPainter> backgroundDecorations;

  /// Decorations for chart foreground, they are drawn last, and the go above items
  final List<DecorationPainter> foregroundDecorations;

  /// Margin of chart drawing area where items are drawn. This is so decorations
  /// can be placed outside of the chart drawing area without actually scaling the chart.
  EdgeInsets defaultMargin;

  /// Padding is used for decorations that want other decorations to be drawn on them.
  /// Unlike [defaultMargin] decorations can draw inside the padding area.
  EdgeInsets defaultPadding;

  /// Get all decorations. This will return list of [backgroundDecorations] and [foregroundDecorations] as one list.
  List<DecorationPainter> get _allDecorations =>
      [...foregroundDecorations, ...backgroundDecorations];

  void _setUpDecorations() {
    _initDecorations();
    _getDecorationsPadding();
    _getDecorationsMargin();
  }

  /// Init all decorations, pass current chart state so each decoration can access data it requires
  /// to set up it's padding and margin values
  void _initDecorations() =>
      _allDecorations.forEach((decoration) => decoration.initDecoration(this));

  /// Get total padding needed by all decorations
  void _getDecorationsMargin() => _allDecorations
      .forEach((element) => defaultMargin += element.marginNeeded());

  /// Get total margin needed by all decorations
  void _getDecorationsPadding() => _allDecorations
      .forEach((element) => defaultPadding += element.paddingNeeded());

  /// For later in case charts will have to animate between states.
  static ChartState<T?> lerp<T>(ChartState<T?> a, ChartState<T?> b, double t) {
    return ChartState<T?>._lerp(
      ChartData.lerp(a.data, b.data, t),
      behaviour: ChartBehaviour.lerp(a.behaviour, b.behaviour, t),
      itemOptions: a.itemOptions.animateTo(b.itemOptions, t),
      // Find background matches, if found, then animate to them, else just show them.
      backgroundDecorations:
          b.backgroundDecorations.map<DecorationPainter>((e) {
        final _match = a.backgroundDecorations
            .firstWhereOrNull((element) => element.isSameType(e));
        if (_match != null) {
          return _match.animateTo(e, t);
        }

        return e;
      }).toList(),
      // Find foreground matches, if found, then animate to them, else just show them.
      foregroundDecorations: b.foregroundDecorations.map((e) {
        final _match = a.foregroundDecorations
            .firstWhereOrNull((element) => element.isSameType(e));
        if (_match != null) {
          return _match.animateTo(e, t);
        }

        return e;
      }).toList(),

      defaultMargin: EdgeInsets.lerp(a.defaultMargin, b.defaultMargin, t) ??
          EdgeInsets.zero,
      defaultPadding: EdgeInsets.lerp(a.defaultPadding, b.defaultPadding, t) ??
          EdgeInsets.zero,
      dataRenderer: t > 0.5 ? b.dataRenderer : a.dataRenderer,
    );
  }

  static ChartDataRendererFactory<T?> defaultItemRenderer<T>(
      ItemOptions itemOptions) {
    return (data) => ChartLinearDataRenderer<T?>(
        data,
        data.items
            .mapIndexed(
              (key, items) => items
                  .map((e) => LeafChartItemRenderer(e, data, itemOptions,
                      arrayKey: key))
                  .toList(),
            )
            .expand((element) => element)
            .toList());
  }
}
