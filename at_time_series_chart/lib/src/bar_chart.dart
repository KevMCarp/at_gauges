part of at_time_series_chart;

typedef DataToValue<T> = double Function(T item);
typedef DataToAxis<T> = String Function(int item);

class BarChart<T> extends StatelessWidget {
  BarChart({
    required List<T> data,
    required this.dataToValue,
    this.height = 240.0,
    this.backgroundDecorations,
    this.foregroundDecorations,
    this.chartBehaviour = const ChartBehaviour(),
    this.itemOptions = const BarItemOptions(),
    this.stack = true,
    this.axisMax,
    this.axisMin,
    Key? key,
  })  : _mappedValues = [
          data.map((e) => BarValue<T>(dataToValue(e))).toList(),
        ],
        super(key: key);

  final DataToValue<T> dataToValue;
  final List<List<BarValue<T>>> _mappedValues;
  final double height;

  final bool stack;
  final ItemOptions itemOptions;
  final ChartBehaviour chartBehaviour;
  final List<DecorationPainter>? backgroundDecorations;
  final List<DecorationPainter>? foregroundDecorations;

  final double? axisMin;
  final double? axisMax;

  @override
  Widget build(BuildContext context) {
    final _foregroundDecorations =
        foregroundDecorations ?? <DecorationPainter>[];
    final _backgroundDecorations =
        backgroundDecorations ?? <DecorationPainter>[];

    return AnimatedChart<T>(
      height: height,
      width: MediaQuery.of(context).size.width - 24.0,
      duration: const Duration(milliseconds: 450),
      state: ChartState<T>(
        ChartData(
          _mappedValues,
          valueAxisMaxOver: 1,
          axisMax: axisMax,
          axisMin: axisMin,
        ),
        itemOptions: itemOptions,
        behaviour: chartBehaviour,
        foregroundDecorations: _foregroundDecorations,
        backgroundDecorations: [
          ..._backgroundDecorations,
        ],
      ),
    );
  }
}
