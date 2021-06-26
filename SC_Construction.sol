// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
contract SC_UNINA_OPT {
// Defining the structure Actor
struct Actor{
address ActorAddress;
bytes32 ContractRef;
bool Allowed;
}

// Defining the structure Transmission
struct Transmission{
bool Current_version;
address Sender;
uint mineTime;
uint blockNumber;
bytes32 Trs_hash;
bytes32 DocType;
bytes32 FileHash;
bytes32 FileHash_New;
}

// Define NULL constant
bytes32 constant NULL = "";
//Defining a array with the list of transmitted hashes 
bytes32[] private ListdocHash;


// Defining the structure map to store the docHashes in order to have 
//an accesskey to the Transmission
mapping (bytes32 => Transmission) private docHashes;
mapping (address => Actor) private ActorList;

constructor() {
Actor memory newActor =Actor (msg.sender,0xe620103cbd446307acee11e21d83a6e23db307a4549b06d2442a1b728c4601dc,true);
ActorList[msg.sender] = newActor;
}

//Add Actor
function Add_Actor (address _NewActorAddress,bytes32 _NewActorContract) public {
// If the submitted file is new
if(ActorList[msg.sender].Allowed == true) { 
//Add new transmission
Actor memory newActor =Actor (_NewActorAddress,_NewActorContract,true);
ActorList[_NewActorAddress] = newActor;
} else {
revert("ERROR 01: You are not authorized to add actors. ");
}}



//Add transmission function
function Add_transmission (bytes32 _FileName,bytes32 _FileType,
bool _NewVersion, bytes32 _FileHash, 
bytes32 _OldFileHash) public {
if(ActorList[msg.sender].Allowed == true) {  
// If the submitted file is new
if(_NewVersion == true) { // if else statement
//Add new transmission
Transmission memory newTransmission =Transmission (true,msg.sender,block.timestamp, block.number,_FileName, _FileType, _FileHash, NULL);
docHashes[_FileHash] = newTransmission;
ListdocHash.push(_FileHash);

} else {
//If it is a revision: Update the old version
if (docHashes[_OldFileHash].Sender == msg.sender){
docHashes[_OldFileHash].Current_version = false;
docHashes[_OldFileHash].FileHash_New = _FileHash;
Transmission memory newTransmission =Transmission (false,msg.sender,block.timestamp, block.number,
_FileName, _FileType, _FileHash,  _OldFileHash);
docHashes[_FileHash] = newTransmission;
ListdocHash.push(_FileHash);

}else {
revert("ERROR 03: You are not authorized to update a file you did not create.  ");
}
    
}


}else {
revert("ERROR 02: You are not authorized to Transmit File. ");
}}

//Return transmission register function
function Return_reg()
public view
returns (address[] memory, bytes32[] memory, bytes32[] memory, uint[] memory, 
uint[] memory, bytes32[] memory, bool[] memory) {

if(ActorList[msg.sender].Allowed == true) {    
    
//Initialisation of vectors 
address[] memory Senders = new address[](ListdocHash.length);
bytes32[] memory FileNames = new bytes32[](ListdocHash.length);
bytes32[] memory DocTypes = new bytes32[](ListdocHash.length);
uint[] memory mineTimes = new uint[](ListdocHash.length);
uint[] memory blockNumbers = new uint[](ListdocHash.length);
bytes32[] memory FileHashs = new bytes32[](ListdocHash.length);
bool[] memory LstVers = new bool[](ListdocHash.length);

//Cycling through all the values I have on the hash list
for (uint i = 0; i < ListdocHash.length || i < 20; i++) {
Senders[i]=docHashes[ListdocHash[i]].Sender;

DocTypes[i] = docHashes[ListdocHash[i]].DocType;
mineTimes[i] = docHashes[ListdocHash[i]].mineTime;
blockNumbers[i] = docHashes[ListdocHash[i]].blockNumber;
FileHashs[i] = docHashes[ListdocHash[i]].FileHash;
LstVers[i] = docHashes[ListdocHash[i]].Current_version;

}
//Returning the Register of transmissions
return (Senders, FileNames, DocTypes, mineTimes, blockNumbers, FileHashs,LstVers);

} else {
revert("ERROR 04: You are not authorized to read the trasmissions history.  ");
}}

function Check_trans (bytes32 TdocHashes) public view returns(address,bytes32,uint, uint,bytes32){
if(ActorList[msg.sender].Allowed == true) {      
if(docHashes[TdocHashes].Current_version == true){
return(docHashes[TdocHashes].Sender,docHashes[TdocHashes].DocType, docHashes[TdocHashes].mineTime, docHashes[TdocHashes].blockNumber, docHashes[TdocHashes].FileHash);
}else{
    revert("ERROR 06: Transmission not found.");}
} else {
revert("ERROR 05: You are not authorized to check Transmission.");
}}

}
