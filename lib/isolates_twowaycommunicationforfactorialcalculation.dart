/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'dart:async';
import 'dart:isolate';

export 'src/isolates_twowaycommunicationforfactorialcalculation_base.dart';

/*
Revised Practice Question 1: Two-Way Communication for Factorial Calculation

Task:

Modify calculateFactorialInIsolate to perform factorial calculation
 in a separate isolate with two-way communication. 
 The main isolate can send multiple numbers to the 
 spawned isolate and receive the factorial result for each.

 */

class FactorialIsolateInAsync {
  final receivedFromWorker = ReceivePort();
  SendPort? sendToWorker;
  Stream? streamFromWorker;
  Isolate? workerIsolate;
  StreamSubscription? streamSubscription;
  bool twoWayConnectionEstablished = false;

  FactorialIsolateInAsync() {
    streamFromWorker = receivedFromWorker.asBroadcastStream();
  }

  Future<dynamic> sendAndReceive(int input) async {
    Completer completerForMain = Completer();
    workerIsolate ??=
        await Isolate.spawn(_factorialWorker, receivedFromWorker.sendPort);

    if (twoWayConnectionEstablished) {
      sendToWorker?.send(input);
    } else {
      print('Two way connection has not been established yet.');
    }

    streamSubscription = streamFromWorker?.listen((event) {
      print('Mesage from worker isolate: $event');

      if(event is SendPort){
        sendToWorker = event;
        twoWayConnectionEstablished = true;
        print('Two way connection established!');
        sendToWorker?.send(input);
      }

      if(event is int){
        print('Received factorial result from worker.');
        completerForMain.complete(event);
        streamSubscription?.cancel();
      }

    });

    return completerForMain.future;
  }

  void shutdown(){
    receivedFromWorker.close();
    workerIsolate?.kill();
    workerIsolate == null;
  }
}

Future<void> _factorialWorker(SendPort sendToMain) async {
  print('Worker isolate created!');
  ReceivePort workerReceiver = ReceivePort();
  sendToMain.send(workerReceiver.sendPort);

  workerReceiver.listen((message) {
    print('Message from main isolate: $message');

    if (message is int) {
      print('Processing integer and returning factorial.');
      sendToMain.send(calculateFactorial(message));
    }
  });
}

int calculateFactorial(int input) {
  int ans = 1;
  while (input > 1) {
    ans *= input;
    input--;
  }
  return ans;
}

setupFactorialIsolate() async {
  return FactorialIsolateInAsync();
}
