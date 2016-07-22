FROM ruby:2.2.3

# Configure bundler
RUN \
  bundle config --global frozen 1 && \
  bundle config --global build.nokogiri --use-system-libraries

# Install cmake
ENV CMAKE_MAJOR=3.4
ENV CMAKE_VERSION=3.4.0
ENV CMAKE_SHASUM256=36c275e5c143f61dc3978f0cf5502a848cfbc09f166a72a2db4427c6f05ab2aa
RUN \
  cd /usr/local && \
  curl -sfLO https://cmake.org/files/v$CMAKE_MAJOR/cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz && \
  echo "${CMAKE_SHASUM256}  cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz" | sha256sum -c - &&\
  tar --strip-components 1 -xzf cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz cmake-$CMAKE_VERSION-Linux-x86_64/bin/cmake cmake-$CMAKE_VERSION-Linux-x86_64/share/cmake-$CMAKE_MAJOR/Modules cmake-$CMAKE_VERSION-Linux-x86_64/share/cmake-$CMAKE_MAJOR/Templates && \
  rm cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz

# Install libssh2 from source
ENV LIBSSH2_VERSION=1.6.0
RUN gpg --keyserver pgp.mit.edu --recv-keys 279D5C91
RUN \
  cd /usr/local && \
  curl -sfLO http://www.libssh2.org/download/libssh2-$LIBSSH2_VERSION.tar.gz && \
  curl -sfLO http://www.libssh2.org/download/libssh2-$LIBSSH2_VERSION.tar.gz.asc && \
  gpg --verify libssh2-$LIBSSH2_VERSION.tar.gz.asc && \
  tar -xzf libssh2-$LIBSSH2_VERSION.tar.gz && \
  cd libssh2-$LIBSSH2_VERSION && \
  ./configure --with-openssl --without-libgcrypt --with-libz && \
  make install && \
  cd .. && \
  rm -r libssh2-$LIBSSH2_VERSION libssh2-$LIBSSH2_VERSION.* share/man/man3/libssh2_*

# Install node.js
ENV NODE_VERSION=5.1.0
ENV NODE_SHASUM256=510e7a2e8639a3ea036f5f6a9f7a66037e3acf8d0c953aeac8d093dea7e41d4c
RUN \
  cd /usr/local && \
  curl -sfLO https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz && \
  echo "${NODE_SHASUM256}  node-v$NODE_VERSION-linux-x64.tar.gz" | sha256sum -c - &&\
  tar --strip-components 1 -xzf node-v$NODE_VERSION-linux-x64.tar.gz node-v$NODE_VERSION-linux-x64/bin node-v$NODE_VERSION-linux-x64/include node-v$NODE_VERSION-linux-x64/lib && \
  rm node-v$NODE_VERSION-linux-x64.tar.gz

# Install kubernetes-secret-env
ENV KUBERNETES_SECRET_ENV_VERSION=0.0.2
RUN \
  mkdir -p /etc/secret-volume && \
  cd /usr/local/bin && \
  curl -sfLO https://github.com/newsdev/kubernetes-secret-env/releases/download/$KUBERNETES_SECRET_ENV_VERSION/kubernetes-secret-env && \
  chmod +x kubernetes-secret-env

# Set the working directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install gems
COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundle install --jobs `nproc`

# Install npm packages
COPY package.json /usr/src/app/
RUN npm install --ignore-scripts

# Install bower dependencies
COPY bower.json .bowerrc /usr/src/app/
RUN ./node_modules/bower/bin/bower --allow-root --config.interactive=false install

# Copy the rest of the application source
COPY . /usr/src/app

# Run the server
EXPOSE 3000
ENTRYPOINT ["kubernetes-secret-env"]
CMD ["puma", "-t", "16:16", "-p", "3000"]
