const { ethers } = require('hardhat');

async function main() {

    const rolesContract = await ethers.getContractFactory("Roles");

    const deployedRolesContract = await rolesContract.deploy();

    await deployedRolesContract.deployed()

    console.log("Roles contract deployed to:", deployedRolesContract.address)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1)
    })