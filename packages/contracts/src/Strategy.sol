// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./Strategy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";


contract Strategy is Ownable(msg.sender) {
    mapping(address => uint256) public userBalances; 
    AggregatorV3Interface internal dataFeed;
    IUniswapV2Router02 internal uniswapRouter;
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
        uint256 percent;
        uint256 lastExecution;
        uint256 frequency;
        bool notpaused;
    }
     event Deposited(address indexed user, address indexed token, uint256 amount);
    event ProfitsRealized(address indexed user, uint256 amount);
    event DCAExecuted(uint256 amountIn, uint256 amountOut);
    event DCAINPaused(address indexed user);
    event DCAINResumed(address indexed user);
    event DCAOUTPaused(address indexed user);
    event DCAOUTResumed(address indexed user);
    event AllowanceUpdated(address indexed token, uint256 amount);
    event DCAINExecuted(uint256 amount1,uint256 amount2,uint256 amount3);


    address public destinationWallet;
    address public usdc = "0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238";
     DCAIN public dcaInStrategy;
    DCAOUT public dcaOutStrategy;
    constructor(address _owner,address _destinationWallet) Ownable()
    {   
        owner = _owner;
        destinationWallet = _destinationWallet;
        dataFeed = AggregatorV3Interface(
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        );
        address _chainlinkAutomationRegistry;
        uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // Uniswap Router

    }

    function setDCAINStrategy(address _dcaINoutToken1,address _dcaINoutToken2,address _dcaINoutToken3,uint256 _frequency) public
    { 
        dcaInStrategy = DCAIN({dcaINoutToken1: _dcaINoutToken1,
        dcaINoutToken2: _dcaINoutToken2,
        dcaINoutToken3: _dcaINoutToken3,
        frequency: 1 minutes, 
        lastExecution: block.timestamp,
        notpaused: true
        }); 
        updateAllowance(usdc, type(uint256).max);

    }

     function setDCAOUTStrategy(address _outToken,address _targetToken,uint256 _priceTarget,uint256 _percent) public
    { 
        dcaOutStrategy = DCAOUT({outToken: _outToken,
        targetToken: _targetToken,
        priceTarget: _priceTarget,
        percent: _percent,
        frequency: 5 minutes, 
        lastExecution: block.timestamp,
        paused: true
        });
        //emit
    }
    function updateAllowance(address token, uint256 amount) public onlyOwner {
        IERC20(token).safeApprove(address(uniswapRouter), 0);
        IERC20(token).safeApprove(address(uniswapRouter), amount);
        emit AllowanceUpdated(token, amount);
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
        bool timepassed = block.timestamp - dcaOutStrategy > DCAOUT.frequency;
        bool targetPriceReached = (getChainlinkDataFeedLatestAnswer() >= DCAOUT._priceTarget);
        upkeepNeeded = (dcaOutStrategy.notPaused && timepassed && targetPriceReached);
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
        if ((block.timestamp - dcaOutStrategy.lastExecution) > dcaOutStrategy.frequency) {
            DCAIN.lastExecution = block.timestamp;
            executeDCAOUT(); 
        }
    }

    function executeDCAIN() public 
    {   
        uint256 usdcBal = userBalances[usdc];
        uint256 split = usdcBal/3;
     ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
                tokenIn: usdc,
                tokenOut: dcaOutStrategy.outToken1,
                fee: 3000,
                recipient: address(this),
                deadline: block.timestamp + 60,
                amountIn: split,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            uint256 amountOut1 = uniswapRouter.exactInputSingle(params);

            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
                tokenIn: usdc,
                tokenOut: dcaOutStrategy.outToken2,
                fee: 3000,
                recipient: address(this),
                deadline: block.timestamp + 60,
                amountIn: split,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            uint256 amountOut2 = uniswapRouter.exactInputSingle(params);
                ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
                tokenIn: usdc,
                tokenOut: dcaOutStrategy.outToken3,
                fee: 3000,
                recipient: address(this),
                deadline: block.timestamp + 60,
                amountIn: split,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            uint256 amountOut3 = uniswapRouter.exactInputSingle(params);

            emit DCAINExecuted(amountOut1,amountOut2,amountOut3);
    }

    function executeDCAOUT() public 
    {   
        uint256 balance = IERC20(token).balanceOf(address(this));
        uint256 amountToSell = (balance * (dcaOutStrategy.percent * 100)) / 10000;
          // Swap on Uniswap
            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
                tokenIn: dcaInStrategy.dcaINoutToken1,
                tokenOut: usdc,
                fee: 3000,
                recipient: destinationWallet,
                deadline: block.timestamp + 60,
                amountIn: amountToSell,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            uint256 amountOut = uniswapRouter.exactInputSingle(params);
            // Update balances and next execution time
            userBalances[dcaInStrategy.dcaINoutToken1] -= amountOut;

ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
                tokenIn: dcaInStrategy.dcaINoutToken2,
                tokenOut: usdc,
                fee: 3000,
                recipient: destinationWallet,
                deadline: block.timestamp + 60,
                amountIn: amountToSell,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            uint256 amountOut = uniswapRouter.exactInputSingle(params);
            // Update balances and next execution time
            userBalances[dcaInStrategy.dcaINoutToken2] -= amountOut;


ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
                tokenIn: dcaInStrategy.dcaINoutToken3,
                tokenOut: usdc,
                fee: 3000,
                recipient: destinationWallet,
                deadline: block.timestamp + 60,
                amountIn: amountToSell,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            uint256 amountOut = uniswapRouter.exactInputSingle(params);
            // Update balances and next execution time
            userBalances[dcaInStrategy.dcaINoutToken3] -= amountOut;


            dcaOutStrategy.lastExecution = block.timestamp + dcaOutStrategy.frequency;
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