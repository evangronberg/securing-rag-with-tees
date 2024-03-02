FROM amazonlinux

RUN mkdir /app
WORKDIR /app
COPY . .

RUN yum install -y python3 python3-pip
RUN python3 -m pip install -r requirements.txt

RUN chmod +x run.sh
CMD ["/app/run.sh"]
