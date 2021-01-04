#!/usr/bin/awk -f

################################################################################
#                                         
# An AWK implementation of a very basic Web Service
#
# Prototype taken verbatim from https://www.gnu.org/software/gawk/manual/gawkinet/gawkinet.html#Primitive-Service
#
################################################################################


BEGIN {
    RS = ORS = "\r\n"
    HttpService = "/inet/tcp/8080/0/0"
    HttpRoot = "/var/www/html"

    file = HttpRoot "/index.html"
    stream = ""
    while (( getline line < file ) > 0)
        stream = stream "\r\n" line
    close(file)

    Len = length(stream) + length(ORS)

    print "HTTP/1.0 200 OK"          |& HttpService
    print "Content-Length: " Len ORS |& HttpService
    print stream                     |& HttpService

    while ((HttpService |& getline) > 0)
        continue;

    close(HttpService)
}

# ex: ts=4 sw=4 et filetype=awk
