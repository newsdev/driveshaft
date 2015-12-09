FROM newsdev/rails

RUN npm install --ignore-scripts
RUN ./node_modules/bower/bin/bower --allow-root install
