#!/bin/sh

./tsched $1 70 &
usleep 1000;
./tsched $1 99 &
usleep 1000;
./tsched $1 70 &
usleep 1000;
./tsched $1 70 &
usleep 1000;
./tsched $1 50 &
usleep 1000;
./tsched $1 30 &
usleep 1000;
./tsched $1 10 &
