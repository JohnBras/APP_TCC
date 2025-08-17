import 'package:flutter/foundation.dart';

class DashboardFilter extends ChangeNotifier {
  int year;
  int month; // 1..12

  DashboardFilter({required this.year, required this.month});

  void setYear(int y) {
    if (y != year) {
      year = y;
      notifyListeners();
    }
  }

  void setMonth(int m) {
    if (m != month) {
      month = m;
      notifyListeners();
    }
  }

  void setYearMonth(int y, int m) {
    final changed = (y != year) || (m != month);
    year = y;
    month = m;
    if (changed) notifyListeners();
  }
}
