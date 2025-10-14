FROM node:18 as installer
COPY . /juice-shop
WORKDIR /juice-shop

RUN npm i -g typescript ts-node
RUN npm install --unsafe-perm

# Installer feature-policy explicitement si manquant
RUN npm install feature-policy --save

RUN npm dedupe
RUN rm -rf frontend/node_modules
RUN rm -rf frontend/.angular
RUN rm -rf frontend/src/assets
RUN mkdir -p logs
RUN chown -R 65532 logs
RUN chgrp -R 0 ftp/ frontend/dist/ logs/ data/ i18n/
RUN chmod -R g=u ftp/ frontend/dist/ logs/ data/ i18n/
RUN rm -f data/chatbot/botDefaultTrainingData.json
RUN rm -f ftp/legal.md
RUN rm -f i18n/*.json

FROM node:18-bookworm-slim
WORKDIR /juice-shop
COPY --from=installer --chown=65532:0 /juice-shop .
USER 65532
EXPOSE 3000
CMD ["node", "build/app.js"]