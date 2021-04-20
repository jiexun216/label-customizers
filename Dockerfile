FROM alpine:latest

ADD label-customizers /label-customizers
ENTRYPOINT ["./label-customizers"]