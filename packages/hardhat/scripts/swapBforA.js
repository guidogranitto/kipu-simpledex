// Archivo: swapBforA.js
const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    const tokenB = await hre.ethers.getContractAt("ERC20", "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0", deployer);
    const simpleDEX = await hre.ethers.getContractAt("SimpleDEX", "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9", deployer);

    console.log("Aprobando TokenB para el swap...");
    await tokenB.approve(simpleDEX.address, hre.ethers.utils.parseEther("50"));
    console.log("TokenB aprobado.");

    console.log("Realizando swap de B por A...");
    await simpleDEX.swapBforA(hre.ethers.utils.parseEther("50"));
    console.log("Swap completado.");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});