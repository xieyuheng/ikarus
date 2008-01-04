#!/usr/bin/env ikarus --r6rs-script
;;; Ikarus Scheme -- A compiler for R6RS Scheme.
;;; Copyright (C) 2006,2007  Abdulaziz Ghuloum
;;; 
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License version 3 as
;;; published by the Free Software Foundation.
;;; 
;;; This program is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; General Public License for more details.
;;; 
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; vim:syntax=scheme
(import 
  (ikarus compiler)
  (match)
  (except (ikarus) assembler-output))

(define (compile1 x)
  (printf "Compiling ~s\n" x)
  (let ([p (open-file-output-port "test64.fasl" (file-options no-fail))])
    (parameterize ([assembler-output #t])
      (compile-core-expr-to-port x p))
    (close-output-port p)))

(define (compile-and-run x) 
  (compile1 x)
  (let ([rs (system "../src/ikarus -b test64.fasl > test64.out")])
    (unless (= rs 0) (error 'run1 "died"))
    (with-input-from-file "test64.out"
      (lambda () (get-string-all (current-input-port))))))

(define (compile-test-and-run expr expected)
  (let ([val (compile-and-run expr)])
    (unless (equal? val expected) 
      (error 'compile-test-and-run "failed:got:expected" val expected))))

(define (test-all)
  (for-each
    (lambda (x)
       (compile-test-and-run (car x) (cadr x)))
    all-tests))

(define all-tests
  '([(quote 42)  "42\n"]
    [(quote #f)  "#f\n"]
    [(quote ())  "()\n"]))

(define (self-evaluating? x)
  (or (number? x) (char? x) (boolean? x) (null? x) (string? x)))

(define (fixup x)
  (match x
    [,n (guard (self-evaluating? n)) `(quote ,n)]
    [,_ (error 'fixup "invalid expression" _)]))

(define-syntax add-tests-with-string-output 
  (lambda (x)
    (syntax-case x (=>)
      [(_ name [test => string] ...) 
       #'(set! all-tests
           (append all-tests
              (list 
                (list (fixup 'test) string) 
                ...)))])))

(include "tests/tests-1.1-req.scm")
(include "tests/tests-1.2-req.scm")

(test-all)
(printf "Passed ~s tests\n" (length all-tests))
(printf "Happy Happy Joy Joy\n")
