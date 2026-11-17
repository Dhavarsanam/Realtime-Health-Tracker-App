import 'package:flutter_test/flutter_test.dart';
import 'package:project1/core/analyzer/health_analyzer.dart';
import 'package:project1/core/models/models.dart';

void main() {
  test('analyzer flags critical readings', () {
    final r = HealthAnalyzer.analyze(systolic: 185, diastolic: 110, heartRate: 72, glucose: 95, waterLiters: 2.6, sleepHours: 8, calories: 2000);
    expect(r.overall, HealthStatus.critical);
  });

  test('analyzer reports optimal for healthy readings', () {
    final r = HealthAnalyzer.analyze(systolic: 112, diastolic: 72, heartRate: 66, glucose: 90, waterLiters: 2.8, sleepHours: 8, calories: 2100);
    expect(r.overall, HealthStatus.optimal);
    expect(r.score, 100);
  });
}
