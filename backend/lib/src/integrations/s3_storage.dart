import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:backend/src/config/env.dart';

class S3Storage {
  S3Storage({
    required this.endpoint,
    required this.publicEndpoint,
    required this.region,
    required this.bucket,
    required this.accessKey,
    required this.secretKey,
  });

  factory S3Storage.fromEnv() {
    final env = Env.load();

    final bucket = env.get('S3_BUCKET');
    final accessKey = env.get('S3_ACCESS_KEY');
    final secretKey = env.get('S3_SECRET_KEY');

    return S3Storage(
      endpoint: env.get(
        'S3_ENDPOINT',
        defaultValue: 'https://s3.twcstorage.ru',
      ),
      publicEndpoint: env.get(
        'S3_PUBLIC_ENDPOINT',
        defaultValue: 'https://s3.twcstorage.ru',
      ),
      region: env.get(
        'S3_REGION',
        defaultValue: 'ru-1',
      ),
      bucket: bucket,
      accessKey: accessKey,
      secretKey: secretKey,
    );
  }

  final String endpoint;
  final String publicEndpoint;
  final String region;
  final String bucket;
  final String accessKey;
  final String secretKey;

  Future<String> uploadBytes({
    required String key,
    required List<int> bytes,
    required String contentType,
  }) async {
    final uri = Uri.parse('$endpoint/$bucket/$key');

    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(
        AWSCredentials(accessKey, secretKey),
      ),
    );

    final scope = AWSCredentialScope(
      region: region,
      service: AWSService.s3,
    );

    final request = AWSHttpRequest(
      method: AWSHttpMethod.put,
      uri: uri,
      headers: {
        AWSHeaders.host: uri.host,
        AWSHeaders.contentType: contentType,
        'x-amz-acl': 'public-read',
      },
      body: bytes,
    );

    final signedRequest = await signer.sign(
      request,
      credentialScope: scope,
    );

    final client = AWSHttpClient();
    final response = await client.send(signedRequest).response;
    final responseBody = await response.decodeBody();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'S3 upload failed: ${response.statusCode} $responseBody',
      );
    }

    return '$publicEndpoint/$bucket/$key';
  }
}
