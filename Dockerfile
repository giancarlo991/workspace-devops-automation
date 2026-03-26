# Estágio 1: Build da aplicação (Builder)
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# Copia o arquivo de configuração do Maven
COPY pom.xml .

# Copia o código fonte (não precisamos dos arquivos mvnw)
COPY src ./src

# Compila a aplicação usando o Maven instalado na imagem
RUN mvn clean package -DskipTests

# Estágio 2: Imagem final de runtime (mais leve)
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Cria usuário para segurança (boa prática de DevOps)
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copia apenas o arquivo .jar gerado no estágio anterior
COPY --from=builder /app/target/*.jar app.jar

# Expõe a porta que a API usa
EXPOSE 8080

# Configurações de performance para rodar em container
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Comando para ligar a aplicação
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]