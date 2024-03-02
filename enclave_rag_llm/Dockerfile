FROM amazonlinux

RUN mkdir /app
WORKDIR /app
COPY . .

RUN pip3 install -r requirements.txt

RUN chmod +x run.sh
CMD ["/app/run.sh"]
