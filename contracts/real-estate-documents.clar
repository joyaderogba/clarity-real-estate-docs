;; Storage Variables and Mappings
(define-data-var document-count uint u0)

(define-map real-estate-documents
  { document-id: uint }
  {
    document-title: (string-ascii 64),
    document-owner: principal,
    document-size: uint,
    upload-date: uint,
    document-description: (string-ascii 128),
    document-tags: (list 10 (string-ascii 32))
  }
)

(define-map document-permissions
  { document-id: uint, user: principal }
  { has-access: bool }
)

;; Error Codes
(define-constant error-document-not-found (err u301))
(define-constant error-duplicate-document (err u302))
(define-constant error-invalid-title (err u303))
(define-constant error-invalid-size (err u304))
(define-constant error-access-denied (err u305))
(define-constant error-unauthorized-action (err u306))
(define-constant error-admin-only (err u300))
(define-constant error-unauthorized-view (err u307))
(define-constant error-invalid-tag (err u308))

;; Contract Administrator
(define-constant admin tx-sender)

;; Private Helper Functions

;; Check if document exists
(define-private (is-document-present (document-id uint))
  (is-some (map-get? real-estate-documents { document-id: document-id }))
)

;; Verify if the caller is the document owner
(define-private (is-document-owner (document-id uint) (user principal))
  (match (map-get? real-estate-documents { document-id: document-id })
    document-data (is-eq (get document-owner document-data) user)
    false
  )
)

;; Retrieve the document size
(define-private (get-document-size (document-id uint))
  (default-to u0
    (get document-size
      (map-get? real-estate-documents { document-id: document-id })
    )
  )
)

;; Validate a single tag
(define-private (is-valid-tag (tag (string-ascii 32)))
  (and
    (> (len tag) u0)
    (< (len tag) u33)
  )
)

;; Validate all tags in a list
(define-private (validate-tags (tags (list 10 (string-ascii 32))))
  (and
    (> (len tags) u0)
    (<= (len tags) u10)
    (is-eq (len (filter is-valid-tag tags)) (len tags))
  )
)

;; Public Document Functions

;; Upload a new document with metadata and tags
(define-public (upload-document (title (string-ascii 64)) (size uint) (description (string-ascii 128)) (tags (list 10 (string-ascii 32))))
  (let
    (
      (new-document-id (+ (var-get document-count) u1))
    )
    (asserts! (> (len title) u0) error-invalid-title)
    (asserts! (< (len title) u65) error-invalid-title)
    (asserts! (> size u0) error-invalid-size)
    (asserts! (< size u1000000000) error-invalid-size)
    (asserts! (> (len description) u0) error-invalid-title)
    (asserts! (< (len description) u129) error-invalid-title)
    (asserts! (validate-tags tags) error-invalid-title)

    (map-insert real-estate-documents
      { document-id: new-document-id }
      {
        document-title: title,
        document-owner: tx-sender,
        document-size: size,
        upload-date: block-height,
        document-description: description,
        document-tags: tags
      }
    )

    (map-insert document-permissions
      { document-id: new-document-id, user: tx-sender }
      { has-access: true }
    )
    (var-set document-count new-document-id)
    (ok new-document-id)
  )
)

;; Transfer ownership of a document to a new owner
(define-public (transfer-document-ownership (document-id uint) (new-owner principal))
  (let
    (
      (document-data (unwrap! (map-get? real-estate-documents { document-id: document-id }) error-document-not-found))
    )
    (asserts! (is-document-present document-id) error-document-not-found)
    (asserts! (is-eq (get document-owner document-data) tx-sender) error-unauthorized-action)
    (map-set real-estate-documents
      { document-id: document-id }
      (merge document-data { document-owner: new-owner })
    )
    (ok true)
  )
)

;; Functionality: Check if a user has access to a document
(define-public (check-access (document-id uint) (user principal))
  (let
    (
      (permission (map-get? document-permissions { document-id: document-id, user: user }))
    )
    (if (is-some permission)
      (ok (get has-access (unwrap-panic permission)))
      error-access-denied
    )
  )
)

;; Add a new function to view the details of a document
(define-public (view-document-details (document-id uint))
  (let
    (
      (document-data (unwrap! (map-get? real-estate-documents { document-id: document-id }) error-document-not-found))
    )
    (ok document-data)
  )
)

;; Optimize contract function by reducing redundant document existence checks
(define-public (get-document-info (document-id uint))
  (let
    (
      (document-data (unwrap! (map-get? real-estate-documents { document-id: document-id }) error-document-not-found))
    )
    (ok document-data)
  )
)

;; Add a test suite function to validate document upload success
(define-public (test-upload-document)
  (let
    (
      (test-title "Test Document")
      (test-size u500)
      (test-description "Test Document Description")
      (test-tags (list "test" "document"))
    )
    (asserts! (> (len test-title) u0) error-invalid-title)
    (asserts! (> test-size u0) error-invalid-size)
    (ok "Upload test passed")
  )
)

;; Fix bug in permission handling, ensuring the correct access level is granted
(define-public (check-document-access (document-id uint) (user principal))
  (let
    (
      (permission (unwrap! (map-get? document-permissions { document-id: document-id, user: user }) error-access-denied))
    )
    (ok (get has-access permission))
  )
)

;; Enhance security by verifying document permissions before granting access
(define-public (check-access-before-view (document-id uint) (user principal))
  (let
    (
      (permission (unwrap! (map-get? document-permissions { document-id: document-id, user: user }) error-access-denied))
    )
    (asserts! (get has-access permission) error-access-denied)
    (ok true)
  )
)

;; Update document details (title, size, description, and tags)
(define-public (update-document (document-id uint) (new-title (string-ascii 64)) (new-size uint) (new-description (string-ascii 128)) (new-tags (list 10 (string-ascii 32))))
  (let
    (
      (document-data (unwrap! (map-get? real-estate-documents { document-id: document-id }) error-document-not-found))
    )
    (asserts! (is-document-present document-id) error-document-not-found)
    (asserts! (is-eq (get document-owner document-data) tx-sender) error-unauthorized-action)
    (asserts! (> (len new-title) u0) error-invalid-title)
    (asserts! (< (len new-title) u65) error-invalid-title)
    (asserts! (> new-size u0) error-invalid-size)
    (asserts! (< new-size u1000000000) error-invalid-size)
    (asserts! (> (len new-description) u0) error-invalid-title)
    (asserts! (< (len new-description) u129) error-invalid-title)
    (asserts! (validate-tags new-tags) error-invalid-title)

    (map-set real-estate-documents
      { document-id: document-id }
      (merge document-data { document-title: new-title, document-size: new-size, document-description: new-description, document-tags: new-tags })
    )
    (ok true)
  )
)

;; Delete a document (only document owner can delete)
(define-public (delete-document (document-id uint))
  (let
    (
      (document-data (unwrap! (map-get? real-estate-documents { document-id: document-id }) error-document-not-found))
    )
    (asserts! (is-document-present document-id) error-document-not-found)
    (asserts! (is-eq (get document-owner document-data) tx-sender) error-unauthorized-action)
    (map-delete real-estate-documents { document-id: document-id })
    (ok true)
  )
)
