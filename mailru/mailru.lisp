(defun iter-check-number (first rest)
  (cond ((null rest) t)
        ((and (= first 1) (= (car rest) 1))
         nil)
        (t (iter-check-number (car rest) (cdr rest)))))

(defun check-number (bit-number)
  (if (null bit-number)
      nil
      (if (iter-check-number (car bit-number) (cdr bit-number))
          bit-number)))


;; (check-number '())
;; (check-number '(1 1 0 1 0 1 0 1 0 1 0 1 0 1))
;; (check-number '(1 0 1 0 1 1 1 0 1 0 1 0 1))
;; (check-number '(1 0 1 0 1 0 1 0 1 0 1))
;; (check-number '(0 0 0 1 1))
(defun iter-ten-to-bin (result number)
  (if (or (= number 0) (= number 1))
      (cons number result)
      (multiple-value-bind (quot rem)
          (floor number 2)
        (iter-ten-to-bin (cons rem result) quot))))

(defun ten-to-bin (number)
  (if number
      (iter-ten-to-bin '() number)
      nil))

;; (ten-to-bin 65)
;; (ten-to-bin 0)
;; (ten-to-bin 1)
;; (ten-to-bin 41)
;; (ten-to-bin 32768)
(defun append-zero (number len)
  (if (< (length number) len)
      (append-zero (cons 0 number) len)
      number))

;; (append-zero '(1) 16)
(defun make-test-numbers (amount max-value)
  (defun iter (amount max-value result)
    (if (= amount 0)
        result
        (iter (- amount 1)
              max-value
              (cons (random (+ max-value 1)) result))))
  (iter amount max-value '()))

(defparameter *test-numbers-list* (make-test-numbers 100 32768))

(defun test-start (numbers-list num-len)
  (let ((bin-numbers-list '())
        (aligned-bin-numbers-list '())
        (ten-numbers-list numbers-list)
        (result-list '()))
    ;; перевели все числа в бинарное представление
    (do ((i (length ten-numbers-list) (decf i)))
        ((= i 0))
      (setf bin-numbers-list (cons (ten-to-bin (car ten-numbers-list))
                                   bin-numbers-list))
      (setf ten-numbers-list (cdr ten-numbers-list)))
    ;; выравниваем числа до 2х байт (заполняем старшие разряды нулями, если число меньше
    ;; 2 байт)
    (do ((i (length bin-numbers-list) (decf i)))
        ((= i 0))
      (setf aligned-bin-numbers-list (cons (append-zero (car bin-numbers-list) num-len)
                                           aligned-bin-numbers-list))
      (setf bin-numbers-list (cdr bin-numbers-list)))
    ;; проверяем все числа предмет ряом стоящих единиц
    (do ((i (length aligned-bin-numbers-list) (decf i)))
        ((= i 0) result-list)
      (let ((cur-result (check-number (car aligned-bin-numbers-list))))
        (if cur-result
            (setf result-list (cons cur-result result-list)))
        (setf aligned-bin-numbers-list (cdr aligned-bin-numbers-list))))))

;; ЗАПУСК
;; (test-start *test-numbers-list* 16)
