// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

// Exported struct for better osmotic parameter handling
struct OsmoticParams {
    uint256 decay;
    uint256 drop;
    uint256 maxFlow;
    uint256 minStakeRatio;
}
import {OsmoticController} from "../../src/OsmoticController.sol";

/**
 * @custom:instructions
 * In order to understand how this works and how to set up the variables, please head to `Instructions.md`
 */
contract CreateNewPool is Script {
    OsmoticController controller;
    address cfa;
    address funding;
    address mime;
    address list;

    uint pk;
    OsmoticParams params;
    /**
     * @custom:instructions 
     * 
     * This script is intended to be used in a scenario where the following requirements are met : 
      1. CFA is a valid address and is compatible with the Superfluid Protocol
      2. Funding MUST be compatible with superfluid's protocol; this means that should be a `SuperToken`
      3. Mime must be a valid `MimeToken` which is controlled by the user or by a trusted partner
      4. List should be valid list compatible with `Equilibra`
      5. Pk MUST be a valid private key that holds enough funds to use the script
      @custom:recomendation Is recommended to use a burner private key, exposing a private key that holds significant amounts of funds can be dangerous 
      6. Decay should be a rasonable value. If you don't know what a rasonable value looks to you, please check the documentation.
      7. Drop should be a rasonable value. If you don't know what a rasonable value looks to you, please check the documentation.
      8. MaxFlow should be a rasonable value. If you don't know what a rasonable value looks to you, please check the documentation.
      9. MinRatio should be a rasonable value. If you don't know what a rasonable value looks to you, please check the documentation.
      @custom:recomendation If after looking the documentation, you still have some doubts about the values, please, use the default values described in the documentation

      @custom:recomendation If you are not sure if the List is valid, the Mime is under a trusted partner (or yourself), we encourage you to use the [CreateAll.sol] script. There all the creations are being handle internally.

      @custom:env-vars : 
      First of all, you must set up a `.env` file in the root of your folder, and from there you can move on.

      CONTROLLER := Refers to the address of the `OsmoticController` of the chain selected. In order to check the oficial addresses, please head to the documentation.
      
      CFA_ADDRESS := Refers to the address of the `CFA_Forward`, this is basically the core contract of `Superfluid` wich allowes to create token flows  
      
      FUNDING_TOKEN := Refers to the address of the Funding token selected. This token MUST be a `SuperToken` or at least be compatible with the `Superfluid` protocol.
      
      MIME_TOKEN := Refers to the address of the `MimeToken` created specifically to this pool. Is recommended that this contract is controlled by the sender or by an external trusted partner.

      PROJECT_LIST := Refers to the address of the `OwnableProjectList` created specifically to this pool. Is recommended that this contract is controlled by the sender or by an external trusted partner.

      PK_SENDER := Refers to the private key of the sender. Is recommended to be used as a descartable key. Please, remember that the `private_key` gives you access to ALL assets helded by that address.

      DECAY := Is a uint that is used as a `cosntructror` value in the pool. It's purpose is to help in the calculation of the conviction voting.

      DROP := Is a uint that is used as a `cosntructror` value in the pool. It's purpose is to help in the calculation of the conviction voting.

      MAX_FLOW := Is a uint that is used as a `cosntructror` value in the pool. It's purpose is to help in the calculation of the conviction voting.

      MIN_RATIO := Is a uint that is used as a `cosntructror` value in the pool. It's purpose is to help in the calculation of the conviction voting.


     */

    constructor() {
        controller= OsmoticController(vm.envAddress('CONTROLLER'));
        cfa = vm.envAddress("CFA_ADDRESS");
        funding = vm.envAddress("FUNDING_TOKEN");
        mime = vm.envAddress("MIME_TOKEN");
        list = vm.envAddress("PROJECT_LIST");
        pk = vm.envUint("PK_SENDER");
        params.decay = vm.envUint("DECAY");
        params.drop = vm.envUint("DROP");
        params.maxFlow = vm.envUint("MAX_FLOW");
        params.minStakeRatio = vm.envUint("MIN_RATIO");
    }

    function run() external virtual {
        vm.startBroadcast(pk);
        _createPool(cfa, address(controller), funding, mime, list, params);
        vm.stopBroadcast();
    }

    function _createPool(
        address _cfaForwarder,
        address _controller,
        address _fundingToken,
        address _mimeToken,
        address _projectList,
        OsmoticParams memory _params
    ) internal returns (address) {
        bytes memory initLoad = abi.encodeWithSignature(
            "initialize(address,address,address,address,address,[uint256,uint256,uint256,uint256])",
            _cfaForwarder,
            _controller,
            _fundingToken,
            _mimeToken,
            _projectList,
            _params
        );
        return controller.createOsmoticPool(initLoad);
    }
}
