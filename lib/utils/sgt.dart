import 'package:intl/intl.dart';

const _sgtOffset = Duration(hours: 8);

final _fmtFull = DateFormat('d MMMM yyyy, HH:mm');
final _fmtShort = DateFormat('dd MMM yyyy, HH:mm');
final _fmtChart = DateFormat('MMM d');

DateTime toSGT(DateTime dt) {
  final utc = dt.isUtc ? dt : dt.toUtc();
  return utc.add(_sgtOffset);
}

String formatSGT(DateTime dt, {String? pattern}) {
  final sgt = toSGT(dt);
  if (pattern != null) return DateFormat(pattern).format(sgt);
  return _fmtFull.format(sgt);
}

String formatSGTShort(DateTime dt) {
  return _fmtShort.format(toSGT(dt));
}

String formatSGTChartLabel(DateTime dt) {
  return _fmtChart.format(toSGT(dt));
}
