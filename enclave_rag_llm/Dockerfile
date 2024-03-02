FROM amazonlinux

ARG KMS_KEY_ID
ENV KMS_KEY_ID=${KMS_KEY_ID}

RUN mkdir /app
WORKDIR /app
COPY . .

RUN pip3 install -r requirements.txt

RUN chmod +x run.sh
CMD ["/app/run.sh"]
