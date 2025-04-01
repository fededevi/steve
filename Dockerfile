FROM eclipse-temurin:17-jdk

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# add alpitronic root ca file to Ubuntu system root ca store
RUN cat - <<EOF > /usr/local/share/ca-certificates/alpitronic-global-root-ca.crt
-----BEGIN CERTIFICATE-----
MIIFqjCCA16gAwIBAgIQGtvZprGD65JJWmlxk62GkjBBBgkqhkiG9w0BAQowNKAP
MA0GCWCGSAFlAwQCAQUAoRwwGgYJKoZIhvcNAQEIMA0GCWCGSAFlAwQCAQUAogMC
ASAwJDEiMCAGA1UEAxMZYWxwaXRyb25pYy1nbG9iYWwtcm9vdC1jYTAeFw0yNDEy
MTIxMDQ3MzBaFw00NDEyMTIxMDU3MzBaMCQxIjAgBgNVBAMTGWFscGl0cm9uaWMt
Z2xvYmFsLXJvb3QtY2EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDN
/GwvPCIqzeFRp65KCZ8riufnJTtNWs0def+5PA4tv1TgvRoQta98t922cElBkqlU
EBX9LPkvT99c96gCWM/2cQB/BvOfliDjIdGOeuAiMcK7cEMTizKJRHmUwUc/EEPe
nKnX7pGQxya3URhkIjA5VO00G7ifZLE5AcA+tGe48bIftWzbiPo4CCCUFTS3DFCi
+z28js3sW0i7OwKIZ+JTzEB5pk53mTepV+kI/ONP8jY7go7iW7d8L6wDY5drBORy
jAjIU1VuNiR5taZnTvbPDB20SBUGCC+rfRw7KyggSSanEbp/i4cNeOiw9xu6XVW/
ZJBPrTUqX9MpgPV5Ygs9t7lw3T1My7SOCd2ZBR6bnJLs9+/sNvabZJV0gOqco6aD
Xv4sRLhNtwIncsQUqQ5TCNuwGh2MkXfRHi92z24XAzYFvubCSvyAjuXlVcSff4Nf
REQnQJGThhN6tglxOnc4yAmJllNwuShV+xvYD7NyS8Pi0kGDVF6NnOj9oZDtuoOc
04MHWcDMsIpecF6I7I8/f9zcLZKCkVFY9lAKJEk6iefa9UMArbMRQIRmRPBOYigO
muVK1hB/UGOlMWoJb4waU5c3MUi0CaV50EF63aa2ERSBTkadbyoyj1cxCJg5Fhcj
us3+GNwShX/ocWMas347WWQIGSnTcpmADIK55/cWCQIDAQABo3AwbjALBgNVHQ8E
BAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU7/LuID/Lzxsh0du69wap
dEQ12HwwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0gBBYwFDAGBgRVHSAAMAoGCCoD
BIsvQ1kFMEEGCSqGSIb3DQEBCjA0oA8wDQYJYIZIAWUDBAIBBQChHDAaBgkqhkiG
9w0BAQgwDQYJYIZIAWUDBAIBBQCiAwIBIAOCAgEAizZ9fCgx+k1lUELSyqvDwdZh
BeGEpXzjYt0yJ8fMDHTt1r20/kcmwyHl4TRxi10EisuLS9w0JKAB0Q9i2tM4hVsu
1WliB8LeJefZTWLqej69uvxIjPuCV60SczU99n9FPUb34c091jQEbfFA0yBkHpMz
TYflk4pkUvXveVbirNkdG4s/C1b82r1ViLhzg7+spbtmDc0RMncylHUihwL2xb+H
y241O9bctXtjwfkO5RrhVUVXeVSlcf+jaUlVz1RKdeDxYpBbmPC03VaI2NCWy590
pYp1znUpSiKY7/wOA77zG4q5tUOHp38shRFNDYP+PPKzj9q2BPsqxA2OkwEEJ9So
zZD/OccalTuIQrwJTmXT80vkJJVvBchHqiuEvAJoDouW2/i5u4K9QXATmtdnGBhW
eCGeRdNev4nKI0MTfIirCEm5Hl8IyltAss9mySPL03kqoRyiGb/iXZ++UpGBVD6R
11yVCKmAviEepGzoCzPLtButZ+riN6tYl/C21SMc8m5NGfeEkT6sQp4kIKtCpL1T
pHqqXHvd8ETHYBoMOzsVyaP4r8X/h0urHCVRYxk1Aysn0muoI1EWqfAp0DNzGk0p
Q3b5uIrpIfMp45QL3+/6HlPnwGhum3e9kWmVDGvXbPwFsMfxu0lJoVx3wuUuaWuj
DQMzOL4tsPSJUiah0rs=
-----END CERTIFICATE-----
EOF
RUN update-ca-certificates

# add alpitronic root ca file to JAVA system root ca store
RUN keytool -importcert -file /usr/local/share/ca-certificates/alpitronic-global-root-ca.crt -cacerts -keypass changeit -storepass changeit -noprompt -alias alpitronic-global-root-ca

MAINTAINER Ling Li

# Download and install dockerize.
# Needed so the web container will wait for MariaDB to start.
ENV DOCKERIZE_VERSION v0.20.2
RUN curl -sfL https://github.com/powerman/dockerize/releases/download/"$DOCKERIZE_VERSION"/dockerize-`uname -s`-`uname -m` | install /dev/stdin /usr/local/bin/dockerize

EXPOSE 8180
EXPOSE 8443
WORKDIR /code

VOLUME ["/code"]

# Copy the application's code
COPY . /code

# Wait for the db to startup(via dockerize), then 
# Build and run steve, requires a db to be available on port 3306
CMD dockerize -wait tcp://mariadb:3306 -timeout 60s && \
	./mvnw clean package -Pdocker -Djdk.tls.client.protocols="TLSv1,TLSv1.1,TLSv1.2" && \
	java -XX:MaxRAMPercentage=85 -jar target/steve.jar

