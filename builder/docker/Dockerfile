FROM centos:7
MAINTAINER Pablo Mansilla Ojeda <pablo@ppamo.cl>

COPY convert.sh /bin/convert.sh
RUN yum -y update && yum -y install inkscape gs
WORKDIR /data
CMD ["sh", "convert.sh"]
