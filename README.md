# otel_bitbucket_pipelines

Dartastic OpenTelemetry bridge for Bitbucket Pipelines (CI/CD).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_bitbucket_pipelines/otel_bitbucket_pipelines.dart';

await tracedBitbucketPipelines<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return BitbucketPipelinesCallResult(value: r, result: BitbucketPipelinesResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutBitbucketPipelinesInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
