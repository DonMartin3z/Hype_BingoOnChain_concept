import { ethers } from 'ethers';
import contractJson from '../../data/artifacts/contracts/BingoSBT.sol/BingoSBT.json';
import contractAddresses from '../../data/__config.json';

export let sbtStore = {
  name: 'sbtStore',
  obj: {
    contract: undefined,
    address: undefined,

    async connect(wallet) {
      this.contract = new ethers.Contract(contractAddresses.bingoGameSBTContract, contractJson.abi, wallet);
      console.log('this.contract:');
      console.log(this.contract);
    },

    // TODO: Add functions as they are needed for calling this contract
  },
};