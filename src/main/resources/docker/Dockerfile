FROM openjdk:11
WORKDIR /app
COPY script.sh .
RUN apt-get update && apt-get install -y bc

ENTRYPOINT ["./script.sh"]


