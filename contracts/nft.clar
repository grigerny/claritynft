;; title: Amazing Aardvarks
;; version: 0.04
;; summary: This is a collection of 10,000 amazing aardvarks
;; description: Some amazing description here

;; FOR TESTNET
;; traits
(use-trait commission-trait .commission-trait.commission)

;; FOR MAINNET
;; traits
;; NFT TRAIT: (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; COMMISSION TRAIT: (use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)
;;

;; token definitions 
(define-non-fungible-token amazing-aardvarks uint)
;;

(define-constant DEPLOYER tx-sender)

;; constants 
(define-constant err-wrong-commission (err u301))
(define-constant err-not-authorized (err u401))
(define-constant err-not-token-owner (err u402))
(define-constant err-not-found (err u404))
(define-constant err-listing (err u507))
(define-constant err-sold-out (err u508))

;; supply
(define-constant supply u100)

;; Sets contract-owner to address that deploys the contract
(define-constant contract-owner tx-sender)

;; data variables 
(define-data-var last-token-id uint u0)
(define-data-var base-uri (string-ascii 256) "https://gateway/ipfs/folderCID/")
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
        (asserts! (is-eq tx-sender sender) err-not-authorized)
        (nft-transfer? amazing-aardvarks token-id tx-sender recipient)))

(define-public (mint (recipient principal))
(let 
    ((token-id (+ (var-get last-token-id) u1)))
    (asserts! (is-eq tx-sender contract-owner) err-not-token-owner)
    (asserts! (< (var-get last-token-id) supply) err-sold-out)
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

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
(begin
    (asserts!  (is-eq tx-sender DEPLOYER) (err u401))
    (var-set base-uri new-base-uri)
    (ok true)))

;; read-only functions
(define-read-only (get-last-token-id (id uint)) 
    (ok (var-get last-token-id)))

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? amazing-aardvarks id)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get base-uri) "{id}") ".json"))))

(define-map balances {address: principal} {balance: uint})