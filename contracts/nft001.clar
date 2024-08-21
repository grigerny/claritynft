;; title: Amazing Aardvarks
;; version: 0.01
;; summary: This is a collection about a group of amazing aardvarks
;; description: Some description here

;; traits
;;

;; token definitions 
(define-non-fungible-token amazing-aardvarks uint)
;;

;; constants 
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; Sets contract-owner to equal address that deploys the contract
(define-constant contract-owner tx-sender)

;; data variables 
(define-data-var last-token-id uint u0)
;;

;; maps 
;;

;; public function 
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
(begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (nft-transfer? amazing-aardvarks token-id sender recipient)))

(define-public (mint (recipient principal))
    (let
        (
            (token-id (+ (var-get last-token-id) u1))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (nft-mint? amazing-aardvarks token-id recipient))
        (var-set last-token-id token-id)
        (ok token-id)))

