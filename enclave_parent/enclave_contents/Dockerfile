FROM enclave_base_image

RUN amazon-linux-extras install python3.8
RUN yum install iproute -y

ENV AWS_STS_REGIONAL_ENDPOINTS=regional
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/app
ENV KMS_KEY_ID=${KMS_KEY_ID}

WORKDIR /app
COPY . .
RUN pip3.8 install -r /app/requirements.txt

RUN chmod +x /app/run.sh
CMD ["/app/run.sh"]
