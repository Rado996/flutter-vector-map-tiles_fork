import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'isolate_executor.dart';

import 'direct_executor.dart';
import 'pool_executor.dart';

typedef CancellationCallback = bool Function();

class Job<Q, R> {
  final String name;
  final ComputeCallback<Q, R> computeFunction;
  final Q value;
  final CancellationCallback? cancelled;

  Job(this.name, this.computeFunction, this.value, {this.cancelled});

  bool get isCancelled => cancelled == null ? false : cancelled!();
}

abstract class Executor {
  Future<R> submit<Q, R>(Job<Q, R> job);

  /// submits the given function and value to all isolates in the executor
  List<Future<R>> submitAll<Q, R>(Job<Q, R> job);

  void dispose();
  bool get disposed;
}

class CancellationException implements Exception {
  CancellationException();
}

Executor newExecutor() => kDebugMode
    ? IsolateExecutor()
    : PoolExecutor(concurrency: max(Platform.numberOfProcessors - 2, 1));
