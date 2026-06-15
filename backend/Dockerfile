FROM dart:stable

WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

COPY . .

RUN dart pub global activate dart_frog_cli
RUN dart pub global run dart_frog_cli:dart_frog build

RUN dart compile exe build/bin/server.dart -o server

EXPOSE 8080

CMD ["./server"]