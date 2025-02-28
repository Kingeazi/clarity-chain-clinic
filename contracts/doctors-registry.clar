;; Doctors Registry Contract - Enhanced Version

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-invalid-status (err u101))

;; Data structures
(define-map doctors
  principal
  {
    name: (string-utf8 64),
    license: (string-ascii 32),
    specialty: (string-utf8 64),
    verified: bool,
    status: (string-ascii 10),  ;; active or inactive
    last-updated: uint
  }
)

;; Public functions
(define-public (register-doctor 
  (name (string-utf8 64))
  (license (string-ascii 32))
  (specialty (string-utf8 64)))
  (ok (map-set doctors
    tx-sender
    {
      name: name,
      license: license,
      specialty: specialty,
      verified: false,
      status: "active",
      last-updated: block-height
    }))
)

(define-public (verify-doctor (doctor principal))
  (let ((doc-data (unwrap! (map-get? doctors doctor) err-not-found)))
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (ok (map-set doctors
      doctor
      (merge doc-data { 
        verified: true,
        last-updated: block-height 
      }))))
)

(define-public (deactivate-doctor (doctor principal))
  (let ((doc-data (unwrap! (map-get? doctors doctor) err-not-found)))
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (ok (map-set doctors
      doctor
      (merge doc-data { 
        status: "inactive",
        last-updated: block-height 
      }))))
)

(define-read-only (is-verified-doctor (address principal))
  (let ((doc-data (map-get? doctors address)))
    (and
      (is-some doc-data)
      (get verified (unwrap-panic doc-data))
      (is-eq (get status (unwrap-panic doc-data)) "active")))
)

(define-read-only (get-doctor-info (address principal))
  (ok (map-get? doctors address))
)
