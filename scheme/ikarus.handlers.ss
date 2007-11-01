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


(library (ikarus system parameters)
  (export make-parameter)
  (import (except (ikarus) make-parameter))
  (define make-parameter
    (case-lambda
      [(x) 
       (case-lambda
         [() x]
         [(v) (set! x v)])]
      [(x guard)
       (unless (procedure? guard)
         (error 'make-parameter "not a procedure" guard))
       (set! x (guard x))
       (case-lambda
         [() x]
         [(v) (set! x (guard v))])])))


(library (ikarus system handlers)
  (export
    interrupt-handler $apply-nonprocedure-error-handler
    $incorrect-args-error-handler $multiple-values-error $debug
    $underflow-misaligned-error top-level-value-error car-error
    cdr-error fxadd1-error fxsub1-error cadr-error fx+-type-error
    fx+-types-error fx+-overflow-error $do-event)
  (import (except (ikarus) interrupt-handler)
          (only (ikarus system $interrupts) $interrupted? $unset-interrupted!))

  (define interrupt-handler
    (make-parameter
      (lambda ()
        (set-port-output-index! (console-output-port) 0)
        (error #f "interrupted"))
      (lambda (x)
        (if (procedure? x)
            x
            (error 'interrupt-handler "not a procedure" x)))))

  (define $apply-nonprocedure-error-handler
    (lambda (x)
      (error 'apply "not a procedure" x)))
  
  (define $incorrect-args-error-handler
    (lambda (p n)
      (error 'apply "incorrect number of argument" n p)))
  
  (define $multiple-values-error
    (lambda args
      (error 'apply 
             "incorrect number of values returned to single value context" 
             args)))
  
  (define $debug
    (lambda (x)
      (foreign-call "ik_error" (cons "DEBUG" x))))
  
  (define $underflow-misaligned-error
    (lambda ()
      (foreign-call "ik_error" "misaligned")))
  
  (define top-level-value-error
    (lambda (x)
      (cond
        [(symbol? x)
         (if (symbol-bound? x)
             (error 'top-level-value-error "BUG: should not happen" x)
             (error #f "unbound" (string->symbol (symbol->string x))))]
        [else
         (error 'top-level-value "not a symbol" x)])))
  
  (define car-error
    (lambda (x)
      (error 'car "not a pair" x)))
  
  (define cdr-error
    (lambda (x)
      (error 'cdr "not a pair" x)))
  
  (define fxadd1-error
    (lambda (x)
      (if (fixnum? x)
          (error 'fxadd1 "overflow")
          (error 'fxadd1 "not a fixnum" x))))
  
  (define fxsub1-error
    (lambda (x)
      (if (fixnum? x)
          (error 'fxsub1 "underflow")
          (error 'fxsub1 "not a fixnum" x))))
  
  (define cadr-error
    (lambda (x)
      (error 'cadr "invalid list structure" x)))
  
  (define fx+-type-error
    (lambda (x)
      (error 'fx+ "not a fixnum" x)))
  
  (define fx+-types-error
    (lambda (x y)
      (error 'fx+ "not a fixnum"
             (if (fixnum? x) y x))))
  
  (define fx+-overflow-error
    (lambda (x y)
      (error 'fx+ "overflow")))
  
  (define $do-event
    (lambda ()
      (when ($interrupted?)
        ($unset-interrupted!)
        ((interrupt-handler)))))
  )