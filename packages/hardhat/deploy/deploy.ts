import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

/**
 * Deploys TokenA, TokenB, and SimpleDEX contracts using the deployer account.
 * TokenA and TokenB have an initial supply, and SimpleDEX is initialized with their addresses.
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployContracts: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployer } = await hre.getNamedAccounts();
    const { deploy } = hre.deployments;

    // Define initial token supply in Wei (1,000,000 tokens)
    const initialSupply = "1000000000000000000000000"; // Equivalent to 1,000,000 tokens in Wei

    // Deploy TokenA
    const tokenADeployment = await deploy("TokenA", {
        from: deployer,
        args: [initialSupply], // Pass initial supply in Wei
        log: true,
        autoMine: true,
    });
    console.log("🚀 TokenA deployed to:", tokenADeployment.address);

    // Deploy TokenB
    const tokenBDeployment = await deploy("TokenB", {
        from: deployer,
        args: [initialSupply], // Pass initial supply in Wei
        log: true,
        autoMine: true,
    });
    console.log("🚀 TokenB deployed to:", tokenBDeployment.address);

    // Deploy SimpleDEX
    const simpleDEXDeployment = await deploy("SimpleDEX", {
        from: deployer,
        args: [tokenADeployment.address, tokenBDeployment.address], // Pass addresses of TokenA and TokenB
        log: true,
        autoMine: true,
    });
    console.log("🚀 SimpleDEX deployed to:", simpleDEXDeployment.address);

    // Get the deployed SimpleDEX contract to interact with it after deploying.
    const simpleDEXContract = await hre.ethers.getContract<Contract>("SimpleDEX", deployer);
    console.log("✅ SimpleDEX contract ready for interactions");
};

export default deployContracts;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g., yarn deploy --tags SimpleDEX
deployContracts.tags = ["SimpleDEX", "TokenA", "TokenB"];
