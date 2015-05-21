FROM rails:onbuild
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN npm install
RUN bower install
