//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./Strategy.sol";

contract Core {
    mapping(address => address) public userStrategies;
    event StrategyDeployed(address indexed user, address indexed StrategyContract);
    constructor(){}

    function createMyStrategy(address destinationWallet) external
    {
        require(userStrategies[msg.sender] == address(0), "Strategy already created");

        Strategy strategy = new Strategy(msg.sender,destinationWallet);
        userStrategies[msg.sender] = address(strategy);
        emit StrategyDeployed(msg.sender, address(strategy));
    }
    function getStrategy(address user) public returns (address)
    {
        return userStrategies[user];
    }
    
}