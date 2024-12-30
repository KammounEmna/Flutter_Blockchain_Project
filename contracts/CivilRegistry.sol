// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract CivilRegistry {
    // Struct to hold record information
    struct Record {
        address id;             // Unique ID (address) for the record
        string name;            // Name of the person
        string birthDate;       // Birth date
        string marriageDate;    // Marriage date (optional)
        string deathDate;       // Death date (optional)
    }

    // Mapping from address (unique ID) to Record
    mapping(address => Record) public records;

    // Dynamic array to store all added IDs
    address[] private allIds;

    // Address of the municipality employee (contract owner)
    address public owner;

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this function");
        _;
    }
    function generateUniqueId() internal view returns (address) {
    bytes32 hash = keccak256(
        abi.encodePacked(
            block.timestamp,
            blockhash(block.number - 1), // Remplacement ici
            block.coinbase,
            msg.sender
        )
    );
    return address(uint160(uint256(hash)));
}


    // Function to add a new record, only executable by the owner
    function addRecord(string memory name, string memory birthDate) public onlyOwner {
        // Generate a unique address ID for the record
        address uniqueId = generateUniqueId();
        //address uniqueId = 0x2b0424B12A1c27C818fE9C24641b06291D8AB418;
        // Add the record to the mapping
        records[uniqueId] = Record({
            id: uniqueId,
            name: name,
            birthDate: birthDate,
            marriageDate: "",
            deathDate: ""
        });

        // Store the ID in the array
        allIds.push(uniqueId);
    }

    // Function to retrieve a record based on the caller's address
    function getRecord(address add) public view returns (Record memory) {
        require(records[add].id != address(0), "No record found for this address");
        return records[add];
    }

    // Function to update a record's marriage or death date
    function updateRecord(address add,string memory recordType, string memory date) public {
        require(records[add].id != address(0), "No record found for this address");

        if (keccak256(abi.encodePacked(recordType)) == keccak256(abi.encodePacked("M"))) {
            // Update marriage date
            records[add].marriageDate = date;
        } else if (keccak256(abi.encodePacked(recordType)) == keccak256(abi.encodePacked("D"))) {
            // Update death date
            records[add].deathDate = date;
        } else {
            revert("Invalid record type. Use 'M' for marriage or 'D' for death.");
        }
    }

    // Function to get all IDs
    function getIds() public view returns (address[] memory) {
        return allIds;
    }
}