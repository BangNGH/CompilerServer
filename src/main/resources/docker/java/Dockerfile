FROM openjdk:11
WORKDIR /app
COPY ../batchscript.sh .
RUN apt-get update && apt-get install -y bc

ENTRYPOINT ["./batchscript.sh"]


