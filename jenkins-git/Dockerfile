FROM debian:buster-backports

RUN apt-get update && apt-get install -y git openssh-server

COPY id_rsa.pub /opt/id_rsa.pub

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

RUN useradd git
RUN mkdir -p /home/git/sources && chown -R git:git /home/git

WORKDIR /home/git
USER git

RUN mkdir /home/git/.ssh/ && touch /home/git/.ssh/authorized_keys
RUN cat /opt/id_rsa.pub >>  /home/git/.ssh/authorized_keys

USER root
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["bash"]
