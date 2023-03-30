const EventStore = artifacts.require("EventStore");

contract("EventStore", (accounts) => {
  it("should return the correct value", async () => {
    const instance = await EventStore.deployed(accounts[0]);
    const result = await instance.pull("123456789", 0, 1000)
    assert.equal(result.length, 0, "Unexpected result");
  });
});