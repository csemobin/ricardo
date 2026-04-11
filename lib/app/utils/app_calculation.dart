class AppCalculation{
  static double killowMeterToMile( kilo ){
    double? val = double.tryParse(kilo);
    return val! * 1.60934;
  }
  static double meterToMile(meter) {
    double? val = double.tryParse(meter);
    return val! * 0.000621371;
  }
}