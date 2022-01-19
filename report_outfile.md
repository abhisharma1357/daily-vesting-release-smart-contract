## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| dailyVesting.sol | 67674a1a194d785fbe78caa242d0b999e3b2137d |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **IErc20Contract** | Interface |  |||
| └ | transfer | External ❗️ | 🛑  |NO❗️ |
| └ | balanceOf | External ❗️ |   |NO❗️ |
||||||
| **DailyVesting** | Implementation |  |||
| └ | <Constructor> | Public ❗️ | 🛑  |NO❗️ |
| └ | setRecipientAddressesAmounts | External ❗️ | 🛑  | onlyAdmin |
| └ | confirmBalance | External ❗️ | 🛑  | onlyAdmin |
| └ | confirmAddressAndTransferOwnership | External ❗️ | 🛑  | onlyAdmin |
| └ | dailyTransfer | External ❗️ | 🛑  |NO❗️ |
| └ | _transfer | Private 🔐 | 🛑  | |
| └ | _isContract | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
