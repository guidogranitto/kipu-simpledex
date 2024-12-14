const hre = require("hardhat");

async function main() {
    const tokenAAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
    const tokenBAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
    const simpleDEXAddress = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";

    const [deployer] = await hre.ethers.getSigners();
    const TokenA = await hre.ethers.getContractAt("ERC20", tokenAAddress, deployer);
    const TokenB = await hre.ethers.getContractAt("ERC20", tokenBAddress, deployer);
    const SimpleDEX = await hre.ethers.getContractAt("SimpleDEX", simpleDEXAddress, deployer);

    console.log("Aprobando y añadiendo liquidez...");
    await TokenA.approve(simpleDEXAddress, hre.ethers.utils.parseEther("1000"));
    await TokenB.approve(simpleDEXAddress, hre.ethers.utils.parseEther("1000"));

    await SimpleDEX.addLiquidity(
        hre.ethers.utils.parseEther("1000"),
        hre.ethers.utils.parseEther("1000")
    );
    console.log("Liquidez añadida.");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
