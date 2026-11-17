import '../models/models.dart';

/// Client-side analyzer that evaluates vitals against predefined clinical
/// ranges to give immediate feedback in the UI.
class AnalysisItem {
  final String metric;
  final String value;
  final HealthStatus status;
  final String message;
  const AnalysisItem(this.metric, this.value, this.status, this.message);
}

class AnalysisResult {
  final List<AnalysisItem> items;
  const AnalysisResult(this.items);

  HealthStatus get overall {
    if (items.any((e) => e.status == HealthStatus.critical)) return HealthStatus.critical;
    if (items.any((e) => e.status == HealthStatus.warning)) return HealthStatus.warning;
    if (items.every((e) => e.status == HealthStatus.optimal)) return HealthStatus.optimal;
    return HealthStatus.normal;
  }

  int get score {
    var s = 100.0;
    for (final i in items) {
      s -= switch (i.status) {
        HealthStatus.optimal => 0,
        HealthStatus.normal => 3,
        HealthStatus.warning => 12,
        HealthStatus.critical => 25,
      };
    }
    return s.clamp(0, 100).round();
  }

  String get summary => switch (overall) {
        HealthStatus.optimal => 'All your vitals are in the optimal range. Keep up the great routine!',
        HealthStatus.normal => 'Your vitals look healthy overall with a few areas to keep an eye on.',
        HealthStatus.warning => 'Some readings are outside the healthy range. Consider lifestyle adjustments.',
        HealthStatus.critical => 'Critical readings detected. Your doctor has been notified automatically.',
      };
}

class HealthAnalyzer {
  static AnalysisResult analyze({
    required int systolic,
    required int diastolic,
    required int heartRate,
    required int glucose,
    required double waterLiters,
    required double sleepHours,
    required int calories,
  }) {
    final items = <AnalysisItem>[];

    // Blood pressure
    HealthStatus bp;
    String bpMsg;
    if (systolic >= 180 || diastolic >= 120) {
      bp = HealthStatus.critical;
      bpMsg = 'Hypertensive crisis range. Seek care immediately.';
    } else if (systolic >= 140 || diastolic >= 90) {
      bp = HealthStatus.warning;
      bpMsg = 'Stage 2 hypertension range.';
    } else if (systolic >= 120 || diastolic >= 80) {
      bp = HealthStatus.normal;
      bpMsg = 'Slightly elevated. Reduce sodium & stress.';
    } else if (systolic < 90 || diastolic < 60) {
      bp = HealthStatus.warning;
      bpMsg = 'Low blood pressure. Stay hydrated.';
    } else {
      bp = HealthStatus.optimal;
      bpMsg = 'Healthy blood pressure.';
    }
    items.add(AnalysisItem('Blood Pressure', '$systolic/$diastolic mmHg', bp, bpMsg));

    // Heart rate
    final hr = heartRate > 130 || heartRate < 45
        ? HealthStatus.critical
        : heartRate > 100 || heartRate < 55
            ? HealthStatus.warning
            : heartRate <= 80
                ? HealthStatus.optimal
                : HealthStatus.normal;
    items.add(AnalysisItem('Heart Rate', '$heartRate bpm', hr, switch (hr) {
      HealthStatus.critical => 'Heart rate is dangerously out of range.',
      HealthStatus.warning => heartRate > 100 ? 'Tachycardia range — rest and re-measure.' : 'Bradycardia range — monitor closely.',
      HealthStatus.optimal => 'Excellent resting heart rate.',
      HealthStatus.normal => 'Within the normal resting range.',
    }));

    // Glucose (fasting mg/dL)
    final gl = glucose >= 250 || glucose < 54
        ? HealthStatus.critical
        : glucose >= 126 || glucose < 70
            ? HealthStatus.warning
            : glucose >= 100
                ? HealthStatus.normal
                : HealthStatus.optimal;
    items.add(AnalysisItem('Glucose', '$glucose mg/dL', gl, switch (gl) {
      HealthStatus.critical => 'Glucose critically out of range.',
      HealthStatus.warning => glucose < 70 ? 'Low sugar — take fast-acting carbs.' : 'Diabetic range — consult your doctor.',
      HealthStatus.normal => 'Prediabetic range. Watch your carbs.',
      HealthStatus.optimal => 'Healthy fasting glucose.',
    }));

    final w = waterLiters >= 2.5
        ? HealthStatus.optimal
        : waterLiters >= 1.8
            ? HealthStatus.normal
            : HealthStatus.warning;
    items.add(AnalysisItem('Hydration', '${waterLiters.toStringAsFixed(1)} L', w,
        w == HealthStatus.warning ? 'You are under-hydrated today.' : 'Hydration on track.'));

    final s = sleepHours >= 7 && sleepHours <= 9
        ? HealthStatus.optimal
        : sleepHours >= 6
            ? HealthStatus.normal
            : HealthStatus.warning;
    items.add(AnalysisItem('Sleep', '${sleepHours.toStringAsFixed(1)} h', s,
        s == HealthStatus.warning ? 'Sleep debt detected. Aim for 7–9h.' : 'Restorative sleep duration.'));

    final c = calories > 3200 || calories < 1200
        ? HealthStatus.warning
        : calories >= 1800 && calories <= 2500
            ? HealthStatus.optimal
            : HealthStatus.normal;
    items.add(AnalysisItem('Calories', '$calories kcal', c,
        c == HealthStatus.warning ? 'Intake is outside the recommended range.' : 'Balanced energy intake.'));

    return AnalysisResult(items);
  }
}
