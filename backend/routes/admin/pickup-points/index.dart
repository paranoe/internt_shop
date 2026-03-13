import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return Response.json(
    body: {
      'route': '/admin/pickup-points',
      'method': context.request.method.value,
      'status': 'ok',
      'note': 'TODO implement'
    },
  );
}





