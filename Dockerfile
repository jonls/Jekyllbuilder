FROM ubuntu:14.04
MAINTAINER Jon Lund Steffensen <jonlst@gmail.com>

RUN apt-get update && apt-get install -y \
    gcc \
    git \
    make \
    nodejs \
    python \
    ruby \
    ruby-dev

ENV JEKYLL_VERSION 2.5.3

RUN gem install --no-rdoc --no-ri \
    jekyll -v ${JEKYLL_VERSION}

RUN gem install --no-rdoc --no-ri \
    bunny \
    git \
    jekyll-sitemap \
    json

# This is the repository that contains the Jekyll site
ENV JEKYLL_REPO jekyll_repo

COPY jekyllbuilder.rb /usr/local/bin/jekyllbuilder.rb

CMD ["/usr/local/bin/jekyllbuilder.rb"]
