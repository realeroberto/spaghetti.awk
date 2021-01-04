#!/usr/bin/awk -f

################################################################################
#                                         
# An AWK implementation of the Chinese remainder theorem.
#
# Given a positive integer k, positive integers a_1, ..., a_k which are
# pairwise coprime and arbitrary integers n_1, ..., n_k, we find the unique
# x such that
#
#     x = a_1 (mod n_1), ..., x = a_k (mod n_k)
#
# Copyright (c) 2018 Roberto Reale
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
################################################################################


#
# absolute value
#

function abs(a) {
    return a >= 0 ? a : -a
}

#
# sign function
#

function sign(a) {
    return a >= 0 ? 1 : -1
}

#
# extended euclidean algorithm, private function
#
#   given two non-negative integers a, b, calculates
#   the gcd(a, b) and the unique s, t such that s*a + t*b = gcd(a, b)
#
# input: a, b
#
# output: a string in the form "s;t;gcd"
#
# warning: no check is performed on a, b
#

function __extended_gcd(a, b, gcd, q, r, s, t, v) {
    if (b == 0)
        return "1;0;"a
    
    q = int(a / b)
    r = a % b
    
    split(__extended_gcd(b, r), v, ";")
    
    s = v[1]
    t = v[2]
    gcd = v[3]

    return t ";" s - q*t ";" gcd
}

#
# extended euclidean algorithm, public interface
#
# input: arbitrary integers a, b
#
# output: a string in the form "s;t;gcd"
#

function extended_gcd(a, b, x, y, gcd, v) {
    split(__extended_gcd(abs(a), abs(b)), v, ";")
    
    x = v[1] * sign(a)
    y = v[2] * sign(b)
    gcd = v[3]
    
    return x ";" y ";" gcd
}

#
# return 0 if the string s represents a valid integer,
# -1 otherwise
#

function validate_int(s) {
    if (s !~ /^[+-]*[0-9]+$/)
        return -1
    else
        return 0
}

#
# return 0 if the string s represents a valid positive integer,
# -1 otherwise
#

function validate_positive_int(s) {
    if (s !~ /^\+*[0-9]+$/)
        return -1
    else
        return 0
}

#
# Chinese remainder theorem --- constructive algorithm
#
#   given positive integers a_1, ..., a_k which are pairwise coprime
#   and arbitrary integers n_1, ..., n_k, we find the unique x such
#   that
#
#       x = a_1 (mod n_1), ..., x = a_k (mod n_k)
#
#   (see http://en.wikipedia.org/wiki/Chinese_remainder_theorem)
#
#
# input: k
#        a_s: string of the form "a_1;...;a_k"
#        n_s: string of the form "n_1;...;n_k"
#
# output: the remainder rem or the string INV if the integers
#         n_1, ..., n_k are not pairwise coprime
#

function chinese_remainder(k, a_s, n_s, v, w, z, s, gcd, e, i, N, rem) {
    N = 1
    rem = 0
    
    split(a_s, v, ";")
    split(n_s, w, ";")
    
    for (i = 1; i <= k; i++) {
        N = N * w[i]
    }
    
    for (i = 1; i <= k; i++) {
        split(extended_gcd(w[i], N/w[i]), z, ";")
        s = z[2]
        gcd = z[3]

        if (abs(gcd) != 1)
            return "INV"
        
        e = s * N / w[i]
        
        rem = rem + v[i]*e
    }
    
    return rem
}

#
# initialize the input state machine
#

BEGIN {
    state_reading_a_s = 0
    state_reading_n_s = 1
    state = state_reading_a_s
}

#
# MAIN LOOP
#
#   read two consecutive lines of input, the first one being
#   of the form a_1 ... a_k, the second one of the form n_1 ... n_k;
#   then print the result, then start again
#

{
    if (state == state_reading_a_s) {
        a_s = ""
        k = NF
        
        for (i = 1; i <= k; i++) {
            if (validate_int($i) < 0) {
                print "ERROR: invalid field $"i
                next
            }
            
            if (i == 1)
                a_s = $i
            else
                a_s = a_s ";" $i
        }
    
        state = state_reading_n_s
    } else {
        n_s = ""
        N = 1

        if (NF != k) {
            print "ERROR: invalid number of fields"
            exit
        }
        
        for (i = 1; i <= k; i++) {
            if (validate_positive_int($i) < 0) {
                print "ERROR: invalid field $"i
                next
            }
            
            if (i == 1)
                n_s = $i
            else
                n_s = n_s ";" $i
        }
        
        if ((rem = chinese_remainder(k, a_s, n_s)) == "INV") {
            print "ERROR: the n_s are not pairwise coprime"
            exit
        } else {
            # print output #
            print rem
            exit
        }
    }
}

# ex: ts=4 sw=4 et filetype=awk
