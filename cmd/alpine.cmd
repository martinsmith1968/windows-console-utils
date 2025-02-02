@ECHO OFF

SETLOCAL

SET VERSION=latest

:PARSE

docker run -it --hostname alpine_%VERSION% --name alpine_%VERSION% alpine:%VERSION%
