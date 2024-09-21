//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Strategy {
    constructor()
    {

    }
    function deposit(address token, uint256 amount) external {
        require(amount >0," Amount must be greater than 0");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit Deposited(msg.sender, token, amount);
    }

    function withdraw(address token, uint256 amount) external {
        uint256 tokenBalance = IERC20(token).balanceOf(address(this));
            require(tokenBalance >= amount, "Insufficient token balance");
            IERC20(token).transfer(msg.sender, amount);
    }
    


}