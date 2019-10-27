#!/bin/bash
exec redis-server /etc/redis/redis.conf
redis-cli CONFIG SET protected-mode no