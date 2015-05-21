FROM rails:onbuild
RUN curl -sL https://deb.nodesource.com/setup_0.12 | bash -
RUN apt-get install -y nodejs
RUN npm install --ignore-scripts
RUN ./node_modules/bower/bin/bower --allow-root install
