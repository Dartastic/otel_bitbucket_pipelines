// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_bitbucket_pipelines_suppression.dart';

class BitbucketPipelinesResult {
  const BitbucketPipelinesResult({
    this.workspace,
    this.repository,
    this.pipelineUuid,
    this.buildNumber,
    this.pipelineStatus,
    this.stepUuid,
    this.stepName,
    this.stepStatus,
    this.runnerLabel,
    this.branch,
    this.commit,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? workspace;
  final String? repository;
  final String? pipelineUuid;
  final int? buildNumber;
  final String? pipelineStatus;
  final String? stepUuid;
  final String? stepName;
  final String? stepStatus;
  final String? runnerLabel;
  final String? branch;
  final String? commit;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class BitbucketPipelinesCallResult<T> {
  const BitbucketPipelinesCallResult({required this.value, this.result});
  final T value;
  final BitbucketPipelinesResult? result;
}

Future<T> tracedBitbucketPipelines<T>({
  required String operation,
  required Future<BitbucketPipelinesCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (bitbucketPipelinesInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t =
      tracer ?? OTel.tracerProvider().getTracer('otel_bitbucket_pipelines');
  final span = t.startSpan('bbpipelines $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'bitbucket');
    span.setStringAttribute('cicd.platform', 'bitbucket');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.workspace != null) {
        span.setStringAttribute('bitbucket.workspace', res.workspace!);
      }
      if (res.repository != null) {
        span.setStringAttribute('bitbucket.repository', res.repository!);
      }
      if (res.pipelineUuid != null) {
        span.setStringAttribute('cicd.pipeline.run.id', res.pipelineUuid!);
      }
      if (res.buildNumber != null) {
        span.setIntAttribute('cicd.pipeline.run.name', res.buildNumber!);
      }
      if (res.pipelineStatus != null) {
        span.setStringAttribute('cicd.pipeline.run.state', res.pipelineStatus!);
      }
      if (res.stepUuid != null) {
        span.setStringAttribute('cicd.task.run.id', res.stepUuid!);
      }
      if (res.stepName != null) {
        span.setStringAttribute('cicd.task.name', res.stepName!);
      }
      if (res.stepStatus != null) {
        span.setStringAttribute('cicd.task.run.state', res.stepStatus!);
      }
      if (res.runnerLabel != null) {
        span.setStringAttribute('cicd.worker.name', res.runnerLabel!);
      }
      if (res.branch != null) {
        span.setStringAttribute('vcs.ref.head.name', res.branch!);
      }
      if (res.commit != null) {
        span.setStringAttribute('vcs.ref.head.revision', res.commit!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('bbpipelines.error.code', res.errorCode!);
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
            ErrorResource.errorType.key, res.errorCode ?? 'bitbucket.error');
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
