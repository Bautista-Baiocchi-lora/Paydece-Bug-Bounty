# Optimizations

- A lot (most) of the dependencies can be removed. This will reduce deployment costs substancially.
- Most getters should be removed. They increase contract complexity and bytecode size. this will reduce deployment costs and contract complexity
- `getFeesAvailable()` is useless and should be removed. `feesAvailable` is already public. 
- `getAllowance()` is useless and should be removed. This balance should be queried directly from the ERC20 contract.
- There is no need to delete stale orders from on-chain memory. It serves no practical purpose and increases gas cost.


# Bugs 

### 1 (not severe)
`createEscrow` call is open to anyone, not just contract owner. That means anyone can make an escrow on behalf of anyone.

> elchango.eth says this is intended functionality. In that case the functions comment is misleading.
> https://discord.com/channels/952926531846541332/992764249493483650/1001261262400925787

### 2  (not severe)
`createEscrow` doesn't check that `_seller != address(0)` and `_buyer != address(0)`

### 3 (not severe)
Inside `releaseEscrow` the require message says "USDT has not been deposited" which means the escrow is now only useful for USDT token

### 4 (severe)
`refundBuyer` function is prone to re-entrance attacks. This is irrelavent (**as of right now**) given the current escrow contract only works with a preset ERC20 contract. If the token contract could be set by the user then it could be set to a malicious contract that performs the rentrence attack and drains all buyer funds.

example:

attacker calls `escrow.refundBuyer(0)` which calls `maliciousERC20.safeTransfer`. the `safeTransfer` calls `escrow.refundBuyer(1)`. This will make the escrow call `maliciousERC20.safeTransfer` before updating its internal balance. This loops endlessly until the escrow contract is completely drained.

### 4 (severe)
`cancelEscrow` function is prone to re-entrance attacks. Same exact way as `refundBuyer` function.

### 5 (not severe)
`onlyBuyer` and `onlySeller` modifiers do not check that `msg.sender != address(0)`. remember if `escrows[_orderId]` is undefined then `escrows[_orderId].buyer` will be `address(0)` which is a potential bug. 

### 6 (severe)
All ERC20 token transfers are assumed to be successful. This is not always the case and checks should be implemented accordingly to avoid indefinetly locking funds in the escrow contract.

### 7 (severe)
`releaseEscrow` could probably produce a arthmetic underflow, need to confirm via fuzzy testing.

# Side notes

- It is highly recommend that `orderId` be counter managed solely by the escrow contract. `releaseEscrow` should increment it (`orderId++`). Allowing it to be set by the caller is a massive attack surface.

