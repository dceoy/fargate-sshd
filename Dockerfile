FROM dceoy/sshd:latest

ADD keys/id_rsa.pub /etc/ssh/authorized_keys/root
ARG SSH_PORT

RUN set -ue \
      && echo '#!/usr/bin/env bash' > /usr/local/bin/sshd.sh \
      && echo "set -uex && /usr/sbin/sshd -D -e -p ${SSH_PORT}" \
        >> /usr/local/bin/sshd.sh \
      && chmod +x /usr/local/bin/sshd.sh

EXPOSE ${SSH_PORT}

CMD ["/usr/local/bin/sshd.sh"]
