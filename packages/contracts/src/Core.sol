//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./Strategy.sol";

contract Core {
    mapping(address => address) public userStrategies;
    event StrategyDeployed(address user, address StrategyContract);
    constructor(){}

    function createMyStrategy(address destinationWallet, uint256 destinationChain) external
    {
        //require
        Strategy strategy = new Strategy(msg.sender,destinationWallet, destinationChain);
        userStrategies[msg.sender] = address(strategy);
        emit StrategyDeployed(msg.sender, address(strategy));
    }
}