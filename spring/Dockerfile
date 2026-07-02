# OpenJDK 17을 포함하는 경량화된 Alpine Linux 베이스 이미지 사용
FROM openjdk:17-jdk-bullseye

# 컨테이너 내부의 작업 디렉토리를 /home/app로 설정
WORKDIR /home/app

# 호스트 시스템의 SpringBoot 애플리케이션 JAR 파일을 컨테이너 내부 작업 디렉토리로 복사
COPY build/libs/*.jar app.jar

RUN apt-get update && \
    apt-get install -y fonts-noto-cjk && \
    apt-get install -y fonts-nanum-extra && \
    rm -rf /var/lib/apt/lists/* && \
    fc-cache -fv

# 컨테이너가 시작될 때 실행될 명령어 정의, 작업 디렉토리 /home/app/app.jar 파일 실행
ENTRYPOINT ["java", "-Dfile.encoding=UTF-8", "-jar", "./app.jar"]

# 컨테이너의 8080 포트를 외부에 공개
EXPOSE 8080