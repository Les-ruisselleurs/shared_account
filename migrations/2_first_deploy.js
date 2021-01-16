const FakeDai = artifacts.require('FakeDai');
const SharedAccount = artifacts.require('SharedAccount');

module.exports = async (deployer, network, accounts) => {
    //  dai address on mainnet
    var daiAddress = '0x6b175474e89094c44da98b954eedeac495271d0f';
    if (network == 'development') {
        await deployer.deploy(FakeDai);
        daiAddress = FakeDai.address;
    }

    await deployer.deploy(SharedAccount, daiAddress, 'Kleak test', false);
}