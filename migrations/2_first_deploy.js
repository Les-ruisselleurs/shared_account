const FakeDai = artifacts.require('FakeDai');
const SharedAccountManager = artifacts.require('SharedAccountManager');

module.exports = async (deployer, network, accounts) => {
    if (network == 'development') {
        await deployer.deploy(FakeDai);
    }

    await deployer.deploy(SharedAccountManager);
}