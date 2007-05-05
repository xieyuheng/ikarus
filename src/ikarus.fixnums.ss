
(library (ikarus fixnums)
  (export fxzero? fxadd1 fxsub1 fxlognot fx+ fx- fx* fxquotient
          fxremainder fxmodulo)
  (import 
    (only (scheme) $fxadd1 $fxsub1 $fxlognot $fxzero? $fxquotient
          $fxmodulo $fx+ $fx- $fx*)
    (except (ikarus) fxzero? fxadd1 fxsub1 fxlognot fx+ fx- fx*
            fxquotient fxremainder fxmodulo))

  (define fxzero?
    (lambda (x)
      (cond
        [(eq? x 0) #t]
        [(fixnum? x) #f]
        [else (error 'fxzero? "~s is not a fixnum" x)])))
  
  (define fxadd1
    (lambda (n)
      (if (fixnum? n)
          ($fxadd1 n)
          (error 'fxadd1 "~s is not a fixnum" n))))
  
  (define fxsub1 
    (lambda (n) 
      (if (fixnum? n)
          ($fxsub1 n)
          (error 'fxsub1 "~s is not a fixnum" n))))

  (define fxlognot 
    (lambda (x)
      (unless (fixnum? x) 
        (error 'fxlognot "~s is not a fixnum" x))
      ($fxlognot x)))

  (define fx+ 
    (lambda (x y) 
      (unless (fixnum? x)
        (error 'fx+ "~s is not a fixnum" x))
      (unless (fixnum? y)
        (error 'fx+ "~s is not a fixnum" y))
      ($fx+ x y)))

  (define fx-
    (lambda (x y) 
      (unless (fixnum? x)
        (error 'fx- "~s is not a fixnum" x))
      (unless (fixnum? y)
        (error 'fx- "~s is not a fixnum" y))
      ($fx- x y)))

  (define fx*
    (lambda (x y) 
      (unless (fixnum? x)
        (error 'fx* "~s is not a fixnum" x))
      (unless (fixnum? y)
        (error 'fx* "~s is not a fixnum" y))
      ($fx* x y)))
 
  (define fxquotient
    (lambda (x y) 
      (unless (fixnum? x)
        (error 'fxquotient "~s is not a fixnum" x))
      (unless (fixnum? y)
        (error 'fxquotient "~s is not a fixnum" y))
      (when ($fxzero? y)
        (error 'fxquotient "zero dividend ~s" y))
      ($fxquotient x y))) 
  
  (define fxremainder
    (lambda (x y) 
      (unless (fixnum? x)
        (error 'fxremainder "~s is not a fixnum" x))
      (unless (fixnum? y)
        (error 'fxremainder "~s is not a fixnum" y))
      (when ($fxzero? y)
        (error 'fxremainder "zero dividend ~s" y))
      (let ([q ($fxquotient x y)])
        ($fx- x ($fx* q y)))))
   
  (define fxmodulo
    (lambda (x y) 
      (unless (fixnum? x)
        (error 'fxmodulo "~s is not a fixnum" x))
      (unless (fixnum? y)
        (error 'fxmodulo "~s is not a fixnum" y))
      (when ($fxzero? y)
        (error 'fxmodulo "zero dividend ~s" y))
      ($fxmodulo x y)))


  )