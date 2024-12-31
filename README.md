# Real Estate Document Management Smart Contract

This Clarity 2.0 Smart Contract provides an efficient way to manage and interact with real estate documents on the blockchain. The contract supports document uploads, ownership transfers, permissions, access control, and document updates. This system aims to simplify the management of real estate documents and ensure secure access, transfer, and management of document data.

## Features

### Document Upload:
- Allows users to upload real estate documents with metadata (title, size, description, and tags).
- Ensures data validation for document fields such as title, size, and tags.
- Automatically assigns document ownership to the uploader.

### Document Ownership Transfer:
- Enables the transfer of document ownership from one user to another.
- Only the current owner of the document can transfer ownership.

### Document Permissions:
- Grants or denies access to documents based on user permissions.
- Allows users to check if they have access to a particular document.

### Document Details View:
- Provides a way to view document metadata, including title, owner, size, upload date, and tags.
- Verifies if the caller has the necessary permissions to access the document.

### Document Update:
- Allows document owners to update the document's metadata, including title, size, description, and tags.

### Document Deletion:
- Allows document owners to delete their documents from the system.

## Contract Structure

### Storage Variables and Mappings:
- `document-count`: Tracks the total number of documents in the system.
- `real-estate-documents`: A map storing real estate documents with metadata (id, title, owner, size, date, description, tags).
- `document-permissions`: A map storing document access permissions for users (user and document-id).

### Error Codes:
- `error-document-not-found`: Raised if the document doesn't exist.
- `error-duplicate-document`: Raised if a document already exists with the same ID.
- `error-invalid-title`: Raised for invalid document title length.
- `error-invalid-size`: Raised for invalid document size.
- `error-access-denied`: Raised if the user doesn't have permission to access a document.
- `error-unauthorized-action`: Raised if the user is not authorized for a certain action (like transferring ownership).
- `error-admin-only`: Raised if the action can only be performed by the admin.
- `error-unauthorized-view`: Raised if the user is unauthorized to view the document.
- `error-invalid-tag`: Raised if tags are invalid.

### Private Helper Functions:
- `is-document-present`: Verifies if a document exists.
- `is-document-owner`: Checks if the caller is the owner of the document.
- `get-document-size`: Retrieves the document size.
- `is-valid-tag`: Validates a tag length.
- `validate-tags`: Validates a list of tags.

### Public Document Functions:
1. **upload-document**: Uploads a document with metadata (title, size, description, tags).
2. **transfer-document-ownership**: Transfers ownership of a document to a new user.
3. **check-access**: Checks if a user has access to a document.
4. **view-document-details**: Views the details of a document.
5. **get-document-info**: Retrieves document metadata.
6. **test-upload-document**: A test function to validate document upload functionality.
7. **check-document-access**: Checks document access permission.
8. **check-access-before-view**: Ensures permission is checked before document view.
9. **update-document**: Updates document metadata (title, size, description, tags).
10. **delete-document**: Deletes a document (only the owner can delete).

## Installation

This contract is written in Clarity 2.0 and is designed to work on the Stacks blockchain. You can deploy it on the Stacks network using the appropriate deployment tools.

1. Install the necessary tools for interacting with the Stacks blockchain.
2. Deploy the contract using the Stacks CLI.
3. Interact with the contract using the Stacks Wallet or through a custom front-end.

## Usage

Once the contract is deployed on the Stacks network, users can interact with it by calling the various functions to manage real estate documents. Functions like `upload-document`, `transfer-document-ownership`, and `update-document` allow users to interact with the system. Access control mechanisms ensure only authorized users can perform specific actions.

## Contribution

Contributions are welcome! Please feel free to submit issues and pull requests for enhancements, bug fixes, or additional features.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
