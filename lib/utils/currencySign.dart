import 'dart:io';

import 'package:intl/intl.dart';

String getCurrency() {
  var format = NumberFormat.simpleCurrency(locale: Platform.localeName, name: 'PHP');
  print('Currency Symbol: ${format.currencySymbol}');
  return format.currencySymbol;
}