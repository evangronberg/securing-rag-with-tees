FROM amazonlinux

ENV HELLO="Hello from the enclave side!"
COPY hello.sh /bin/hello.sh

RUN mkdir /app
WORKDIR /app
COPY . .

RUN pip3 install -r requirements.txt

RUN chmod +x run.sh
CMD ["/app/run.sh"]
