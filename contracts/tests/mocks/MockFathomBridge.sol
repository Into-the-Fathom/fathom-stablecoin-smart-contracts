// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "../../main/interfaces/ICagable.sol";
import "../../main/interfaces/IAccessControlConfig.sol";
import "../../main/interfaces/IStablecoin.sol";
import "../../main/interfaces/IFathomBridge.sol";
import "../../main/utils/SafeToken.sol";


contract MockFathomBridge is PausableUpgradeable, IFathomBridge, ICagable {
    /// Client asterizm receive request DTO
    /// @param srcChainId uint64  Source chain ID
    /// @param srcAddress uint  Source address
    /// @param dstChainId uint64  Destination chain ID
    /// @param dstAddress uint  Destination address
    /// @param txId uint  Transaction ID
    /// @param transferHash bytes32  Transfer hash
    /// @param payload bytes  Transfer payload
    struct ClAsterizmReceiveRequestDto {
        uint64 srcChainId;
        uint srcAddress;
        uint64 dstChainId;
        uint dstAddress;
        uint txId;
        bytes32 transferHash;
        bytes payload;
    }


    using SafeToken for address;
    uint256 private txId;
    address public stablecoin;
    IAccessControlConfig public accessControlConfig;
    uint256 public fixedBridgeFee; // fixed fee [wad]
    uint256 public live; // Active Flag
    bool public isDecentralizedMode;
    mapping(address => bool) public whitelisted;
    mapping(uint64 => uint256) public bridgedInAmount; // [wad]
    mapping(uint64 => uint256) public bridgedOutAmount; // [wad]
    uint256 public override totalBridgedInAmount; // [wad]
    uint256 public override totalBridgedOutAmount; // [wad]

    modifier onlyOwnerOrGov() {
        require(
            accessControlConfig.hasRole(accessControlConfig.OWNER_ROLE(), msg.sender) ||
                accessControlConfig.hasRole(accessControlConfig.GOV_ROLE(), msg.sender),
            "!(ownerRole or govRole)"
        );
        _;
    }

    modifier onlyOwnerOrShowStopper() {
        require(
            accessControlConfig.hasRole(accessControlConfig.OWNER_ROLE(), msg.sender) ||
                accessControlConfig.hasRole(accessControlConfig.SHOW_STOPPER_ROLE(), msg.sender),
            "!(ownerRole or showStopperRole)"
        );
        _;
    }

    modifier onlyWhitelisted() {
        if (!whitelisted[msg.sender] && !isDecentralizedMode) {
            revert("FathomBridge/not-whitelisted");
        }
        _;
    }

    constructor() {
        // Must be commented out for test script
        // _disableInitializers();
    }

    function initialize(address _stablecoin, address _accessControlConfig) external initializer {
        _zeroAddressCheck(_stablecoin);
        _zeroAddressCheck(_accessControlConfig);
        stablecoin = _stablecoin;
        accessControlConfig = IAccessControlConfig(_accessControlConfig);
        live = 1;
        whitelisted[msg.sender] = true;
        // _asterizm_initialize(_initializerLib, true, false);
    }

    function addToWhitelist(address _usr) external onlyOwnerOrGov {
        _zeroAddressCheck(_usr);
        whitelisted[_usr] = true;
        emit LogAddToWhitelist(_usr);
    }

    function removeFromWhitelist(address _usr) external onlyOwnerOrGov {
        _zeroAddressCheck(_usr);
        whitelisted[_usr] = false;
        emit LogRemoveFromWhitelist(_usr);
    }

    function setDecentralizedMode(bool _isOn) external onlyOwnerOrGov {
        isDecentralizedMode = _isOn;
        emit LogSetDecentralizedMode(_isOn);
    }

    function setFee(uint256 _newFee) external onlyOwnerOrGov {
        fixedBridgeFee = _newFee;
        emit LogSetFee(_newFee);
    }

    function withdrawFees(address _to) external onlyOwnerOrGov {
        _zeroAddressCheck(_to);
        stablecoin.safeTransfer(_to, stablecoin.balanceOf(address(this)));
        emit LogWithdrawFees(msg.sender, _to, stablecoin.balanceOf(address(this)));
    }

    /// Cross-chain transfer
    /// works only when the sender is whitelisted or in decentralized mode
    /// @param _dstChainId uint64  Destination chain ID
    /// @param _to address  To address
    /// @param _amount uint  Amount
    function crossChainTransfer(uint64 _dstChainId, address _to, uint _amount) external onlyWhitelisted {
        require(live == 1, "FathomBridge/not-live");
        require(_amount > fixedBridgeFee, "FathomBridge/amount-less-than-fee");
        _zeroAddressCheck(_to);

        uint256 _actualTransferAmount = fixedBridgeFee != 0 ? _amount - fixedBridgeFee : _amount;
        IStablecoin(stablecoin).burn(msg.sender, _actualTransferAmount);
	    stablecoin.safeTransferFrom(msg.sender, address(this), _amount - _actualTransferAmount);

        bridgedOutAmount[_dstChainId] = bridgedOutAmount[_dstChainId] + _amount;
        totalBridgedOutAmount = totalBridgedOutAmount + _amount;

        //generate event for off-chain components
        _initAsterizmTransferEvent(_dstChainId, abi.encode(msg.sender, _to, _actualTransferAmount));
        emit LogCrossChainTransferOut(_dstChainId, msg.sender, _to, _actualTransferAmount, _getTxId());
        emit LogFeeCollection(msg.sender, fixedBridgeFee, _getTxId());
    }

    /// Cross-chain fn that triggers when receiving payload from another chain
    /// Minting logic on the receiver side
    function _asterizmReceive(ClAsterizmReceiveRequestDto memory _dto) internal {
        (address _from, address _to, uint _amount) = abi.decode(_dto.payload, (address, address, uint256));
        bridgedInAmount[_dto.srcChainId] = bridgedInAmount[_dto.srcChainId] + _amount;
        totalBridgedInAmount = totalBridgedInAmount + _amount;
        IStablecoin(stablecoin).mint(_to, _amount);
        emit LogCrossChainTransferIn(_dto.srcChainId, _from, _to, _amount);
    }


    function _zeroAddressCheck(address _address) internal pure {
        require(_address != address(0), "FathomBridge/zero-address");
    }

    /// @dev The `cage` function permanently halts the `collateralTokenAdapter` contract.
    /// Please exercise caution when using this function as there is no corresponding `uncage` function.
    /// The `cage` function in this contract is unique because it must be called before users can initiate `emergencyWithdraw` in the `collateralTokenAdapter`.
    /// It's a must to invoke this function in the `collateralTokenAdapter` during the final phase of an emergency shutdown.
    function cage() external override onlyOwnerOrShowStopper {
        if (live == 1) {
            live = 0;
            emit LogCage();
        }
    }

    /// @dev access: OWNER_ROLE, GOV_ROLE
    function pause() external onlyOwnerOrGov {
        _pause();
    }

    /// @dev access: OWNER_ROLE, GOV_ROLE
    function unpause() external onlyOwnerOrGov {
        _unpause();
    }

    function _initAsterizmTransferEvent(uint64 /**_dstChainId**/ , bytes memory /** _payload **/) internal {
        txId++;
    }

    function _getTxId() internal view returns(uint) {
        return txId;
    }

}