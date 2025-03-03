;; Doctors Registry Contract - Enhanced Version

;; Constants and errors
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-invalid-status (err u101))
(define-constant err-invalid-license (err u102))
(define-constant err-invalid-specialty (err u103))

;; Approved specialties
(define-data-var approved-specialties (list 20 (string-utf8 64)) (list 
  "Cardiology"
  "Neurology"
  "Pediatrics"
  "Internal Medicine"
  "Surgery"
))

;; Data structures
(define-map doctors
  principal
  {
    name: (string-utf8 64),
    license: (string-ascii 32),
    specialty: (string-utf8 64),
    verified: bool,
    status: (string-ascii 10),
    last-updated: uint,
    suspension-reason: (optional (string-utf8 256))
  }
)

[... rest of the enhanced doctors registry contract ...]
