// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Aggregate.sol";
import "./AMMState.sol";
import "./Utils.sol";
import "./proto/command.proto.sol";
import "./proto/event.proto.sol";


contract AMMAggregate is Aggregate {

    AMMState public state;

    constructor(string memory id_, AMMState state_, uint256 version_) {
        id = id_;
        state = state_;
        version = version_;
    }

    function create(bytes memory token1, bytes memory token2, uint token1_balance, uint token2_balance) public {
        AMMState s = AMMState(address(state));

        require(s.isCreated() == false, "AMM already exists");

        AMMCreatedPayload memory evnt_payload;
        evnt_payload.asset1 = token1;
        evnt_payload.asset2 = token2;
        evnt_payload.supply1 = token1_balance;
        evnt_payload.supply2 = token1_balance;

        DomainEvent memory evnt = createEvent(eventsCount, DomainEventType.AMM_CREATED, AMMCreatedPayloadCodec.encode(evnt_payload));
        applyEvent(evnt);
    }

    function deposit(bytes memory token, address account, uint amount) public {
        AMMState s = AMMState(address(state));

        require(s.isCreated() == true, "AMM does not exist");
        require(compareStrings(s.token1(), payload.token) || compareStrings(s.token2(), payload.token), "Not supported token");
        require(payload.amount > 0, "Not enough funds");

        FundsDepositedPayload memory evnt_payload;
        evnt_payload.account = account;
        evnt_payload.amount = amount;
        evnt_payload.asset = token;

        DomainEvent memory evnt = createEvent(eventsCount, DomainEventType.FUNDS_DEPOSITED, FundsDepositedPayloadCodec.encode(evnt_payload));
        applyEvent(evnt);
    }

    function withdraw(bytes memory token, address account, uint amount) public {

        require(s.isCreated() == true, "AMM does not exist");
        require(compareStrings(s.token1(), token) || compareStrings(s.token2(), token), "Not  supported token");
        
        address account = Utils.bytesToAddress(account);
        if (compareStrings(s.token1(), token)) {
            require(s.balance1(account) > amount, "Not enough balance");
        }

        if (compareStrings(s.token2(), token)) {
            require(s.balance2(account) > amount, "Not enough balance");
        }

        FundsWithdrawnPayload memory evnt_payload;
        evnt_payload.account = account;
        evnt_payload.amount = amount;
        evnt_payload.asset = token;

        
        DomainEvent memory evnt = createEvent(eventsCount, DomainEventType.FUNDS_WITHDRAWN, FundsWithdrawnPayloadCodec.encode(evnt_payload));
        applyEvent(evnt);
    }

    function addLiquidity(AddLiquidityPayload memory payload) private {

        require(s.isCreated() == true, "AMM does not exist");
        
        address account = bytesToAddress(payload.account);
        require(s.balance1(account) >= payload.amount1 
            && s.balance2(account) >= payload.amount2, "Not enough balance");

        LiquidityAddedPayload memory evnt_payload;
        evnt_payload.account = payload.account;
        evnt_payload.amount1 = payload.amount1;
        evnt_payload.amount2 = payload.amount2;

        DomainEvent memory evnt = createEvent(eventsCount, DomainEventType.LIQUIDITY_ADDED, LiquidityAddedPayloadCodec.encode(evnt_payload));
        applyEvent(evnt);
    }

    function removeLiquidity(RemoveLiquidityPayload memory payload) private {
        AMMState s = AMMState(address(state));

        require(s.isCreated() == true, "AMM does not exist");
        
        address account = bytesToAddress(payload.account);
        require(s.shares(account) >= payload.share, "Not enough share");

        // Calculate amounts when altering state
        LiquidityRemovedPayload memory evnt_payload;
        evnt_payload.account = payload.account;
        evnt_payload.shares = payload.share;

        DomainEvent memory evnt = createEvent(eventsCount, DomainEventType.LIQUIDITY_REMOVED, LiquidityRemovedPayloadCodec.encode(evnt_payload));
        applyEvent(evnt);
    }

    function swap(bytes memory token, bytes memory accountBytes, uint amount) private {

        address account = Utils.bytesToAddress(accountBytes);
        
        uint toSwapped = 0;
        bytes memory toToken;

        require(s.isCreated() == true, "AMM does not exist");
        if (compareStrings(s.token1(), payload.token)) {
            require(s.balance1(account) >= payload.amount, "Not enough token1");

            toSwapped = s.getSwapToken1Estimate(payload.amount);
            toToken = s.token2();
        }
        if (compareStrings(s.token2(), payload.token)) {
            require(s.balance2(account) >= payload.amount, "Not enough token2");
        
            toSwapped = s.getSwapToken2Estimate(payload.amount);
            toToken = s.token1();
        }
        
        TokensSwapedPayload memory evnt_payload;
        evnt_payload.account = account;
        evnt_payload.amount_from = amount;
        evnt_payload.asset_from = token;
        evnt_payload.amount_to = uint64(toSwapped);
        evnt_payload.asset_to = toToken;

        DomainEvent memory evnt = createEvent(eventsCount, DomainEventType.TOKENS_SWAPPED, TokensSwapedPayloadCodec.encode(evnt_payload));
        applyEvent(evnt);
    }
}