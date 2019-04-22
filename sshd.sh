#!/usr/bin/env bash

set -uex
/usr/sbin/sshd -D -e -p ${SSH_PORT}
