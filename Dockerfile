FROM scratch
RUN mkdir /bin
ADD cmd/hello/hello /bin
