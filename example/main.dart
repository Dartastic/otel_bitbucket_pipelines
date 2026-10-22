// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_bitbucket_pipelines/otel_bitbucket_pipelines.dart';

/// Traces Bitbucket Pipelines calls with OpenTelemetry.
///
/// `otel_bitbucket_pipelines` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Bitbucket Pipelines call in
/// [tracedBitbucketPipelines]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'bitbucket-pipelines-example');

  // Traces a Bitbucket Pipelines call.
  final bitbucketPipelinesId = await tracedBitbucketPipelines<String>(
    operation: 'create',
    invoke: () async {
      // Make the Bitbucket Pipelines call here, then report what it returned.
      const id = 'bitbucket_pipelines_8f3a2c';
      return const BitbucketPipelinesCallResult(
          value: id,
          result: BitbucketPipelinesResult(
              workspace: 'example',
              repository: 'example',
              pipelineUuid: 'pipelineuu_8f3a2c',
              buildNumber: 1,
              pipelineStatus: 'succeeded',
              stepUuid: 'stepuu_8f3a2c',
              stepName: 'example',
              stepStatus: 'succeeded',
              runnerLabel: 'example',
              branch: 'example',
              commit: 'example',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info(
      'tracedBitbucketPipelines create returned $bitbucketPipelinesId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutBitbucketPipelinesInstrumentationAsync.
  await runWithoutBitbucketPipelinesInstrumentationAsync(
    () => tracedBitbucketPipelines<String>(
      operation: 'create',
      invoke: () async {
        const id = 'bitbucket_pipelines_8f3a2c';
        return const BitbucketPipelinesCallResult(
            value: id,
            result: BitbucketPipelinesResult(
                workspace: 'example',
                repository: 'example',
                pipelineUuid: 'pipelineuu_8f3a2c',
                buildNumber: 1,
                pipelineStatus: 'succeeded',
                stepUuid: 'stepuu_8f3a2c',
                stepName: 'example',
                stepStatus: 'succeeded',
                runnerLabel: 'example',
                branch: 'example',
                commit: 'example',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
