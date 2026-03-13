import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return Response.json(
    body: {
      'route': '/me/pickup-points/:id',
      'id': id,
      'method': context.request.method,
      'status': 'ok',
      'note': 'TODO implement'
    },
  );
}
