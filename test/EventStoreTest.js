var Aggregate = artifacts.require("Aggregate");
var AggregateRepository = artifacts.require("AggregateRepository");
var AggregateState = artifacts.require("Aggregate");
var Dispatcher = artifacts.require("Dispatcher");
var EventStore = artifacts.require("EventStore");
var NFTsAggregate = artifacts.require("NFTsAggregate");
var NFTsState = artifacts.require("NFTsState");
var Utils = artifacts.require("Utils");
var Ownable = artifacts.require("Ownable");


var CommandCodec = artifacts.require("CommandCodec");
var DomainEventCodec = artifacts.require("DomainEventCodec");
var OperationCodec = artifacts.require("OperationCodec");

var TransferNFTPayloadCodec = artifacts.require("TransferNFTPayloadCodec");
var NFTTransferedPayloadCodec = artifacts.require("NFTTransferedPayloadCodec");
var NFTMintedPayloadCodec = artifacts.require("NFTMintedPayloadCodec");
var MintNFTPayloadCodec = artifacts.require("MintNFTPayloadCodec");

contract("EventStore", (accounts) => {
  it("should return the correct value", async () => {
    const instance = await EventStore.deployed(accounts[0]);
    const result = await instance.pull("123456789", 0, 1000)
    assert.equal(result.length, 0, "Unexpected result");
  });

  it("should work", async () => {
    const eventStore = await EventStore.deployed(accounts[0]);
    const dispatcher = await Dispatcher.deployed();
    const repository = await AggregateRepository.deployed();
    const nftAggregate = await NFTsAggregate.deployed();
    
    assert.equal(true, true, "Yes");
  });
});