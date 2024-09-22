### DCAwesome
I love DCAing, with hopes of being financially stable. But most of the time, I forget to take profits or just wait a little more(really), to make some extra. As much as we take time to SIP every month or week, we often miss taking profits even if the price touches the moon. I wanted to solve this, for me and every other investor.

What it does

Let's a user Dollar Cost Average with a strategy. A user can keep sending tokens(like piggy bank) to the contract whenever they save, until the Keepers trigger the date/time of DCA frequency(to make best use, without keeping the funds idle). Then, the amount is swapped according to the DCA(usually for a blue-chip) pre-set strategy. A user also has an option to DCA-out with a set-strategy that withdraws their holdings to their wallet.The user can also withdraw their amount according to their will as well,anytime.

How we built it

Using Solidity, Foundry, Remix,Chainlink,and Uniswap.


## Decentralized Dollar Cost Averaging (DCA) Dapp for DCAIn and DCAOut based on Time and Price Triggers

### Project Overview
This project implements a decentralized Dollar Cost Averaging (DCA) platform that allows users to create personalized, automated cryptocurrency investment strategies. The platform enables users to set up both buy-in (DCAIN) and sell-off (DCAOUT) strategies, operating on a "set and forget" principle for hands-off portfolio management.

### Key Features

User-Specific Strategies: Each user can create and manage their own DCA strategy through a dedicated smart contract.
Flexible DCAIN:
Users can deposit USDC into their strategy contract at any time.
The DCAIN function uses the accumulated USDC balance for monthly investments.
Users can split their investment equally into up to three different cryptocurrencies of their choice.
Customizable DCAOUT:
Users can set specific conditions for profit realization.
DCAOUT converts invested tokens back to USDC based on user-defined parameters.
Self-Custody: Each strategy contract is controlled solely by its creator, ensuring fund security and user autonomy.
Automated Execution: Strategies are executed automatically based on predefined conditions and time intervals.
Uniswap Integration: The platform uses Uniswap V3 for all token swaps, ensuring liquidity and competitive rates.
Chainlink Oracle: Price feeds from Chainlink are used to trigger DCAOUT strategies based on market conditions.
Pause/Resume Functionality: Users can pause and resume their DCAIN and DCAOUT strategies as needed.



