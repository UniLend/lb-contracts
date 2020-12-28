const Factory = artifacts.require("UniLendLbFactory")
const Router = artifacts.require("UniLendLbRouter")


module.exports = async function(deployer) {
  deployer
  .then(async () => {
    let swapFactory = '0x1AB74d9eBD4FEC1A88a386e2597C2068eb28c9b1'
    let WETH = '0xc778417E063141139Fce010982780140Aa0cD5Ab''
    
    // Deploy factory contract
    await deployer.deploy(Factory)
    const FactoryContract = await Factory.deployed()
    console.log("LB Factory deployement done:", Factory.address)

    // Deploy router contract
    await deployer.deploy(Router, Factory.address, swapFactory, WETH)
    const RouterContract = await Router.deployed()
    console.log("LB Router deployement done", RouterContract.address)
  })
}
