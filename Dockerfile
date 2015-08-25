FROM ubuntu:14.04

RUN apt-get update -y && apt-get install -y \
              autoconf \
              bison \
              build-essential \
              curl \      
              git \
              libffi-dev \              
              libgdbm3 \
              libgdbm-dev \
              libncurses5-dev \
              libreadline6-dev \              
              libssl-dev \
              libyaml-dev \
              zlib1g-dev \              
        && rm -rf /var/lib/apt/lists/*

RUN useradd ubuntu -d /home/ubuntu -m -U
RUN chown -R ubuntu:ubuntu /home/ubuntu

# for log storage (maybe shared with host)
RUN mkdir -p /fluentd/log
# configuration/plugins path (default: copied from .)
RUN mkdir -p /fluentd/etc
RUN mkdir -p /fluentd/plugins

RUN chown -R ubuntu:ubuntu /fluentd

USER ubuntu
WORKDIR /home/ubuntu

RUN git clone https://github.com/tagomoris/xbuild.git /home/ubuntu/.xbuild
RUN /home/ubuntu/.xbuild/ruby-install 2.2.2 /home/ubuntu/ruby

ENV PATH /home/ubuntu/ruby/bin:$PATH
WORKDIR /home/ubuntu
RUN gem install fluentd -v 0.12.15
RUN gem install fluent-plugin-s3


ENV FLUENTD_OPT="--suppress-config-dump"
ENV FLUENTD_CONF="fluent.conf"

EXPOSE 24224

### docker run -p 24224 -v `pwd`/log: -v `pwd`/log:/home/ubuntu/log fluent/fluentd:latest
CMD fluentd -c /fluentd/etc/fluent.conf -p /fluentd/plugins --suppress-config-dump
