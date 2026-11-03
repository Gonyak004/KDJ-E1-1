# KDJ-E1-1

### 내 컴퓨터에 개발자용 '작업실' 꾸미기

개발 워크스테이션 구축: Linux CLI, WSL Ubuntu, Docker 및 Git/GitHub 실습

### 1. 실행 환경

| 구분 | 실행 환경 및 설정 |
| --- | --- |
| 호스트 운영체제 | Windows |
| Linux 환경 | WSL2 / Ubuntu 26.04.1 LTS |
| Linux 커널 | 6.18.54.1-microsoft-standard-WSL2 |
| 개발 도구 | Visual Studio Code / WSL Ubuntu 터미널 |
| 컨테이너 환경 | Docker Desktop / Docker Engine 29.9.2 |
| 웹 서버 | NGINX 1.31.8 / 기반 이미지: `nginx:alpine` |
| 웹 콘텐츠 | `app/index.html` |
| 기본 접속 주소 | `http://localhost:8080` |
| 포트 매핑 | 호스트 8080 → 컨테이너 80 |
| 추가 검증 포트 | `127.0.0.1:60684` → 컨테이너 80 |
| 바인드 마운트 | `app/` → `/usr/share/nginx/html` (읽기 전용) |
| 영속 저장소 | Docker named volume / 컨테이너 내부 `/data` |
| Windows 프로젝트 경로 | `C:\github\KDJ-E1-1` |
| WSL 프로젝트 경로 | `/mnt/c/github/KDJ-E1-1` |
| Linux 권한 실습 경로 | `~/dev-workstation` |
| 관리 | Git / [Gonyak004/KDJ-E1-1](https://github.com/Gonyak004/KDJ-E1-1) |

버전과 추가 검증 포트는 [실제 실행 로그](logs/verification-20261103-162726.log)를 기준으로 정리했습니다. 추가 검증에서는 기본 8080 서비스와 별도로 임시 포트를 사용했습니다.

### 2. 수행 체크리스트

- [v] WSL Ubuntu 개발 환경 및 터미널 실행 확인
- [v] Linux CLI로 디렉터리·파일 생성 및 내용 조회
- [v] 파일 복사 및 이름 변경 실습
- [v] WSL 홈 경로에서 파일 권한 755 → 644 변경 확인
- [v] WSL 홈 경로에서 디렉터리 권한 755 확인
- [v] Docker hello-world 실행 및 클라이언트·서버 연결 확인
- [v] NGINX Dockerfile 작성 및 이미지 빌드 완료
- [v] 8080:80 포트 매핑과 웹 페이지 접속 확인
- [v] NGINX HTTP 200 응답 및 접근 로그 확인
- [v] 바인드 마운트의 HTML 변경 반영 확인
- [v] 읽기 전용 바인드 마운트 설정 확인
- [v] 작성 컨테이너 삭제 후 새 컨테이너에서 볼륨 데이터 유지 확인
- [v] 실습 스크린샷 8장 및 실제 검증 로그 확보
- [v] 본인 GitHub 저장소 연결 및 프로젝트 파일 게시 확인

권한 체크는 WSL 홈 경로의 스크린샷 기준입니다. Windows 드라이브 경로에서 실행한 추가 로그에는 파일·디렉터리가 777로 표시되어 두 환경의 결과를 구분했습니다. 파일 삭제 명령 자체는 첨부 화면에 없어 완료 항목으로 표시하지 않았습니다.

---

### 목차

- [1. 실행 환경](#1-실행-환경)
- [2. 수행 체크리스트](#2-수행-체크리스트)
- [3. 프로젝트 소개](#3-프로젝트-소개)
- [4. 실습 및 실행 방법](#4-실습-및-실행-방법)
- [5. 프로젝트 구조](#5-프로젝트-구조)
- [6. 트러블슈팅](#6-트러블슈팅)
- [7. 로그 및 증빙 자료](#7-로그-및-증빙-자료)
- [8. 실습 확인 결과](#8-실습-확인-결과)
- [9. 사용한 터미널 명령어](#9-사용한-터미널-명령어)

---

### 3. 프로젝트 소개

> Windows에서 WSL Ubuntu를 활용해 Linux 개발 환경을 구성하고, Docker 기반 NGINX 웹 서버와 Git/GitHub를 다뤄보며 파일 권한, 포트 매핑, 바인드 마운트와 볼륨 영속성을 학습하고 관련 기록을 정리했습니다.

주요 실습 내용

- Linux CLI를 이용한 파일·디렉터리 관리 및 `chmod` 권한 설정
- Docker 이미지 빌드 및 컨테이너 관리
- NGINX 웹 서버 실행과 `8080:80` 포트 매핑
- 바인드 마운트를 이용한 HTML 변경 반영 및 볼륨 데이터 보존 확인
- Git 커밋과 GitHub 원격 저장소 연결, 인증 오류 대응

저장소: [Gonyak004/KDJ-E1-1](https://github.com/Gonyak004/KDJ-E1-1)

이 문서는 이전 실습 대화, 로컬 파일 및 첨부 스크린샷 8장을 기준으로 작성했습니다. 아래 명령어는 재현·확인용으로 참고 부탁드립니다.

---
### 4. 실습 및 실행 방법
#### Linux CLI 및 파일 권한

```bash
cd /mnt/c/github/KDJ-E1-1
pwd
whoami
uname -a
ls -la
mkdir -p permission-dir
touch permission.txt
chmod 644 permission.txt
chmod 755 permission-dir
ls -l permission.txt
ls -ld permission-dir
```

`644`는 소유자 읽기·쓰기, 그룹과 기타 사용자 읽기 권한입니다. `755`는 소유자 읽기·쓰기·실행, 그룹과 기타 사용자 읽기·실행 권한입니다. 디렉터리의 실행 권한은 디렉터리 접근에 사용됩니다.

Windows 드라이브(`/mnt/c`)에서는 WSL 마운트 설정과 Windows 권한에 따라 `chmod` 반영 방식이 달라질 수 있었습니다. 첨부 화면에서는 WSL의 ~/dev-workstation에서 파일 권한 755 → 644 변경과 디렉터리 755 권한의 실제 출력을 확인했습니다.
#### Docker 환경 확인 및 컨테이너 관리

```bash
docker --version
docker info
docker images
docker ps -a
docker volume ls
```

첨부 화면에서 hello-world 실행 후 Hello from Docker! 출력을 확인했습니다. 촬영 당시 컨테이너 실행이 확인되며 현재 상태는 위 명령으로 확인했습니다. Docker Desktop을 사용하신다면 Ubuntu와 WSL 통합 설정도 확인했습니다.
#### Dockerfile

현재 Dockerfile의 내용입니다.

```dockerfile
FROM nginx:alpine

LABEL description="Development Workstation Web Server"

COPY app/index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

이미지 빌드 및 실행 예시입니다. 동일한 컨테이너 이름이나 호스트 포트가 이미 사용 중이면 다른 이름·포트를 지정했습니다.

```bash
docker build -t kdj-e1-1-web .
docker run -d --name kdj-e1-1-web -p 8080:80 kdj-e1-1-web
curl -I --max-time 10 http://localhost:8080
docker logs kdj-e1-1-web
```
브라우저에서 `http://localhost:8080`으로 접속했습니다. `8080:80`은 호스트의 8080번 포트를 컨테이너의 80번 포트에 연결했습니다. `EXPOSE 80`만으로 호스트 포트가 공개되지는 않습니다. HTTP 응답의 정상 확인 기준은 `200 OK`입니다.

```bash
docker stop kdj-e1-1-web
docker start kdj-e1-1-web
```
#### 바인드 마운트

호스트의 `app` 폴더를 NGINX 문서 경로에 연결했습니다. 앞의 웹 컨테이너를 중지하여 8080번 포트를 확보한 뒤 실행했습니다.

```bash
docker stop kdj-e1-1-web
docker run -d --name kdj-e1-1-bind -p 8080:80 \
  --mount type=bind,source="$(pwd)/app",target=/usr/share/nginx/html,readonly \
  nginx:alpine
```

호스트의 `app/index.html`을 수정한 후 `curl http://localhost:8080`으로 변경 내용을 확인했습니다. 이미지 재빌드 없이 호스트 파일을 제공하며, 컨테이너에서는 읽기 전용으로 연결됩니다.
기존 `logs/bind-before.log`에는 없던 `Bind Mount Updated Successfully!` 문구가 `logs/bind-after.log`와 현재 HTML에 존재했습니다. 저장된 응답 내용의 차이와 첨부 화면의 브라우저·curl 변경 반영을 확인했으며, 추가 검증에서 /mnt/c/github/KDJ-E1-1/app의 읽기 전용 바인드 마운트(Type: bind, RW: false) 설정도 확인했습니다.
#### Docker 볼륨 영속성

다음은 별도 테스트 볼륨에 데이터를 쓰고, 작성 컨테이너 종료 후 새 컨테이너에서 다시 읽는 재현 예시입니다.

```bash
mkdir -p logs
docker volume create kdj-e1-1-persistence-check
docker run --rm -v kdj-e1-1-persistence-check:/data alpine \
  sh -c 'echo "Docker Volume Persistence Test" > /data/test.txt; cat /data/test.txt' \
  > logs/volume-before.log
docker run --rm -v kdj-e1-1-persistence-check:/data alpine \
  cat /data/test.txt > logs/volume-after.log
diff -s logs/volume-before.log logs/volume-after.log
```
정상적으로 실행되면 두 파일의 내용이 일치했습니다. 컨테이너가 종료·삭제되어도 이름 있는 볼륨은 별도로 삭제하기 전까지 데이터를 보관했습니다. 위 예시를 재실행하면 같은 이름의 기존 로그가 갱신됩니다.

현재 두 로그에는 동일한 `Docker Volume Persistence Test` 문구가 저장되어 있었습니다. 추가 검증 로그에서는 작성 컨테이너를 삭제한 후 새 컨테이너가 같은 볼륨에서 데이터를 읽고 내용 비교를 통과한 과정까지 확인했습니다.
#### Git / GitHub 연동

현재 로컬 `origin`의 fetch/push 주소는 모두 `https://github.com/Gonyak004/KDJ-E1-1.git`로 확인했습니다.

```bash
git remote -v
git status
git log -1 --oneline
```

변경 내용을 확인하신 뒤 아래 순서로 반영했습니다.

```bash
git add README.md evidence/
git diff --cached
git commit -m "docs: document development workstation practice"
git push origin main
```

---
### 5. 프로젝트 구조

로컬 주요 파일과 이번 문서에 첨부한 증빙 폴더의 구성입니다.

```text
KDJ-E1-1/
├── Dockerfile
├── README.md
├── .gitignore
├── permission.txt
├── permission-dir/
├── app/
│   └── index.html
├── docs/
├── evidence/                 # 첨부 스크린샷 8장
└── logs/
    ├── bind-before.log
    ├── bind-after.log
    ├── volume-before.log
    ├── volume-after.log
    └── final-verification.log
```

`evidence/`에는 아래 스크린샷 8장을 첨부했습니다.

---

### 6. 트러블슈팅
#### 1. 빈 Dockerfile로 인한 빌드 문제

- 문제: 실습 중 Dockerfile에 내용을 포함하고 있었으나, 이미지 빌드에 내용이 없다는 에러를 확인 후, 재시도 및 필요한 지시문이 다시 넣어 해결하였습니다.

- 조치: NGINX 기본 이미지, HTML 복사 경로, 포트 및 실행 명령을 재시도하는 방식으로 대응했습니다.

- 현재 확인: 로컬 Dockerfile에는 위 내용이 들어 있었습니다. 첨부 화면의 NGINX 응답에 더해 추가 검증 로그에서 이미지 내보내기·태그 지정과 빌드 완료까지 확인했습니다.

- 확인 방법: `cat Dockerfile`로 내용을 확인하고 `docker build -t kdj-e1-1-web .`의 종료 결과를 확인할 수 있었습니다.

#### 2. 잘못된 GitHub 계정 인증으로 인한 403 오류

이전 대화에서 다음 오류가 확인되었습니다.

```text
remote: Permission to Gonyak004/KDJ-E1-1.git denied to SeoyoungShim.
fatal: unable to access 'https://github.com/Gonyak004/KDJ-E1-1.git/': The requested URL returned error: 403
```

- 원인: 저장소 소유자는 `Gonyak004`였지만 Git 인증에는 `SeoyoungShim` 계정이 사용되었습니다. 커밋 작성자 설정과 GitHub 인증 계정은 서로 다른것을 확인했습니다.

- 대응 절차: `git config --show-origin --get-all credential.helper`로 인증 도구를 확인하고, 해당 인증 도구에서 본인 계정 `Gonyak004`로 로그인한 뒤 다시 push했습니다. 

- >공용 PC의 다른 사용자 인증정보가 저장되어 추후 pc 사용에있어서 꼭 유의해야할 듯 싶습니다...

- 현재 확인: 로컬 원격 주소는 본인 저장소로 설정되어 있습니다. 재인증 및 push 성공 출력은 추가 확인이 필요했습니다.

- 별도 정리: 이전 사용자인 `SeoyoungShim` 계정에 잘못 생성된 저장소는 소유자와 협의하여 정리하도록 하겠습니다.

---
### 7. 로그 및 증빙 자료
| 자료 | 확인 내용 | 상태 |
| --- | --- | --- |
| [bind-before.log](logs/bind-before.log) | 변경 전 HTML | 파일 확인 |
| [bind-after.log](logs/bind-after.log) | 변경 확인 문구가 추가된 HTML | 파일 확인 |
| [volume-before.log](logs/volume-before.log) | 저장 데이터 문구 | 파일 확인 |
| [volume-after.log](logs/volume-after.log) | 이전 로그와 같은 문구 | 내용 일치 확인 |
| [final-verification.log](logs/final-verification.log) | 시스템·Docker·Git 확인 명령어 | 실행 출력이 아닌 명령어 본문만 저장됨 |
| `evidence/` | Linux·권한·Docker·웹 응답·HTML 변경 화면 | 스크린샷 8장 첨부 |
| [추가 검증 로그](logs/verification-20261103-162726.log) | 빌드·볼륨 재사용·마운트·HTTP 응답 | 실제 실행 결과 확인 |
#### 실습 화면 증빙

촬영 당시 화면에서 확인되는 내용을 정리했습니다.

##### 터미널 실습

>WSL: Ubuntu 연결과 Ubuntu OS 정보 출력을 확인했습니다.

![터미널 실습](evidence/01-wsl-terminal.png)

##### 리눅스 파일 생성

>mkdir, touch, echo, cat을 이용한 파일 생성과 Hello Linux 출력을 확인했습니다.

![리눅스 파일 생성](evidence/02-linux-file-create.png)

##### 파일 삭제 복사 변경

>cp와 mv 명령, renamed.txt가 있는 목록과 이후 없는 목록을 확인했습니다. 삭제 명령 자체는 표시되지 않습니다.

![파일 삭제 복사 변경](evidence/03-linux-file-operations.png)
##### 파일 권한 변경

>chmod 755 적용 후 -rwxr-xr-x, chmod 644 적용 후 -rw-r--r-- 출력을 확인했습니다.

![파일 권한 변경](evidence/04-file-permissions.png)

##### 디렉토리 권한 변경

>chmod 755 적용 후 permission-dir의 drwxr-xr-x 출력을 확인했습니다.

![디렉토리 권한 변경](evidence/05-directory-permissions.png)

##### Docker 로그확인

>hello-world 실행 후 Hello from Docker! 출력을 확인했습니다.

![Docker 로그확인](evidence/06-docker-hello-world.png)
##### html 이미지 빌드

>localhost:8080 웹 화면과 HTTP/1.1 200 OK, Server: nginx/1.31.8 출력을 확인했습니다. 빌드 명령은 보이지만 빌드 완료 로그는 표시하지 않았습니다.

![html 이미지 빌드](evidence/07-nginx-web-response.png)
##### html 바인드 마운트 변경

>브라우저와 curl 응답에 Bind Mount Updated Successfully! 문구가 반영되었습니다.

![html 바인드 마운트 변경](evidence/08-bind-mount-update.png)

기존 `final-verification.log`에는 명령어 본문만 있으므로, 실제 실행 결과가 담긴 `verification-20261103-162726.log`를 최종 증빙으로 사용했습니다. 아래는 필요 시 추가 출력을 수집하는 예시입니다.
```bash
{
  uname -a
  whoami
  ls -l permission.txt
  ls -ld permission-dir
  docker --version
  docker info
  docker images
  docker ps -a
  docker volume ls
  curl -I --max-time 10 http://localhost:8080
  grep 'Bind Mount Updated Successfully' logs/bind-after.log
  diff -s logs/volume-before.log logs/volume-after.log
  git remote -v
  git status
  git log -1 --oneline
} > "logs/verification-output-$(date +%Y%m%d-%H%M%S).log" 2>&1
```
- 로그에는 오류 출력도 함께 저장됩니다. HTTP 응답, Docker 연결, 권한 및 Git 상태를 항목별로 확인했습니다. Linux 권한, Docker 실행, 웹 접속 및 HTML 변경 화면은 첨부했습니다. 볼륨 재사용 과정은 추가 실행 로그로 GitHub 최종 반영은 별도 확인이 필요했습니다.

---
### 8. 실습 확인 결과
#### [검증 로그](logs/verification-20261103-162726.log)

| 확인 항목 | 실행 결과 |
| --- | --- |
| WSL / Ubuntu | WSL2 커널 및 Ubuntu 26.04.1 LTS 출력 확인 |
| Docker | 클라이언트·서버 29.9.2 연결 확인 |
| NGINX 이미지 빌드 | COPY 수행, 이미지 내보내기 및 태그 지정 완료 |
| 볼륨 영속성 | 작성 컨테이너 삭제 후 새 컨테이너에서 같은 볼륨의 데이터 재조회·내용 비교 통과 |
| 바인드 마운트 | app → /usr/share/nginx/html, Type: bind, RW: false 확인 |
| HTTP 응답 | 임시 포트 60684에서 HTTP/1.1 200 OK 및 HTML 본문 확인 |
| NGINX 로그 | HEAD·GET 요청의 200 응답 기록 확인 |
| Git 원격 | Gonyak004/KDJ-E1-1 fetch·push 주소 확인 |

---

### 9. 사용한 터미널 명령어

실습과 추가 검증에 사용한 주요 명령어입니다. 아래 예시의 이미지·컨테이너·볼륨 이름은 실제 실행 환경에 맞게 지정했습니다.

#### Linux 환경 및 파일 관리

| 명령어 예시 | 간략한 설명 |
| --- | --- |
| `pwd` | 현재 작업 디렉터리의 경로를 확인합니다. |
| `cd ~/dev-workstation` | 실습 프로젝트 디렉터리로 이동합니다. |
| `whoami` | 현재 로그인한 사용자 이름을 확인합니다. |
| `uname -a` | Linux 커널과 시스템 정보를 확인합니다. |
| `cat /etc/os-release` | Ubuntu 배포판과 버전 정보를 확인합니다. |
| `ls -la` | 숨김 파일을 포함한 파일 목록과 권한을 확인합니다. |
| `mkdir -p practice` | 실습 디렉터리를 생성합니다. 필요한 상위 디렉터리도 함께 생성합니다. |
| `touch test.txt` | 빈 파일을 생성하거나 기존 파일의 수정 시각을 갱신했습니다. |
| `echo "Hello Linux" > test.txt` | 문자열을 파일에 저장했습니다. 기존 내용은 덮어씁니다. |
| `cat test.txt` | 파일에 저장된 내용을 출력합니다. |
| `cp test.txt copy.txt` | 파일을 복사합니다. |
| `mv copy.txt renamed.txt` | 파일 이름을 변경합니다. 다른 경로를 지정하면 이동합니다. |
| `chmod 755 permission.txt` | 소유자에게 읽기·쓰기·실행, 나머지 사용자에게 읽기·실행 권한을 설정합니다. |
| `chmod 644 permission.txt` | 소유자에게 읽기·쓰기, 나머지 사용자에게 읽기 권한을 설정합니다. |
| `chmod 755 permission-dir` | 디렉터리에 소유자 전체 권한과 나머지 사용자의 조회·접근 권한을 설정합니다. |
| `ls -l permission.txt` | 파일 권한과 소유자를 확인합니다. |
| `ls -ld permission-dir` | 디렉터리 자체의 권한과 소유자를 확인합니다. |

#### Docker 및 NGINX

| 명령어 예시 | 간략한 설명 |
| --- | --- |
| `docker version` | Docker 클라이언트와 서버의 버전을 확인합니다. |
| `docker info` | Docker 엔진 연결과 실행 환경 정보를 확인합니다. |
| `docker run --name hello-test hello-world` | 테스트 컨테이너를 실행하여 Docker 동작을 확인합니다. |
| `docker build -t kdj-e1-1-web .` | 현재 폴더의 Dockerfile로 이미지를 빌드하고 이름을 지정합니다. |
| `docker build --progress=plain -t kdj-e1-1-web .` | 빌드 단계별 출력을 일반 텍스트로 표시하여 로그를 확인합니다. |
| `docker run -d --name kdj-e1-1-web -p 8080:80 kdj-e1-1-web` | NGINX 컨테이너를 백그라운드로 실행하고 호스트 8080 포트를 연결합니다. |
| `docker images` | 로컬 Docker 이미지 목록을 확인합니다. |
| `docker ps -a` | 실행 중이거나 종료된 컨테이너를 확인합니다. |
| `docker logs kdj-e1-1-web` | 컨테이너의 시작 로그와 요청 처리 로그를 확인합니다. |
| `docker stop kdj-e1-1-web` | 컨테이너를 중지합니다. |
| `docker start kdj-e1-1-web` | 중지한 컨테이너를 다시 실행합니다. |
| `docker rm 컨테이너명` | 종료된 컨테이너를 삭제했습니다. 검증에서는 작성 컨테이너 삭제 후 볼륨을 재사용합니다. |
| `docker inspect 컨테이너명 --format '{{json .Mounts}}'` | 바인드 마운트·볼륨의 연결 경로와 읽기·쓰기 설정을 확인합니다. |
| `docker port 컨테이너명 80/tcp` | 컨테이너의 80번 포트에 연결된 실제 호스트 주소와 포트를 확인합니다. |

#### 마운트·볼륨 및 결과 확인

| 명령어 예시 | 간략한 설명 |
| --- | --- |
| `--mount type=bind,source="$(pwd)/app",target=/usr/share/nginx/html,readonly` | `docker run`에 사용하는 옵션으로, 호스트의 app 폴더를 읽기 전용으로 연결합니다. |
| `docker volume create 볼륨명` | 컨테이너와 별도로 데이터를 보관하는 볼륨을 생성합니다. |
| `docker volume ls` | Docker 볼륨 목록을 확인합니다. |
| `docker run --rm -v 볼륨명:/data alpine cat /data/test.txt` | 새 컨테이너에 기존 볼륨을 연결하여 저장된 데이터를 읽고, 종료 후 컨테이너를 자동 삭제합니다. |
| `curl -I http://localhost:8080` | HTTP 응답 헤더를 조회하여 상태 코드와 서버 정보를 확인합니다. |
| `curl -s http://localhost:8080` | 진행률 표시 없이 웹 페이지 응답 본문을 조회합니다. |
| `curl --fail http://localhost:8080` | 웹 응답을 조회하며 HTTP 400 이상 오류에 실패 종료 코드를 반환합니다. |
| `tee logs/bind-after.log` | 앞 명령의 출력을 화면과 로그 파일에 동시에 기록합니다. |
| `grep 'Bind Mount Updated Successfully' logs/bind-after.log` | 로그에서 HTML 변경 확인 문구를 검색합니다. |
| `diff -s logs/volume-before.log logs/volume-after.log` | 볼륨 검증 전후 파일 내용을 비교하고 일치 여부를 출력합니다. |
| `bash verify-workstation.sh` | 이미지 빌드·볼륨 재사용·마운트·HTTP 응답을 검증하고 실행 로그를 저장합니다. |

#### Git / GitHub

| 명령어 예시 | 간략한 설명 |
| --- | --- |
| `git remote -v` | fetch·push에 사용하는 원격 저장소 주소를 확인합니다. |
| `git status` | 현재 브랜치와 수정·추적 상태를 확인합니다. |
| `git status --short` | 변경 파일을 짧은 형식으로 확인합니다. |
| `git log -1 --oneline` | 가장 최근 커밋의 식별자와 메시지를 확인합니다. |
| `git config --show-origin --get-regexp '^user\.'` | 커밋 작성자 이름·이메일과 설정 출처를 확인합니다. |
| `git config --local user.name "Gonyak004"` | 현재 저장소에서 앞으로 생성할 커밋의 작성자 이름을 설정합니다. |
| `git config --local user.email "본인 GitHub 등록 이메일"` | 현재 저장소의 커밋 작성자 이메일을 설정했습니다. 예시 문구 대신 실제 본인 주소를 입력합니다. |
| `git add README.md evidence/ logs/` | 문서·이미지·로그의 변경 내용을 커밋 대상으로 등록합니다. |
| `git diff --cached` | 커밋 대상으로 등록한 변경 내용을 확인했습니다. |
| `git commit -m "docs: update README"` | 등록한 변경 내용을 로컬 커밋으로 저장합니다. |
| `git push origin main` | 로컬 main 브랜치의 커밋을 원격 저장소에 업로드합니다. |
