// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";


contract Strategy is Ownable(msg.sender) {
    mapping(address => uint256) public userBalances; 
    ISwapRouter public uniswapRouter;
    AggregatorV3Interface internal dataFeed;
    address public chainlinkAutomationRegistry;

    struct DCAIN {
        address dcaINoutToken1;
        address dcaINoutToken2;
        address dcaINoutToken3;
        uint256 dcaAmount;
        uint256 frequency;
        uint256 lastExecution;
        bool notpaused;
    }
    struct DCAOUT {
        address outToken;
        address targetToken;
        uint256 priceTarget;
        uint256 nextExecution;
        bool notpaused;
    }
    address public destinationWallet;
    address public destinationChain;
    address public usdc = "0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238";

    constructor(address _owner,address _destinationWallet,uint256 _destinationChain)
    {
        owner = _owner;
        destinationWallet = _destinationWallet;
        destinationChain = _destinationChain;
        dataFeed = AggregatorV3Interface(
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        );
        uniswapRouter = ISwapRouter(_uniswapRouter);
        address _uniswapRouter;
        address _chainlinkAutomationRegistry;
    }

    function setDCAINStrategy(address _dcaINoutToken1,address _dcaINoutToken2,address _dcaINoutToken3,uint256 _frequency) public
    { 
        DCAIN({dcaINoutToken1: _dcaINoutToken1,
        dcaINoutToken2: _dcaINoutToken2,
        dcaINoutToken3: _dcaINoutToken3,
        frequency: 1 minutes, 
        lastExecution: block.timestamp,
        paused: true
        }); 
        //emit
    }

     function setDCAOUTStrategy(address _outToken,address targetToken,uint256 priceTarget) public
    { 
        DCAOUT({outToken: _outToken,
        targetToken: _targetToken,
        priceTarget: _priceTarget,
        frequency: 5 minutes, 
        lastExecution: block.timestamp,
        paused: true
        });
        //emit
    }
    function deposit(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        userBalances[token] += amount;
        emit Deposited(msg.sender, token, amount);
    }
      function takeProfits(address token, uint256 amount) external {
        require(userBalances[token] >= amount, "Insufficient balance");
        userBalances[token] -= amount;
        address user = payable(msg.sender);
        IERC20(token).transfer(user, amount);
        emit ProfitsRealized(user, amount);
    }

    //DCAOUT executions

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        bool timepassed = block.timestamp - DCAOUT.lastExecution > DCAOUT.frequency;
        bool targetPriceReached = (getChainlinkDataFeedLatestAnswer() >= DCAOUT._priceTarget);
        upkeepNeeded = (DCAIN.notPaused && timepassed && targetPriceReached);
    }
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        if ((block.timestamp - DCAIN.lastExecution) > DCAIN.frequency) {
            DCAIN.lastExecution = block.timestamp;
            executeDCAOUT(); //sell order with uniswap
        }
    }

    function executeDCAOUT() public 
    {
    }

    function executeDCAIN() public 
    {   
        uint256 usdcBal = userBalances[usdc];
        uint256 percentswap = usdcBal/3;
         ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
                tokenIn: usdc,
                tokenOut: DCAIN.dcaINoutToken1,
                fee: 3000,
                recipient: userAddress,
                deadline: block.timestamp + 60,
                amountIn: percentswap,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            uint256 amountOut = uniswapRouter.exactInputSingle(params);

            // Update balances and next execution time
            userBalances[usdc] -= percentswap;
            userBalances[DCAIN.dcaINoutToken1] += amountOut;
            config.nextExecution = block.timestamp + config.frequency;

            emit DCAExecuted(amountIn, amountOut);
    }


    function pauseDCAIN() external {
        DCAIN.paused = true;
        emit DCAINPaused(msg.sender);
    }

    function resumeDCAIN() external {
        DCAIN.paused = false;
        emit DCAINResumed(msg.sender);
    }
    function pauseDCAOUT() external {
        DCAOUT.paused = true;
        emit DCAOUTPaused(msg.sender);
    }

    function resumeDCAOUT() external {
        DCAOUT.paused = false;
        emit DCAOUTResumed(msg.sender);
    }

 


}