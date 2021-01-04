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
    Hello = "<HTML><HEAD>" \
    "<TITLE>A Famous Greeting</TITLE></HEAD>" \
    "<BODY><H1>Hello, world</H1></BODY></HTML>"
    Len = length(Hello) + length(ORS)
    print "HTTP/1.0 200 OK"          |& HttpService
    print "Content-Length: " Len ORS |& HttpService
    print Hello                      |& HttpService
    while ((HttpService |& getline) > 0)
        continue;
    close(HttpService)
}

# ex: ts=4 sw=4 et filetype=awk
