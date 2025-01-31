;; Doctors Registry Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))

;; Data structures
(define-map doctors
  principal
  {
    name: (string-utf8 64),
    license: (string-ascii 32),
    specialty: (string-utf8 64),
    verified: bool
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
      verified: false
    }))
)

(define-public (verify-doctor (doctor principal))
  (if (is-eq tx-sender contract-owner)
    (ok (map-set doctors
      doctor
      (merge (unwrap-panic (map-get? doctors doctor))
        { verified: true })))
    err-unauthorized)
)

(define-read-only (is-verified-doctor (address principal))
  (default-to false
    (get verified (map-get? doctors address)))
)
