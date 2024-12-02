FROM golang:1.23

# Definir o diretório de trabalho
WORKDIR /usr/src/app

# Instalar dependências necessárias: SQLite3, libsqlite3-dev e ferramentas para o Protobuf
RUN apt-get update && apt-get install -y \
    sqlite3 \
    libsqlite3-dev \
    unzip \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instalar o protoc
RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v21.12/protoc-21.12-linux-x86_64.zip \
    -O /tmp/protoc.zip && \
    unzip /tmp/protoc.zip -d /usr/local && \
    rm /tmp/protoc.zip

# Adicionar `protoc` ao PATH
ENV PATH="$PATH:/usr/local/bin"

# Instalar o plugin protoc-gen-go e protoc-gen-go-grpc
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.30.0
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.3.0

# Instalar o Evans via go install
RUN go install github.com/ktr0731/evans@latest

# Adicionar o diretório $GOPATH/bin ao PATH para garantir que os plugins sejam encontrados
ENV PATH="$PATH:/go/bin"

# Pré-copiar e baixar dependências Go
COPY go.mod go.sum ./
RUN go mod download && go mod verify

# Copiar o restante dos arquivos do projeto
COPY . .

# Comando padrão ao iniciar o contêiner
CMD ["bash"]
