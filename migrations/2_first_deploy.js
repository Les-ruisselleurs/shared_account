const FakeDai = artifacts.require('FakeDai');
const SharedAccountManager = artifacts.require('SharedAccountManager');

module.exports = async (deployer, network, accounts) => {
    if (network == 'development') {
        await deployer.deploy(FakeDai);
        await deployer.deploy(SharedAccountManager, '0x88bf67b3c033B0b46E33bCcAc0382Aa628fCfe01');
    } else if (network == 'earthy-meal') {
        await deployer.deploy(FakeDai);
        await deployer.deploy(SharedAccountManager, '0x88bf67b3c033B0b46E33bCcAc0382Aa628fCfe01');
    }
}