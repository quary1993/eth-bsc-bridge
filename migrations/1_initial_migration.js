const MultiSigWallet = artifacts.require("MultiSigWallet");
const GlueReceiver = artifacts.require("GlueReceiver");

module.exports = function (deployer) {
  //deployer.deploy(MultiSigWallet,["0xBb3f8f2774729b17E2abC8BE6bC6383ACAc0D5Da","0x389023cF6216bB0888DB1c9722c536c96752D44F","0x3a7aBF504a42F6791051df471ad408a01d9446D3"],2).then(function(){
    deployer.deploy(GlueReceiver,"1000000000000000","1000000000000000","0x1D48Ff980B8AaD8e8CCC563eF7cd162720d88ff1"); //0x6141Bf4BEa2D4dBa64eBc935F7029043d673865F
  //});
  
};
