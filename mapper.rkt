#lang racket
(module+ test
  (require rackunit))

(require racket/match)
(require racket/system)

(define env (box '()))

(define (exit? expr)
  (match expr
    ['(exit) #t]
    [_ #f]))

(define (help? expr)
  (match expr
    ['(help) #t]
    [_ #f]))

(define (version? expr)
  (match expr
    ['(version) #t]
    [_ #f]))

(define-syntax red
  (syntax-rules (red bold)
    [(red x)
     (format "\u001b[31m~a\u001b[0m" x)]
    [(red bold x)
     (format "\u001b[1;31m~a\u001b[0m" x)]))

(define-syntax green
  (syntax-rules (green bold)
    [(green x)
     (format "\x1b[32m~a\x1b[0m" x)]
    [(green bold x)
     (format "\u001b[1;32m~a\u001b[0m" x)]))

(define-syntax yellow
  (syntax-rules (yellow bold)
    [(yellow x)
     (format "\x1b[33m~a\x1b[0m" x)]
    [(yellow bold x)
     (format "\u001b[1;33m~a\u001b[0m" x)]))

(define-syntax blue
  (syntax-rules (blue bold)
    [(blue x)
     (format "\x1b[34m~a\x1b[0m" x)]
    [(blue bold x)
     (format "\u001b[1;34m~a\u001b[0m" x)]))

(define-syntax magenta
  (syntax-rules (magenta bold)
    [(magenta x)
     (format "\x1b[35m~a\x1b[0m" x)]
    [(bagenta bold x)
     (format "\u001b[1;35m~a\u001b[0m" x)]))

(define-syntax cyan
  (syntax-rules (cyan bold)
    [(cyan x)
     (format "\x1b[36m~a\x1b[0m" x)]
    [(cyan bold x)
     (format "\u001b[1;36m~a\u001b[0m" x)]))

(define (display-lines lines)
  (cond ((null? lines) '())
        ((not (pair? lines)) '())
        ((string? (car lines))
         (displayln (car lines))
         (display-lines (cdr lines)))
        (else
          (display-lines (cdr lines)))))

(define (undefined expr)
  (format (red bold "~s undefined") expr))

(define (help)
  (begin
    (display-lines 
      '("hello"
        "hello, hello"))))

(define (version)
  (begin
    (display-lines 
      '("kame-mapper version 0.0.0"))))

;; for reserved function
(define (reserved-function? expr)
  (cond ((null? expr) #f)
        ((pair? expr)
         (match (car expr)
           ['+ #t]
           ['- #t]
           ['* #t]
           ['/ #t]
           ['= #t]
           ['> #t]
           ['< #t]
           ['exact->inexact #t]
           ['list #t]
           ['car #t]
           ['cdr #t]
           ['cons #t]
           [_ #f]))
        (else #f)))

(define (eval-args args)
  (let loop ((lst args) (ret '()))
    (cond ((null? lst) (reverse ret))
          (else
            (loop (cdr lst)
                  (cons (evaluate (car lst)) ret))))))

(define (eval-reserved-function expr)
  (match* ((car expr) (cdr expr))
    [('+ _) (apply + (eval-args (cdr expr)))]
    [('- _) (apply - (eval-args (cdr expr)))]
    [('* _) (apply * (eval-args (cdr expr)))]
    [('/ _) (apply / (eval-args (cdr expr)))]
    [('= _) (apply = (eval-args (cdr expr)))]
    [('> _) (apply > (eval-args (cdr expr)))]
    [('< _) (apply < (eval-args (cdr expr)))]
    [('exact->inexact _) (apply exact->inexact (evaluate (cdr expr)))]
    [('list _) (apply list (evaluate (cdr expr)))]
    [('car _) (apply car (evaluate (cdr expr)))]
    [('cdr _) (apply cdr (evaluate (cdr expr)))]
    [('cons _) (apply cons (evaluate (cdr expr)))]
    [(_ _) '()]))

;; for shell command
(define (shell-command? expr)
  (cond ((null? expr) #f)
        ((pair? expr)
         (match (car expr)
           ['open #t]
           ['shell #t]
           [_ #f]))
        (else #f)))

(define (eval-open expr)
  (match* ((car expr) (cdr expr))
    [('open (list x))
     (system (format "open \"~a\"" x))]
    [('open (list '-a x))
     (system (format "open -a \"~a\"" x))]
    [('open (list '-a x y))
     (system (format "open -a \"~a\" \"~a\"" x y))]
    [('open (list '-a x y z))
     (cond ((system (format "open -a \"~a\" \"~a\"" x y))
            (displayln (format "~a" z))
            #t)
           (else #f))]
    [(_ _) (undefined expr)]))

(define (eval-shell-command expr)
  (match* ((car expr) (cdr expr))
    [('open _) (eval-open expr)]
    [(_ _) (undefined expr)]))

(define (extension-file sym)
  (format "./sexp/~a.sexp" sym))

  (define (read-sexp sym)
  (call-with-input-file (extension-file sym)
                        (lambda (in)
                          (read in))))

(define (extension-command? expr)
  (if (pair? expr)
    (file-exists? (extension-file (car expr)))
    #f))

(define (atom? expr)
  (or (number? expr)
      (string? expr)))

(define (eval-extension-command expr)
  (define (print-commands-list cmds expr)
    (cond ((null? cmds) #t)
          (else 
            (let* ((row (car cmds))
                   (sym (car row))
                   (note (cdr (second (cdr row)))))
              (displayln (format "(~a ~a) \"~a\"" (car expr) sym note)))
            (print-commands-list (cdr cmds) expr))))
  (define (lookup-command cmds expr)
    (let ((data (assq (second expr) cmds)))
      (if data
        (cdr (assq 'command (cdr data)))
        #f)))
  (let ((cmds (read-sexp (car expr))))
    (match* ((car expr) (cdr expr))
      [(a (list 'list))
       (let ((cmds (read-sexp (car expr))))
         (print-commands-list cmds expr))]
      [(a (list b)) 
       (let* ((cmds (read-sexp (car expr)))
              (cmd (lookup-command cmds expr)))
         (if cmd
           (evaluate cmd)
           (undefined expr)))]
      [(_ _) (undefined expr)])))

(define (evaluate expr)
  (cond ((null? expr) '())
        ((reserved-function? expr)
         (eval-reserved-function expr))
        ((shell-command? expr)
         (eval-shell-command expr))
        ((extension-command? expr)
         (eval-extension-command expr))
        ((atom? expr) expr)
        (else
          (undefined expr))))

(define (repl)
  (define (read-command)
;    (display (green bold "> "))
    (display (green bold "🐢 "))
    (read))
  (let ([expr (read-command)])
    (cond [(exit? expr) #f]
          [(help? expr) (help) (repl)]
          [(version? expr) (version) (repl)]
          [else
            (let ((result (evaluate expr)))
              (displayln (format "~a" result))
              (repl))])))

(module+ test

  (check-equal? (reserved-function? '(+ 1 2)) #t)
  (check-equal? (reserved-function? '(hoge 1 2)) #f)
  (check-equal? (reserved-function? '()) #f)

  (check-equal? (evaluate '(+ 1 2)) 3)
  (check-equal? (evaluate '(+ 1 2 1 2)) 6)
  (check-equal? (evaluate '(+ 1 2 (+ 1 2))) 6)
  (check-equal? (evaluate '(+ 1 2 (+ 1 2) (+ 1 2))) 9)
  (check-equal? (evaluate '(+ 1 2 (+ 1 2 (+ 1 2)) (+ 1 2))) 12)
  
  (check-equal? (evaluate '(- 10 2)) 8)
  (check-equal? (evaluate '(- 10 2 1)) 7)
  (check-equal? (evaluate '(- 10 2 (- 3 2))) 7)
  (check-equal? (evaluate '(- 10 2 (- 3 2) (- 3 2))) 6)
  (check-equal? (evaluate '(- 10 2 (+ 3 2) (- 3 2))) 2)

)

(module+ main
#|
  (require racket/cmdline)
  (define who (box "world"))
  (command-line
    #:program "my-program"
    #:once-each
    [("-n" "--name") name "Who to say hello to" (set-box! who name)]
    #:args ()
    (printf "hello ~a~n" (unbox who)))
|#
  (define x (repl))
)

