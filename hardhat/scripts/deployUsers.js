const { ethers } = require('hardhat');

async function main() {

    const usersContract = await ethers.getContractFactory("Users");

    const deployedUsersContract = await usersContract.deploy("0x5FbDB2315678afecb367f032d93F642f64180aa3");

    await deployedUsersContract.deployed()

    console.log("Users contract deployed to:", deployedUsersContract.address)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1)
    })