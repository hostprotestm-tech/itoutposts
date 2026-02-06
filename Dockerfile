FROM ubuntu:24.04

RUN apt-get update && apt-get install -yq gawk git

COPY parser.sh /usr/local/bin/parser.sh

RUN chmod +x /usr/local/bin/parser.sh

CMD ["tail", "-f", "/dev/null"]
