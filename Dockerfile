FROM golang:1.11.5-alpine3.8 as gobuild
WORKDIR /
ENV GOPATH="/go"
RUN apk update && apk add build-base git zeromq-dev
#COPY . . if you update the libs below build with --no-cache

RUN go get -d github.com/gorilla/mux
RUN go get -d github.com/me-box/lib-go-databox
#RUN go get -d github.com/gorilla/handlers

COPY ./src ./src
RUN addgroup -S databox && adduser -S -g databox databox
RUN GGO_ENABLED=0 GOOS=linux go build -a -ldflags '-s -w' -o app /src/*.go

FROM amd64/alpine:3.8
COPY --from=gobuild /etc/passwd /etc/passwd
RUN apk update && apk add libzmq
USER databox
WORKDIR /
COPY --from=gobuild /app .
COPY /ui/dist /www
LABEL databox.type="app"
EXPOSE 8080
CMD ["./app"]
