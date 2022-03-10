FROM centos:centos7.9.2009
MAINTAINER Ppamo <pablo@ppamo.cl>

RUN yum -y update && yum -y install inkscape ghostscript
COPY convert.sh /bin/convert.sh
WORKDIR /data
CMD ["sh", "convert.sh"]
