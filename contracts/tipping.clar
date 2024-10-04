;; title: 
;; version: 
;; summary: 

;; traits
;;

;; token definitions
;;

;; constants
(define-constant tip-amount u1000000)
(define-constant err-sending-tip (err 101))
(define-constant err-unauthorized (err 102))

;; data variables 
;;

;; private function 

;; public functions
(define-public (tip (recipient principal))
(begin
    (asserts! (not (is-eq tx-sender recipient)) (err u102))
    (asserts! (is-ok (stx-transfer? tip-amount tx-sender recipient)) (err u101))
    (ok true)
))
