# 開発環境
# gitinstallが1.15.2だとできなかった
FROM golang:1.15.2-alpine as dev

ENV ROOT=/go/src/app
# C言語のインポートを無しにする
ENV CGO_ENABLED 0
WORKDIR ${ROOT}

# gitのインストール
RUN apk update && apk add git
# go.mod go.sumファイルは空でいいから作成しておくこと
# 実際にimportしてみるとしっかりと書き込みされていた。
COPY go.mod go.sum ./
RUN go mod download
EXPOSE 3000

CMD ["go", "run", "main.go"]

# 本番環境
FROM golang:1.15.7-alpine as builder

ENV ROOT=/go/src/app
WORKDIR ${ROOT}

RUN apk update && apk add git
COPY go.mod go.sum ./
RUN go mod download

COPY . ${ROOT}
RUN CGO_ENABLED=0 GOOS=linux go build -o $ROOT/binary


FROM scratch as prod

ENV ROOT=/go/src/app
WORKDIR ${ROOT}
COPY --from=builder ${ROOT}/binary ${ROOT}

EXPOSE 3000
ENTRYPOINT ["/go/src/app/binary"]
