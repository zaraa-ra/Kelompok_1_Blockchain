// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoffeeSupplyChain {

    // ENUM STATUS PRODUK
    enum Status { Harvested, Roasted, Distributed }

    // STRUCT DATA BATCH KOPI
    struct Batch {
        string batchID;
        string location;
        string variety;
        uint256 harvestDate;
        uint256 roastDate;
        string roastProfile;
        address farmer;
        address roaster;
        address currentOwner;
        Status status;
        bool exists;
    }

    // MAPPING DATA
    mapping(string => Batch) private batches;

    // ACCESS CONTROL (ACL)
    mapping(address => bool) public authorizedActors;

    // ADMIN
    address public admin;

    constructor() {
        admin = msg.sender;
        authorizedActors[msg.sender] = true;
    }

    // =============================
    // 1. AUTHORIZE ACTOR
    // =============================
    function authorizeActor(address _actor) public {
        require(msg.sender == admin, "Only admin can authorize");
        authorizedActors[_actor] = true;
    }

    // =============================
    // 2. ADD BATCH (PETANI)
    // =============================
    function addBatch(
        string memory _batchID,
        string memory _location,
        string memory _variety,
        uint256 _harvestDate
    ) public {
        require(authorizedActors[msg.sender], "Not authorized");
        require(!batches[_batchID].exists, "Batch already exists");

        batches[_batchID] = Batch({
            batchID: _batchID,
            location: _location,
            variety: _variety,
            harvestDate: _harvestDate,
            roastDate: 0,
            roastProfile: "",
            farmer: msg.sender,
            roaster: address(0),
            currentOwner: msg.sender,
            status: Status.Harvested,
            exists: true
        });
    }

    // =============================
    // 3. UPDATE TO ROASTER
    // =============================
    function updateToRoaster(
        string memory _batchID,
        uint256 _roastDate,
        string memory _roastProfile
    ) public {
        require(authorizedActors[msg.sender], "Not authorized");
        require(batches[_batchID].exists, "Batch not found");

        Batch storage batch = batches[_batchID];

        batch.roastDate = _roastDate;
        batch.roastProfile = _roastProfile;
        batch.roaster = msg.sender;
        batch.currentOwner = msg.sender;
        batch.status = Status.Roasted;
    }

    // =============================
    // 4. GET BATCH DETAILS (READ ONLY)
    // =============================
    function getBatchDetails(string memory _batchID)
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            uint256,
            uint256,
            string memory,
            address,
            address,
            address,
            Status
        )
    {
        require(batches[_batchID].exists, "Batch not found");

        Batch memory b = batches[_batchID];

        return (
            b.batchID,
            b.location,
            b.variety,
            b.harvestDate,
            b.roastDate,
            b.roastProfile,
            b.farmer,
            b.roaster,
            b.currentOwner,
            b.status
        );
    }

    // =============================
    // 5. VERIFY ORIGIN
    // =============================
    function verifyOrigin(string memory _batchID)
        public
        view
        returns (bool)
    {
        require(batches[_batchID].exists, "Batch not found");

        Batch memory b = batches[_batchID];

        // Validasi sederhana (bisa dikembangkan)
        if (b.farmer != address(0) && b.harvestDate != 0) {
            return true;
        }
        return false;
    }

    // =============================
    // 6. GET BATCH STATUS
    // =============================
    function getBatchStatus(string memory _batchID)
        public
        view
        returns (Status)
    {
        require(batches[_batchID].exists, "Batch not found");
        return batches[_batchID].status;
    }
}