FROM ubuntu:mantic
MAINTAINER Ppamo <pablo@ppamo.cl>

RUN apt update && apt -y upgrade && apt install -y inkscape ghostscript
COPY convert.sh /bin/convert.sh
RUN chmod +x /bin/convert.sh
WORKDIR /res
CMD ["sh", "/bin/convert.sh"]
