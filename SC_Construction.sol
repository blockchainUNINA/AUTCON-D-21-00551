// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
contract SmartContractUnina {
// Defining the structure Actor
struct Actor{
address ActorAddress;
bytes32 ContractRef;
bool Allowed;
}

// Defining the structure Transmission
struct Transmission{
bytes32 FileName;
bytes32 DocType;
bytes32 FileHash;
bytes32 FileHash_New;
bool Current_version;
address Sender;
uint mineTime;
uint blockNumber;
}

// Define NULL constant
bytes32 constant NULL = "";
//Defining a array with the list of transmitted hashes 
bytes32[] private listdocHash;



// Defining the structure map to store the docHashes in order to have 
//an accesskey to the Transmission
mapping (bytes32 => Transmission) private docHashes;
mapping (address => Actor) private actorList;

constructor() {
Actor memory newActor =Actor (msg.sender,0xe620103cbd446307acee11e21d83a6e23db307a4549b06d2442a1b728c4601dc,true);
actorList[msg.sender] = newActor;
}

//Add Actor
function addActor (address newActorAddress,bytes32 newActorContract) external {
// If the submitted file is new
if(actorList[msg.sender].Allowed) { 
//Add new transmission
Actor memory newActor =Actor (newActorAddress,newActorContract,true);
actorList[newActorAddress] = newActor;
} else {
revert("ERROR 01: You are not authorized to add actors. ");
}}



//Add transmission function
function addtransmission (bytes32 fileName,bytes32 fileType,
bool newVersion, bytes32 fileHash, 
bytes32 oldfileHash) external {
if(actorList[msg.sender].Allowed ) {  
// If the submitted file is new
if(newVersion) { // if else statement
//Add new transmission
Transmission memory newTransmission =Transmission (fileName, fileType, fileHash, NULL,true,msg.sender,block.timestamp, block.number);
docHashes[fileHash] = newTransmission;
listdocHash.push(fileHash);

} else {
//If it is a revision: Update the old version
if (docHashes[oldfileHash].Sender == msg.sender){
docHashes[oldfileHash].Current_version = false;
docHashes[oldfileHash].FileHash_New = fileHash;
Transmission memory newTransmission =Transmission (fileName, fileType, fileHash,  oldfileHash,false,msg.sender,block.timestamp, block.number);
docHashes[fileHash] = newTransmission;
listdocHash.push(fileHash);

}else {
revert("ERROR 03: You are not authorized to update a file you did not create.  ");
}
    
}


}else {
revert("ERROR 02: You are not authorized to Transmit File. ");
}}

//Return transmission register function
function returnReg()
external view
returns (address[] memory, bytes32[] memory,   bytes32[] memory,uint[] memory, 
uint[] memory, bytes32[] memory, bool[] memory) {

if(actorList[msg.sender].Allowed) {    
    
//Initialisation of vectors 
address[] memory Senders = new address[](listdocHash.length);
bytes32[] memory FileNames = new bytes32[](listdocHash.length);
bytes32[] memory DocTypes = new bytes32[](listdocHash.length);
uint[] memory mineTimes = new uint[](listdocHash.length);
uint[] memory blockNumbers = new uint[](listdocHash.length);
bytes32[] memory FileHashs = new bytes32[](listdocHash.length);
bool[] memory LstVers = new bool[](listdocHash.length);

//Cycling through all the values I have on the hash list
for (uint i = 0; i < listdocHash.length && i < 20; i++) {
Senders[i]=docHashes[listdocHash[i]].Sender;
FileNames[i]=docHashes[listdocHash[i]].FileName;
DocTypes[i] = docHashes[listdocHash[i]].DocType;
mineTimes[i] = docHashes[listdocHash[i]].mineTime;
blockNumbers[i] = docHashes[listdocHash[i]].blockNumber;
FileHashs[i] = docHashes[listdocHash[i]].FileHash;
LstVers[i] = docHashes[listdocHash[i]].Current_version;

}
//Returning the Register of transmissions
return (Senders, FileNames, DocTypes, mineTimes, blockNumbers, FileHashs,LstVers);

} else {
revert("ERROR 04: You are not authorized to read the trasmissions history.  ");
}}

function checkTrans (bytes32 tdocHashes) external view returns(address,bytes32,uint, uint,bytes32){
if(actorList[msg.sender].Allowed ) {      
if(docHashes[tdocHashes].Current_version ){
return(docHashes[tdocHashes].Sender,docHashes[tdocHashes].DocType, docHashes[tdocHashes].mineTime, docHashes[tdocHashes].blockNumber, docHashes[tdocHashes].FileHash);
}else{
    revert("ERROR 06: Transmission not found.");}
} else {
revert("ERROR 05: You are not authorized to check Transmission.");
}}

}
