// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract Simple {
    event Deposit(uint256 amount, address indexed sender, uint256 balance);

    address public owner;
    uint256 public storedValue;

    constructor(address _owner) {
        require(_owner != address(0), "Owner address cannot be zero");
        owner = _owner;
    }

    receive() external payable {
        emit Deposit(msg.value, msg.sender, address(this).balance);
    }

    function release(address payable to) public {
        require(msg.sender == owner, "Not authorized");
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to release");
        (bool success, ) = to.call{value: balance}("");
        require(success, "Transfer failed");
    }

    function store(uint256 val) public {
        storedValue = val;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getReleaseData(address to) public view returns (bytes memory) {
        return abi.encodeWithSignature("release(address)", to);
    }

    function getStoreData(uint256 val) public view returns (bytes memory) {
        return abi.encodeWithSignature("store(uint256)", val);
    }
}
