// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;
import "forge-std/Script.sol";

import {BeaconProxy} from "@oz/proxy/beacon/BeaconProxy.sol";
import {UpgradeableBeacon} from "@oz/proxy/beacon/UpgradeableBeacon.sol";

import {ABDKMath64x64} from "abdk-libraries/ABDKMath64x64.sol";

// import {Formula, FormulaParams} from "../src/Formula.sol";
import {OsmoticController, MimeToken, MimeTokenFactory, OwnableProjectList, OsmoticPool, OsmoticParams} from "../src/OsmoticController.sol";
// import "../src/librerias/gnosis/GnosisWallet.sol";
import "../src/projects/ProjectRegistry.sol";
import "../src/interfaces/ISuperToken.sol";

contract CFADummy {
    struct FlowRate {
        address benef;
        int96 rate;
    }
    mapping(address => FlowRate) flowRates;

    function setFlowRate(
        IERC20 _fundingToken,
        address _benef,
        int96 _rate
    ) external returns (bool) {
        flowRates[address(_fundingToken)] = FlowRate(_benef, _rate);
        return true;
    }
}

abstract contract ScriptUtils is Script {

    bytes32 SALT = "TR0YA";

    /**
     * @dev OsmoticController data
     */
    UpgradeableBeacon osmoticControllerBeacon;
    BeaconProxy osmoticControllerProxy;
    OsmoticController osmoticControllerImpl;
    address controllerOwner;
    /**
     * @dev Registry data
     */
    UpgradeableBeacon registryBeacon;
    BeaconProxy registryProxy;
    ProjectRegistry registryImpl;
    address registryOwner;
    /**
     * @dev OsmoticPool data
     */
    OsmoticPool pool;


    //--------------------------------------------
    //              SAFE_UTILS
    //--------------------------------------------

    function _createCFA_llhh() internal returns (address impl_) {
        return address(new CFADummy());
    }

    //--------------------------------------------
    //              PROXY_UTILS
    //--------------------------------------------

    function _createBeaconAndProxy(
        address _implementation,
        address _initalOwner,
        bytes memory _initPayload
    ) internal returns (UpgradeableBeacon beacon_, BeaconProxy beaconProxy_) {
        beacon_ = new UpgradeableBeacon(_implementation,_initalOwner);
        beaconProxy_ = new BeaconProxy(address(beacon_), _initPayload);
    }

    //--------------------------------------------
    //              FORMULA_UTILS
    //--------------------------------------------
    // function createOsmoticPool()  returns () {

    // }
    /**
     * Crear OsmoticPool & proxy
     * Crear OsmoticController
     * Crear registry
     *
     */

    function setUpContracts(SetupConfig memory _config) public {
        (address _mimeImpl,address mimeTokenFactory )= _createMimeTokenFactory();

        (address _registryImpl, address projectRegistryAddress) = _createProjectRegistry(
            _config.version
        );

        pool = new OsmoticPool();
        address poolImpl=address(pool);

        (address impl_, address controllerProxy_) = _createOsmoticController(
            _config.version,
            projectRegistryAddress,
            poolImpl,
            mimeTokenFactory,
            _config.roundDuration
        );
        vm.stopBroadcast();

        console.log("OsmoticController_IMPL", impl_);
        console.log("OsmoticController_PORXY", controllerProxy_);
        console.log("OsmoticController_BEACON", address(osmoticControllerBeacon));
        console.log('==========================================');
        console.log("Registry_IMPL", _registryImpl);
        console.log("Registry_PORXY", projectRegistryAddress);
        console.log("Registry_BEACON", address(registryBeacon));
        console.log('==========================================');
        console.log("MimeToken_IMPL", _mimeImpl);
        console.log("MimeFactory_IMPL", mimeTokenFactory);
        console.log("POOL_IMPL", address(pool));

    }



    function _createOsmoticController(
        uint256 _version,
        address _osmoticPool,
        address _projectRegistry,
        address _mimeTokenFactory,
        uint256 _claimDuration
    ) internal returns (address impl_, address controllerProxy_) {
        osmoticControllerImpl = new OsmoticController();

        bytes memory initData = abi.encodeWithSignature(
            "initialize(uint256,address,address,address,uint256)",
            _version,
            _osmoticPool,
            _projectRegistry,
            _mimeTokenFactory,
            _claimDuration
        );

        (
            osmoticControllerBeacon,
            osmoticControllerProxy
        ) = _createBeaconAndProxy(
            address(osmoticControllerImpl),
            controllerOwner,
            initData
        );

        return (
            address(osmoticControllerImpl),
            address(osmoticControllerProxy)
        );
    }

    function _createMimeTokenFactory()
        internal
        returns (address _mimeImpl,address mimeTokenFactory_)
    {
        _mimeImpl = address(new MimeToken());
        vm.label(_mimeImpl, "mimeTokenImpl");

        mimeTokenFactory_ = address(new MimeTokenFactory(_mimeImpl));
        vm.label(mimeTokenFactory_, "mimeTokenFactory");
    }

    function _createProjectRegistry(
        uint256 _version
    ) internal returns (address impl_, address projectRegistryProxy_) {
        registryImpl = new ProjectRegistry(_version);
        (registryBeacon, registryProxy) = _createBeaconAndProxy(
            address(registryImpl),
            registryOwner,
            ""
        );
        return (address(registryImpl), address(registryProxy));
    }
}
struct SetupConfig {
    uint256 version;
    uint256 roundDuration;
    address cfaV1Forwarder;
    address nw_owner;
}
