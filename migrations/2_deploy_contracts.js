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

var relay = "0x0Bd06bcC1D913640a811FDBB40ED155d3f861542";
module.exports = function(deployer) {

    let eventStoreInstance;

    deployer.deploy(CommandCodec);
    deployer.deploy(OperationCodec);
    deployer.deploy(DomainEventCodec);
    deployer.deploy(Utils);
    
    deployer.link(CommandCodec, AggregateRepository);
    deployer.link(DomainEventCodec, AggregateRepository);

    deployer.deploy(NFTsAggregate).then(() => {
        deployer.link(NFTsAggregate, AggregateRepository)
        return deployer.deploy(EventStore, relay);
    }).then((instance) => {
        eventStoreInstance = instance;
        deployer.link(EventStore, AggregateRepository)
        return deployer.deploy(AggregateRepository, EventStore.address);
    }).then((repository) => {
        repository.addAggregate("123456789", NFTsAggregate.address)
        return deployer.deploy(Dispatcher);
    });
    // Additional contracts can be deployed here
};