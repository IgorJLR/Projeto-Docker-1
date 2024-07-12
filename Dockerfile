# syntax=docker/dockerfile:1

# Defina a versão do Node.js que será usada
ARG NODE_VERSION=21.2.0

# Use a imagem base do Node.js Alpine
FROM node:${NODE_VERSION}-alpine

# Configure a variável de ambiente para o ambiente de produção
ENV NODE_ENV production

# Crie o diretório da aplicação
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Copie o arquivo package.json e instale as dependências
COPY package.json /usr/src/app/
RUN npm install

# Copie o restante dos arquivos da aplicação
COPY . /usr/src/app

# Baixe as dependências em uma etapa separada para aproveitar o cache do Docker
# Utilize um cache mount para /root/.npm para acelerar as builds subsequentes
# Utilize bind mounts para package.json e package-lock.json para evitar copiá-los novamente nesta camada
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

# Execute a aplicação como um usuário não root
USER node

# Exponha a porta que a aplicação escuta
EXPOSE 3000

# Execute a aplicação
CMD node src/index.js
