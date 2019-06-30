FROM centos:7
MAINTAINER Ppamo <pablo@ppamo.cl>

RUN yum -y update && yum -y install inkscape gs
COPY convert.sh /bin/convert.sh
WORKDIR /data
CMD ["sh", "convert.sh"]
