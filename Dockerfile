FROM node:18 as installer
COPY . /juice-shop
WORKDIR /juice-shop

# Installer typescript et ts-node globalement
RUN npm i -g typescript ts-node

# Patch pour corriger l'erreur express-jwt avant l'installation
RUN sed -i "s/expressJwt({ secret: publicKey })/expressJwt({ secret: publicKey, algorithms: ['RS256'] })/g" lib/insecurity.ts || true
RUN sed -i "s/expressJwt({ secret: '' + Math.random() })/expressJwt({ secret: '' + Math.random(), algorithms: ['RS256'] })/g" lib/insecurity.ts || true

# Installer toutes les dépendances
RUN npm install --unsafe-perm

# Installer feature-policy explicitement si manquant
RUN npm install feature-policy --save

# Rebuild le projet après les modifications
RUN npm run build || true

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