// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;
// import "forge-std/Script.sol";

import {DeploySystem} from "./DeploySystem.s.sol";
import {OsmoticController, OsmoticParams} from "../src/OsmoticController.sol";


contract Create_Pool is DeploySystem {
    OsmoticController controller ;

    uint pkpool = vm.envUint("PK_POOL_BUILDER");
    
    string PROJECT_LIST_NAME = "LIST_X";

    string MIME_NAME = "";
    string MIME_SYMBOLE = "";
    bytes32 MIME_MERKLE = "";
    uint MIME_ROUND_DURATION = 0;
    
    OsmoticParams  params = OsmoticParams(0, 0, 0, 0);

    address FUNDING_TOKEN = address(0);

    address list;
    address mimeToken;
    address poolAddr;

    function run() public override {
        super.run();
        _buildPool();
    }

    

    function _buildPool() internal {
        controller=OsmoticController(address(osmoticControllerProxy));
        vm.startBroadcast(pkpool);

        list = controller.createProjectList(PROJECT_LIST_NAME);

        mimeToken = _createMime(
            MIME_NAME,
            MIME_SYMBOLE,
            MIME_MERKLE,
            block.timestamp,
            MIME_ROUND_DURATION
        );

        poolAddr = _createPool(
            config.cfaV1Forwarder,
            address(controller),
            FUNDING_TOKEN,
            mimeToken,
            list,
            params
        );

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

    function _createMime(
        string memory _name,
        string memory _symbol,
        bytes32 _merkleRoot,
        uint _timestamp,
        uint _timeDuration
    ) internal returns (address) {
        bytes memory initLoad = abi.encodeWithSignature(
            "initialize(string,string,bytes32,uint256,uint256)",
            _name,
            _symbol,
            _merkleRoot,
            _timestamp,
            _timeDuration
        );
        return controller.createMimeToken(initLoad);
    }
}
