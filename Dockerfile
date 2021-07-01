
FROM debian:buster

ARG GH_ACTIONS_RUNNER_VERSION=2.263.0
ARG PACKAGES="gnupg2 apt-transport-https ca-certificates software-properties-common pwgen git make curl wget zip libicu-dev build-essential libssl-dev"

# install basic stuff
RUN apt-get update \
    && apt-get install -y -q ${PACKAGES} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install docker
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && apt-key fingerprint 0EBFCD88 \
    && add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/debian \
       $(lsb_release -cs) \
       stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# create "runner" user
RUN useradd -d /runner --uid=1000 runner \
    && echo 'runner:runner' | chpasswd \
    && mkdir /runner \
    && chown -R runner:runner /runner

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get update \
    && apt-get install -y -q nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*    

RUN npm install -g yarn

RUN apt-get update \
    && apt-get install -y -q libffi-dev python3-dev python3-pip python3-setuptools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list \
    && curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add \
    && apt-get update                                                   \
    && apt-get install -y -q default-jdk maven gradle sbt                  \
    && apt-get clean                                                    \
    && rm -rf /var/lib/apt/lists/*    
    
RUN cd /tmp \
   && wget https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz \
   && tar -xvf go1.13.3.linux-amd64.tar.gz \
   && mv go /usr/local/src \
   && ln -s /usr/local/src/go/bin/go /usr/local/bin/ \
   && apt-get update \
   && apt-get install -y -q build-essential \
   && apt-get clean \
   && cd /runner
   
USER runner
WORKDIR /runner

# install github actions runner
RUN curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v${GH_ACTIONS_RUNNER_VERSION}/actions-runner-linux-x64-${GH_ACTIONS_RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64.tar.gz \
    && rm -f actions-runner-linux-x64.tar.gz

COPY start.sh /
  
CMD /start.sh