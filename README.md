# Stage DevSecOps - OWASP Juice Shop

## Description du Projet

Ce projet fait partie d'un stage DevSecOps utilisant *OWASP Juice Shop*, une application web volontairement vulnérable créée pour l'apprentissage de la sécurité des applications.

## Objectifs

- Mise en place d'un pipeline CI/CD sécurisé
- Intégration d'outils de sécurité (SAST, DAST, SCA)
- Automatisation des tests de sécurité
- Déploiement sécurisé sur infrastructure cloud
- Surveillance et monitoring de la sécurité

## Technologies Utilisées

- *Application* : OWASP Juice Shop (Node.js)
- *CI/CD* : GitLab CI/CD
- *Conteneurisation* : Docker
- *Orchestration* : Kubernetes (optionnel)
- *Cloud* : AWS EC2 / Azure / GCP
- *Outils DevSecOps* :
  - SonarQube (analyse de code)
  - OWASP Dependency-Check (scan des dépendances)
  - Trivy (scan d'images Docker)
  - OWASP ZAP (tests de sécurité dynamiques)

## Installation Locale

### Prérequis
- Node.js 18.x ou 16.x
- Docker (optionnel)
- Git

### Installation depuis les sources
# Cloner le repository
git clone https://gitlab.com/tayebmallouli640/stage-devsecops-ete.git
cd stage-devsecops-ete

# Installer les dépendances
npm install

# Lancer l'application
npm start

L'application sera accessible sur : http://localhost:3000

### Installation avec Docker
# Build l'image
docker build -t juice-shop .

# Lancer le conteneur
docker run -d -p 3000:3000 juice-shop

## Configuration

### Variables d'environnement
NODE_ENV=production
PORT=3000

### Configuration de la base de données

Par défaut, Juice Shop utilise SQLite. Configuration dans config/default.yml

## Pipeline DevSecOps

### Étapes du Pipeline

1. *Build* : Compilation et création de l'image Docker
2. *SAST* : Analyse statique du code source
3. *SCA* : Scan des vulnérabilités des dépendances
4. *Container Scan* : Scan de l'image Docker
5. *Deploy* : Déploiement sur environnement cible
6. *DAST* : Tests de sécurité dynamiques

### Structure du fichier .gitlab-ci.yml
stages:
  - build
  - security-scan
  - deploy
  - test

# Voir .gitlab-ci.yml pour les détails complets

## Structure du Projet
.
├── .gitlab-ci.yml          # Configuration CI/CD
├── Dockerfile              # Configuration Docker
├── package.json            # Dépendances Node.js
├── frontend/               # Code source frontend
├── routes/                 # Routes backend
├── data/                   # Données de l'application
├── config/                 # Fichiers de configuration
└── test/                   # Tests automatisés

## Déploiement

### Déploiement sur AWS EC2
# Configuration AWS CLI
aws configure

# Déploiement avec script
./deploy-ec2.sh

### Déploiement sur Azure
az container create \
  --resource-group juice-shop-rg \
  --name juice-shop \
  --image bkimminich/juice-shop \
  --dns-name-label juice-shop-demo \
  --ports 3000

## Monitoring et Logs

- *Logs applicatifs* : logs/
- *Métriques* : Prometheus + Grafana (si configuré)
- *Alertes* : Configuration dans .gitlab-ci.yml

## Tests
# Tests unitaires
npm test

# Tests de sécurité
npm run test:security

# Tests d'intégration
npm run test:integration

## Documentation

- [OWASP Juice Shop Official Docs](https://pwning.owasp-juice.shop)
- [Guide de configuration](docs/CONFIGURATION.md)
- [Guide de déploiement](docs/DEPLOYMENT.md)
- [Rapport de sécurité](docs/SECURITY_REPORT.md)

## Contribution

Ce projet est réalisé dans le cadre d'un stage. Pour toute question ou suggestion :

- *Stagiaire* : Tayeb Mallouli
- *Email* : tayebmallouli640@gmail.com
- *GitLab* : https://gitlab.com/tayebmallouli640

## Licence

Ce projet utilise OWASP Juice Shop qui est sous licence MIT.

## Avertissement

*Cette application contient des vulnérabilités de sécurité volontaires !*

- Ne pas déployer en production
- Ne pas exposer sur Internet sans protection
- Utiliser uniquement dans un environnement de formation/test isolé

## Ressources Utiles

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [DevSecOps Best Practices](https://www.devsecops.org/)
- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [Docker Security](https://docs.docker.com/engine/security/)

---

## védio démonstratif:
[Watch the demo video on Google Drive](https://drive.google.com/file/d/1PYvqwYS3mq5G53kVSbvdmJrnVVt6vvhp/view)


*Fait avec dans le cadre du stage DevSecOps*

Dernière mise à jour : Novembre 2025
