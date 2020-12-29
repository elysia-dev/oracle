pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.6/vendor/Ownable.sol";
//import "https://github.com/smartcontractkit/chainlink/evm-contracts/src/v0.6/ChainlinkClient.sol";
//import "https://github.com/smartcontractkit/chainlink/evm-contracts/src/v0.6/vendor/Ownable.sol";

contract APIConsumer is ChainlinkClient {
  
    uint256 public volume;
    
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    /// @notice Emitted when Oracle Address is changed
    event NewOracle(address newOracle);

    /// @notice Emitted when JobId is changed
    event NewJobId(bytes32 newJobId);

    /// @notice Emitted when Fee is changed
    event NewFee(uint256 newFee);

    /**
     * Example
     * Network: Kovan
     * Oracle: Chainlink - 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e
     * Job ID: Chainlink - 29fa9aa13bf1468788b7cc4a500a45b8
     * Fee: 0.1 LINK
     *
     * Network: Mainnet
     * Oracle: DelphiOracle - 0x475585efd6E684BeA22D0e55Ff8667B836048435
     * Job ID: UINT256 JSON API - c02424acfae647bdb32fe4bd53860eea
     * Fee: 0.1 LINK
     */

	constructor() public {
        setPublicChainlinkToken();
        oracle = 0x049Bd8C3adC3fE7d3Fc2a44541d955A537c2A484;
        jobId = "98839fc3b550436bbe752f82d7521843";
        fee = 0.1 * 10 ** 18; // 0.1 LINK
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestVolumeData() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
		request.add("get", "https://api.coingecko.com/api/v3/simple/token_price/ethereum?contract_addresses=0x2781246fe707bb15cee3e5ea354e2154a2877b16&vs_currencies=usd");
		request.add("path", "0x2781246fe707bb15cee3e5ea354e2154a2877b16.usd");
        int timesAmount = 10**18;
        request.addInt("times", timesAmount);
        
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    
    /**
     * Receive the response in the form of uint256
     */ 
    function fulfill(bytes32 _requestId, uint256 _volume) public recordChainlinkFulfillment(_requestId)
    {
        volume = _volume;
    }

    function setOracle(address _oracle) external onlyOwner returns (bool) {
        oracle = _oracle;

        emit NewOracle(_oracle);

        return true;
    }

	function setJobId(address _jobId) external onlyOwner returns (bool) {
        jobId = _jobId;

        emit NewJobId(_jobId);

        return true;
    }

	function setFee(uint256 _fee) external onlyOwner returns (bool) {
		fee = _fee;

        emit NewFee(_fee);

        return true;
    }
}
