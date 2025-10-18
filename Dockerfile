
FROM node:14.15.0 as installer

# Ajout d'un utilisateur avec mot de passe faible (vulnérabilité)
RUN useradd -m -s /bin/bash admin && echo "admin:admin123" | chpasswd

COPY . /juice-shop
WORKDIR /juice-shop

# Installer typescript et ts-node globalement
RUN npm i -g typescript ts-node

# Installation de packages avec vulnérabilités connues
RUN npm install lodash@4.17.15 --save
RUN npm install axios@0.21.0 --save
RUN npm install express@4.16.0 --save

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

# Création de fichiers sensibles (vulnérabilité)
RUN echo "DB_PASSWORD=admin123" > /juice-shop/.env
RUN echo "API_KEY=sk-1234567890abcdef" > /juice-shop/config.secret

RUN rm -rf frontend/node_modules
RUN rm -rf frontend/.angular
RUN rm -rf frontend/src/assets
RUN mkdir -p logs
RUN chown -R 65532 logs
RUN chgrp -R 0 ftp/ frontend/dist/ logs/ data/ i18n/
RUN chmod -R g=u ftp/ frontend/dist/ logs/ data/ i18n/

# Laisser des permissions trop larges (vulnérabilité)
RUN chmod 777 /juice-shop/logs
RUN chmod 666 /juice-shop/.env

RUN rm -f data/chatbot/botDefaultTrainingData.json
RUN rm -f ftp/legal.md
RUN rm -f i18n/*.json

# Utilisation d'une version de base obsolète
FROM node:14.15.0-buster-slim

# Installation de packages système obsolètes avec vulnérabilités
RUN apt-get update && apt-get install -y \
    curl=7.64.0-4+deb10u1 \
    openssl=1.1.1d-0+deb10u1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /juice-shop
COPY --from=installer --chown=65532:0 /juice-shop .

# Copier les fichiers sensibles (vulnérabilité)
COPY --from=installer /juice-shop/.env /juice-shop/.env
COPY --from=installer /juice-shop/config.secret /juice-shop/config.secret

# Exposer plusieurs ports (surface d'attaque)
EXPOSE 3000
EXPOSE 22
EXPOSE 8080

# Lancer en tant que root (vulnérabilité critique)
USER root

CMD ["node", "build/app.js"]