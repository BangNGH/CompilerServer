FROM mono:latest
RUN apt-get update && apt-get install -y bc
# Copy script.sh vào container
COPY ../batchscript.sh .
RUN chmod +x ../batchscript.sh
# Định nghĩa entrypoint là script.sh
ENTRYPOINT ["./batchscript.sh"]
