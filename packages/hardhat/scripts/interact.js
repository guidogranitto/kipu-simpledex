import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();

    // Direcciones de los contratos desplegados
    const tokenAAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
    const tokenBAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
    const simpleDexAddress = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";

    const amountToApprove = ethers.utils.parseUnits("1000", 18); // Cambia el monto si es necesario

    // Conectar a los contratos de token
    const TokenA = await ethers.getContractAt("ERC20", tokenAAddress, deployer);
    const TokenB = await ethers.getContractAt("ERC20", tokenBAddress, deployer);

    // Aprobar a SimpleDEX para gastar tokens
    console.log("Aprobando Token A...");
    await TokenA.approve(simpleDexAddress, amountToApprove);
    console.log("Token A aprobado.");

    console.log("Aprobando Token B...");
    await TokenB.approve(simpleDexAddress, amountToApprove);
    console.log("Token B aprobado.");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
