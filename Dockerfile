# node-react
FROM openshift/base-centos7

LABEL maintainer="Yann <yann.cai@crossinfo.cn>"

ENV BUILDER_VERSION 1.0

# TODO: Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for building frontend" \
      io.k8s.display-name="builder frontedn" \
      io.openshift.expose-services="80:http,443:https" \
      io.openshift.tags="builder,etc."
#yarn
RUN curl --silent --location https://rpm.nodesource.com/setup_14.x | bash -
RUN curl -sL https://dl.yarnpkg.com/rpm/yarn.repo  | tee /etc/yum.repos.d/yarn.repo
RUN yum install -y yarn
RUN yarn config set registry https://registry.npm.taobao.org/

#安装开发依赖
RUN yum install -y pcre-devel wget net-tools gcc zlib zlib-devel make openssl-devel

#ADD 下载node
#RUN curl -O  https://nodejs.org/dist/v14.15.4/node-v14.15.4-linux-x64.tar.xz 
#RUN tar -xJf node-v14.15.4-linux-x64.tar.xz

#ADD  下载nginx
RUN curl -O http://nginx.org/download/nginx-1.15.3.tar.gz 
RUN tar -zxf nginx-1.15.3.tar.gz
RUN mkdir -p /usr/local/nginx
RUN cd nginx-1.15.3 && ./configure && make && make install
RUN ln -s /usr/local/nginx/sbin/* /usr/local/sbin/

#RUN 清除yum包
RUN yum clean all -y

#REPLACE CONF 替换配置文件
RUN rm /usr/local/nginx/conf/nginx.conf
ADD conf/nginx.conf /usr/local/nginx/conf/
 
#ADD RESOUCES 添加静态资源
RUN rm /usr/local/nginx/html/index.html
RUN mkdir -p /usr/local/nginx/html/static
#COPY dist/ /usr/local/nginx/html/static
 
# Drop the root user and make the content of /opt/openshift owned by user 1001
RUN chown -R 1001:1001 /usr/local/nginx/html/static /opt/app-root/src
RUN usermod -aG adm webuser
# Change perms on target/deploy directory to 777
RUN chmod -R 777 /usr/local/nginx/html/static /opt/app-root/src



# Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way.
COPY ./s2i/bin/ /usr/libexec/s2i
RUN chmod -R 777 /usr/libexec/s2i

# This default user is created in the openshift/base-centos7 image
USER 1001

#EXPOSE 映射端口
EXPOSE 80
# Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
