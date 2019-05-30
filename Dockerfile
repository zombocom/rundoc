FROM ruby:2.6.3-stretch

RUN useradd rundoc
RUN curl https://cli-assets.heroku.com/install-ubuntu.sh | sh

RUN apt-get clean && apt-get update && apt-get install -y locales nodejs

RUN locale-gen en_US.UTF-8
ENV LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV DISABLE_SPRING=1

WORKDIR /home/rundoc
RUN mkdir -p /home/rundoc/ && chown -R rundoc:rundoc /home/rundoc
USER rundoc
RUN mkdir -p /home/rundoc/workdir

RUN git config --global user.email "developer@example.com"
RUN git config --global user.name "Dev Eloper"

ADD Gemfile Gemfile.lock

RUN bundle install