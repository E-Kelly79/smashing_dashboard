# Smashing container
#
# Specification taken from unofficial Docker Hub example (https://hub.docker.com/r/visibilityspots/smashing/)

# Arguments that can only be used in FROM statement. Can also be overriden by Docker build command
ARG registry=dockerregistry.routematch.com
ARG from_tag=ci

FROM ${registry}/rm-docker-debian-base:${from_tag}

# Install RVM
RUN apt-get update -qy && \
   apt-get install -qy curl ca-certificates gnupg2 build-essential procps --no-install-recommends && \
   apt-get clean && \
   gpg --no-tty --keyserver hkp://ipv4.pool.sks-keyservers.net:80 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
   curl -sSL https://get.rvm.io | bash -s stable

# Install Node
RUN apt-get update && \
   apt-get install -y --no-install-recommends apt-utils && \
   apt-get -y install nodejs && \
   apt-get -y clean

# Install Ruby and required gems
RUN /bin/bash -l -c "rvm install 2.5.1 && \
       gem install bundler --no-document && \
       rvm use 2.5.1 --default && \
       gem update --system && \
       gem install smashing sinatra_cyclist httparty date time_difference faraday jira-ruby xml-simple nokogiri --no-document"

RUN mkdir /smashing

COPY run.sh /
COPY content/widgets /smashing/widgets/
COPY content/assets /smashing/assets/
COPY content/config /smashing/config/
COPY content/dashboards /smashing/dashboards/
COPY content/jobs /smashing/jobs/
COPY content/public /smashing/public/
COPY content/config.ru /smashing/config.ru
COPY content/Go.env /smashing/Go.env
COPY content/Gemfile /smashing/Gemfile
COPY content/Gemfile.lock /smashing/Gemfile.lock
COPY content/lib/cloudwatch.rb /smashing/lib/cloudwatch.rb

RUN cd /smashing && \
   /bin/bash -l -c "bundle install"

# Ensure that script can be run
RUN chmod 700 run.sh

EXPOSE 3030
WORKDIR /smashing

CMD ["/run.sh"]
