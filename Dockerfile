FROM dceoy/sshd:latest

ADD keys/id_rsa.pub /etc/ssh/authorized_keys/root
ADD sshd.sh /usr/local/bin/sshd.sh

ARG SSH_PORT
ENV SSH_PORT ${SSH_PORT}
EXPOSE ${SSH_PORT}

CMD ["/usr/local/bin/sshd.sh"]
