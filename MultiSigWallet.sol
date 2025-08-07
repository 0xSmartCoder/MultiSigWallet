// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract MultiSig {
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        uint confirmed;
        bool executed;
    }

    Transaction[] public transactions;
    address[] public owners;
    uint public requiredVotes;
    mapping(uint => mapping(address => bool)) public isConfirmed;
    mapping(address => bool) public isOwner;

    // Events
    event TransactionSubmitted(address indexed sender, uint indexed id);
    event Confirmed(address indexed whoConfirmed, uint indexed id);
    event Deposit(address indexed sender, uint amount, uint balance);
    event Executed(address indexed sender, uint indexed id);

    constructor(address[] memory _owners, uint _requiredVotes) {
        require(_owners.length > 0, "Owners required");
        require(_requiredVotes > 0 && _requiredVotes <= _owners.length, "Invalid number of required votes");

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner address");
            require(!isOwner[owner], "Owner already exists");
            isOwner[owner] = true;
            owners.push(owner);
        }
        requiredVotes = _requiredVotes;
    }

    // Modifiers
    modifier notExecuted(uint _index) {
        require(!transactions[_index].executed, "Already executed");
        _;
    }

    modifier mustBeConfirmed(uint _index) {
        require(isConfirmed[_index][msg.sender], "Not confirmed");
        _;
    }

    modifier idExists(uint _index) {
        require(_index < transactions.length, "ID not found");
        _;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    // Functions
    function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner {
        uint id = transactions.length;
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            confirmed: 0,
            executed: false
        }));
        emit TransactionSubmitted(msg.sender, id);
    }

    function confirmTransaction(uint _index) public onlyOwner idExists(_index) notExecuted(_index) {
        require(!isConfirmed[_index][msg.sender], "Already confirmed");
        Transaction storage transaction = transactions[_index];
        transaction.confirmed += 1;
        isConfirmed[_index][msg.sender] = true;
        emit Confirmed(msg.sender, _index);
    }

    function deposit() public payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function executeTransaction(uint _index) public onlyOwner idExists(_index) mustBeConfirmed(_index) notExecuted(_index) {
        Transaction storage transaction = transactions[_index];
        require(transaction.confirmed >= requiredVotes, "Not enough confirmations");
        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "Transaction failed");
        emit Executed(msg.sender, _index);
    }
}
