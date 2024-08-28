;; title: Amazing Aardvarks
;; version: 0.02
;; summary: This is a collection about a group of amazing aardvarks
;; description: Some description here

;; traits
(use-trait commission-trait .commission-trait.commission)
;;

;; token definitions 
(define-non-fungible-token amazing-aardvarks uint)
;;

;; constants 
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-wrong-commission (err u301))
(define-constant err-not-authorized (err u401))
(define-constant err-not-found (err u404))
(define-constant err-listing (err u507))

;; Sets contract-owner to equal address that deploys the contract
(define-constant contract-owner tx-sender)

;; data variables 
(define-data-var last-token-id uint u0)
;;

;; maps 
(define-map market uint {price: uint, commission: principal})
;;

;; private function 
(define-private (is-sender-owner (id uint))
    (let ((owner (unwrap! (nft-get-owner? amazing-aardvarks id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

;; public function 
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (nft-transfer? amazing-aardvarks token-id sender recipient)))

(define-public (mint (recipient principal))
    (let
        ((token-id (+ (var-get last-token-id) u1)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (nft-mint? amazing-aardvarks token-id recipient))
        (var-set last-token-id token-id)
        (ok token-id)))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
    (let ((listing {price: price, commission: (contract-of comm )}))
        (asserts! (is-sender-owner id) err-not-authorized)
        (map-set market id listing)
        (print (merge listing {a: "list-in-ustx", id: id}))
        (ok true)))

(define-public (unlist-in-ustx (id uint))
    (begin
        (asserts! (is-sender-owner id) err-not-authorized)
        (map-delete market id)
        (print {a: "unlist-in-ustx", id: id})
        (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
    (let ((owner (unwrap! (nft-get-owner? amazing-aardvarks id) err-not-found))
        (listing (unwrap! (map-get? market id) err-listing))
        (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) err-wrong-commission)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (nft-transfer? amazing-aardvarks id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))