# Node.js 공식 이미지를 사용합니다.
FROM node:21

# 환경 변수를 설정합니다.
ENV DB_HOST="database-1.cluster-cbyc6i02oj3t.ap-northeast-2.rds.amazonaws.com"
ENV DB_USER="admin"
ENV DB_PASSWORD="pjs970213"
ENV DB_NAME="gomdb"
ENV PORT=3000

# 앱 디렉토리를 생성합니다.
WORKDIR /usr/src/app

# 애플리케이션 의존성 파일을 설치합니다.
# package.json 과 package-lock.json을 복사합니다.
COPY package*.json ./

RUN npm install

# 앱 소스를 컨테이너에 복사합니다.
COPY . .

# 앱이 사용할 포트를 지정합니다.
EXPOSE 3000

# 애플리케이션을 실행합니다.
CMD ["node", "app.js"]
