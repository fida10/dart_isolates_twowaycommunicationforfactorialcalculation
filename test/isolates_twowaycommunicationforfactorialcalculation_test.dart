import 'package:isolates_twowaycommunicationforfactorialcalculation/isolates_twowaycommunicationforfactorialcalculation.dart';
import 'package:test/test.dart';

void main() {
  test(
      'calculateFactorialInIsolate computes factorial with two-way communication',
      () async {
    var factorialIsolate = await setupFactorialIsolate();

    expect(await factorialIsolate.sendAndReceive(5), equals(120));
    expect(await factorialIsolate.sendAndReceive(7), equals(5040));

    await factorialIsolate.shutdown();
  });
}