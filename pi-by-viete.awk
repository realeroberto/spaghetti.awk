#!/usr/bin/awk -f

################################################################################
#                                         
# Calculates an approximation of PI by means of Vi`ete's formula
#
#   see http://en.wikipedia.org/wiki/Vi`ete's_formula
#
################################################################################

function abs(x) {
    return x >= -x ? x : -x
}
 
BEGIN {
    tol = .000001
    x = sqrt(2)
    v_new = x / 2
 
    while (abs(v_new - v) >= tol) {
        x = sqrt(2 + x)
        v = v_new
        v_new = v * (x / 2)
    }
 
    print 2 / v_new
 
    exit
}

# ex: ts=4 sw=4 et filetype=awk
