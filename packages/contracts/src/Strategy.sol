// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Strategy is Ownable(msg.sender) {
        
    struct DCAIN {
        address dcaINoutToken1;
        address dcaINoutToken2;
        address dcaINoutToken3;
        uint256 dcaAmount;
        uint256 frequency;
        uint256 lastExecution;
        bool paused;
    }
    struct DCAOUT {
        address outToken;
        address TargetToken;
        uint256 priceTarget;
        uint256 nextExecution;
        bool paused;
    }
    address public destinationWallet;
    adddress public destinationChain;

    constructor(address _owner,_destinationWallet,_destinationChain)
    {
        owner = _owner;
        destinationWallet = _destinationWallet;
        destinationChain = _destinationChain;
    }

    function setDCAINStrategy(address _dcaINoutToken1,address _dcaINoutToken2,address _dcaINoutToken3,uint256 _frequency) public onlyOwner
    { 
        DCAIN({dcaINoutToken1: _dcaINoutToken1,
        dcaINoutToken2: _dcaINoutToken2,
        dcaINoutToken3: _dcaINoutToken3,
        frequency: _frequency, //gotta hardcode it to 1 minute for demo
        lastExecution: block.timestamp,
        paused: false
        }); 
        //emit
    }

    function pauseDCA() external {
        DCAIN.paused = true;
        emit DCAPaused(msg.sender);
    }

    function resumeDCA() external {
        DCAIN.paused = false;
        emit DCAResumed(msg.sender);
    }

   


}