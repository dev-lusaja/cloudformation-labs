FROM golang:1.15.6-alpine

# dependences needed for lambda container
RUN apk update && \
    apk add autoconf \
    automake \
    cmake \
    g++ \
    libtool \
    libexecinfo-dev \
    make \
    py-pip \
    python3-dev

RUN mkdir -p /function

COPY src/ /function

RUN pip install \
        --target /function \
        awslambdaric
#

RUN apk add git
RUN go get github.com/aws/aws-lambda-go/lambda

CMD go run /function/main.go