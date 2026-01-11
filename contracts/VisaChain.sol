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

        Version[] versions;
    }

    uint256 public documentCount;
    mapping(uint256 => Document) public documents;

    /* ------------------------------------------------------------ */
    /*                          PERMISSIONS                         */
    /* ------------------------------------------------------------ */

    mapping(uint256 => mapping(address => bool)) public editors;
    mapping(uint256 => mapping(address => bool)) public validators;
    mapping(uint256 => mapping(address => bool)) public readers;

    mapping(uint256 => address[]) private editorList;
    mapping(uint256 => address[]) private validatorList;
    mapping(uint256 => address[]) private readerList;

    /* ------------------------------------------------------------ */
    /*                          SIGNATURES                          */
    /* ------------------------------------------------------------ */

    mapping(uint256 => mapping(address => bool)) public hasSigned;

    /* ------------------------------------------------------------ */
    /*                             EVENTS                           */
    /* ------------------------------------------------------------ */

    event DocumentCreated(uint256 indexed docId, address indexed owner, string cid);
    event DocumentUpdated(uint256 indexed docId, address indexed author, string cid, string note);
    event DocumentSigned(uint256 indexed docId, address indexed validator);
    event DocumentRevoked(uint256 indexed docId);
    event OwnershipTransferred(uint256 indexed docId, address oldOwner, address newOwner);

    /* ------------------------------------------------------------ */
    /*                           MODIFIERS                          */
    /* ------------------------------------------------------------ */

    modifier onlyOwner(uint256 docId) {
        require(msg.sender == documents[docId].owner, "Not document owner");
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

    /* ------------------------------------------------------------ */
    /*                        DOCUMENT LOGIC                        */
    /* ------------------------------------------------------------ */

    function createDocument(string memory cid, string memory note) external {
        documentCount++;

        Document storage d = documents[documentCount];
        d.id = documentCount;
        d.owner = msg.sender;
        d.status = Status.Draft;

        d.versions.push(
            Version({
                cid: cid,
                author: msg.sender,
                timestamp: block.timestamp,
                note: note
            })
        );

        emit DocumentCreated(documentCount, msg.sender, cid);
    }

    function updateDocument(
        uint256 docId,
        string memory newCid,
        string memory note
    ) external canEdit(docId) {
        Document storage d = documents[docId];
        require(d.status != Status.Revoked, "Document revoked");

        d.versions.push(
            Version({
                cid: newCid,
                author: msg.sender,
                timestamp: block.timestamp,
                note: note
            })
        );

        emit DocumentUpdated(docId, msg.sender, newCid, note);
    }

    function getDocumentSummary(uint256 docId)
        external
        view
        canRead(docId)
        returns (
            uint256 id,
            address owner,
            Status status,
            string memory latestNote
        )
    {   
        Document storage d = documents[docId];
        Version storage v = d.versions[d.versions.length - 1];

        return (d.id, d.owner, d.status, v.note);
    }
    
    function revokeDocument(uint256 docId) external onlyOwner(docId) {
        documents[docId].status = Status.Revoked;
        emit DocumentRevoked(docId);
    }

    function transferOwnership(uint256 docId, address newOwner)
        external
        onlyOwner(docId)
    {
        require(newOwner != address(0), "Invalid address");
        address oldOwner = documents[docId].owner;
        documents[docId].owner = newOwner;

        emit OwnershipTransferred(docId, oldOwner, newOwner);
    }

    /* ------------------------------------------------------------ */
    /*                       SIGNATURE LOGIC                        */
    /* ------------------------------------------------------------ */

    function signDocument(uint256 docId) external {
        require(validators[docId][msg.sender], "Not validator");
        require(!hasSigned[docId][msg.sender], "Already signed");

        hasSigned[docId][msg.sender] = true;

        // Active dès la première signature (modifiable)
        documents[docId].status = Status.Active;

        emit DocumentSigned(docId, msg.sender);
    }

    /* ------------------------------------------------------------ */
    /*                     PERMISSION MANAGEMENT                    */
    /* ------------------------------------------------------------ */

    function setEditor(uint256 docId, address user, bool allowed)
        external
        onlyOwner(docId)
    {
        if (allowed && !editors[docId][user]) {
            editorList[docId].push(user);
        }
        editors[docId][user] = allowed;
    }

    function setValidator(uint256 docId, address user, bool allowed)
        external
        onlyOwner(docId)
    {
        if (allowed && !validators[docId][user]) {
            validatorList[docId].push(user);
        }
        validators[docId][user] = allowed;
    }

    function setReader(uint256 docId, address user, bool allowed)
        external
        onlyOwner(docId)
    {
        if (allowed && !readers[docId][user]) {
            readerList[docId].push(user);
        }
        readers[docId][user] = allowed;
    }

    /* ------------------------------------------------------------ */
    /*                          READ HELPERS                        */
    /* ------------------------------------------------------------ */

    function getLatestVersion(uint256 docId)
        external
        view
        canRead(docId)
        returns (
            string memory cid,
            string memory note,
            address author,
            uint256 timestamp
        )
    {
        Version storage v =
            documents[docId].versions[
                documents[docId].versions.length - 1
            ];

        return (v.cid, v.note, v.author, v.timestamp);
    }

    function getVersionCount(uint256 docId) external view returns (uint256) {
        return documents[docId].versions.length;
    }

    function getValidators(uint256 docId)
        external
        view
        onlyOwner(docId)
        returns (address[] memory)
    {
        return validatorList[docId];
    }

    function getReaders(uint256 docId)
        external
        view
        onlyOwner(docId)
        returns (address[] memory)
    {
        return readerList[docId];
    }

    function getValidatorSignatures(uint256 docId)
        external
        view
        onlyOwner(docId)
        returns (address[] memory validators_, bool[] memory signed_)
    {
        address[] memory vList = validatorList[docId];
        bool[] memory sList = new bool[](vList.length);

        for (uint256 i = 0; i < vList.length; i++) {
            sList[i] = hasSigned[docId][vList[i]];
        }

        return (vList, sList);
    }
}
