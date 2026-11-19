FROM dart:stable

WORKDIR /app

COPY server.dart ./
COPY lib ./lib

EXPOSE 10000

CMD ["dart", "run", "server.dart"]
