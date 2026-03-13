import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return Response.json(
    body: {
      'route': '/admin/payment-methods/:id',
      'id': id,
      'method': context.request.method,
      'status': 'ok',
      'note': 'TODO implement'
    },
  );
}
