# node-react
FROM openshift/base-centos7

LABEL maintainer="Yann <yann.cai@crossinfo.cn>"

ENV BUILDER_VERSION 1.0

# TODO: Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for building frontend" \
      io.k8s.display-name="builder frontedn" \
      io.openshift.expose-services="80:http,443:https" \
      io.openshift.tags="builder,etc."

#安装开发依赖
RUN yum install -y pcre-devel wget net-tools gcc zlib zlib-devel make openssl-devel

#ADD 下载node
ADD https://nodejs.org/dist/v14.15.4/node-v14.15.4-linux-x64.tar.xz .
RUN tar -xJvf node-v14.15.4-linux-x64.tar.xz

#ADD  下载nginx
ADD http://nginx.org/download/nginx-1.15.3.tar.gz .
RUN tar -zxvf nginx-1.15.3.tar.gz
RUN mkdir -p /usr/local/nginx
RUN cd nginx-1.15.3 && ./configure && make && make install
RUN ln -s /usr/local/nginx/sbin/* /usr/local/sbin/

#RUN 清除yum包
RUN yum clean all -y

#REPLACE CONF 替换配置文件
RUN rm /usr/local/nginx/conf/nginx.conf
ADD conf/nginx.conf /usr/local/nginx/conf/
 
#ADD RESOUCES 添加静态资源
#RUN rm /usr/local/nginx/html/index.html
#RUN mkdir -p /usr/local/nginx/html/static
#COPY dist/ /usr/local/nginx/html/static
 
#EXPOSE 映射端口
EXPOSE 80

COPY ./s2i/bin/ /usr/libexec/s2i
