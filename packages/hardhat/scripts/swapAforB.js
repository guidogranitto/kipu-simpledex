// Archivo: swapAforB.js
const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    const tokenA = await hre.ethers.getContractAt("ERC20", "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512", deployer);
    const simpleDEX = await hre.ethers.getContractAt("SimpleDEX", "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9", deployer);

    console.log("Aprobando TokenA para el swap...");
    await tokenA.approve(simpleDEX.address, hre.ethers.utils.parseEther("100"));
    console.log("TokenA aprobado.");

    console.log("Realizando swap de A por B...");
    await simpleDEX.swapAforB(hre.ethers.utils.parseEther("100"));
    console.log("Swap completado.");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});