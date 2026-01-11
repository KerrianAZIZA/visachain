// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VisaChain {

    enum Status {
        Draft,
        Active,
        Suspended,
        Revoked
    }

    struct Version {
        string cid;
        address author;
        uint256 timestamp;
        string note;
    }

    struct Document {
        uint256 id;
        address owner;
        Status status;

        bool signed;
        address signedBy;
        uint256 signedAt;

        Version[] versions;
    }

    mapping(uint256 => Document) public documents;
    uint256 public documentCount;

    mapping(uint256 => mapping(address => bool)) public editors;
    mapping(uint256 => mapping(address => bool)) public validators;
    mapping(uint256 => mapping(address => bool)) public readers;

    event DocumentCreated(uint256 docId, address owner, string cid);
    event DocumentUpdated(uint256 docId, address author, string cid, string note);
    event DocumentRevoked(uint256 docId);
    event DocumentSigned(uint256 docId, address validator);
    event OwnershipTransferred(uint256 docId, address oldOwner, address newOwner);

    modifier onlyOwner(uint256 docId) {
        require(msg.sender == documents[docId].owner, "Not owner");
        _;
    }

    modifier canEdit(uint256 docId) {
        require(
            msg.sender == documents[docId].owner || editors[docId][msg.sender],
            "Not authorized to edit"
        );
        _;
    }

    modifier canRead(uint256 docId) {
        require(
            msg.sender == documents[docId].owner || readers[docId][msg.sender],
            "Not authorized to read"
        );
        _;
    }


    function createDocument(string memory cid, string memory note) public {
        documentCount++;

        Document storage d = documents[documentCount];
        d.id = documentCount;
        d.owner = msg.sender;
        d.status = Status.Draft;

        d.versions.push(Version(cid, msg.sender, block.timestamp, note));

        emit DocumentCreated(documentCount, msg.sender, cid);
    }

    function updateDocument(
        uint256 docId,
        string memory newCid,
        string memory note
    ) public canEdit(docId) {
        Document storage d = documents[docId];
        require(d.status != Status.Revoked, "Document revoked");

        d.versions.push(Version(newCid, msg.sender, block.timestamp, note));
        emit DocumentUpdated(docId, msg.sender, newCid, note);
    }

    function signDocument(uint256 docId) public {
        require(validators[docId][msg.sender], "Not validator");
        Document storage d = documents[docId];
        require(!d.signed, "Already signed");

        d.signed = true;
        d.signedBy = msg.sender;
        d.signedAt = block.timestamp;
        d.status = Status.Active;

        emit DocumentSigned(docId, msg.sender);
    }

    function revokeDocument(uint256 docId) public onlyOwner(docId) {
        documents[docId].status = Status.Revoked;
        emit DocumentRevoked(docId);
    }

    function transferOwnership(uint256 docId, address newOwner) public onlyOwner(docId) {
        address old = documents[docId].owner;
        documents[docId].owner = newOwner;
        emit OwnershipTransferred(docId, old, newOwner);
    }

    // Permission Management

    function setEditor(uint256 docId, address user, bool allowed) public onlyOwner(docId) {
        editors[docId][user] = allowed;
    }

    function setValidator(uint256 docId, address user, bool allowed) public onlyOwner(docId) {
        validators[docId][user] = allowed;
    }

    function setReader(uint256 docId, address user, bool allowed) public onlyOwner(docId) {
        readers[docId][user] = allowed;
    }

    // Read helpers

    function getLatestCID(uint256 docId) public view canRead(docId) returns (string memory) {
        Document storage d = documents[docId];
        return d.versions[d.versions.length - 1].cid;
    }

    function getVersionCount(uint256 docId) public view returns (uint256) {
        return documents[docId].versions.length;
    }
}
