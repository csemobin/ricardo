class AppCalculation{
  static double killowMeterToMile( kilo ){
    double? val = double.tryParse(kilo);
    return val! * 1.60934;
  }
}