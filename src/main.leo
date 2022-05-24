import merkle_tree.(MerkleTree);
import merkle_tree.(MerkleTreeForTest);

function main(leaves: [field; 8]) -> field {
    return MerkleTree::generate_root(leaves);
}

@test
function test_merkle_tree(){
    let array: [field;8] = [0,0,1,1,0,1,0,1];
    let root = MerkleTreeForTest::generate_dummy_root(array);
    //Hash function adds one so we get
    //1 1 2 2 1 2 1 2
    //Then we group them by adding them
    //2 4 3 3
    //Then we hash them adding one
    //3 5 4 4
    //Then we pack them by adding them
    //8 8
    //Then we hash them by adding one
    //9 9
    //Then we pack them
    //18
    //Then we hash them by adding one
    //19
    console.log("Root is: {}", root);
    console.assert(root == 19field);
}


@test
function test_verify_merkle_proof(){
    let array: [field;8] = [0,0,1,3,0,1,0,1];
    //The original array is
    //We denote the merkle path for the third element with >
    //0 0 >1 3 0 1 0 1
    //Hash the array in pairs so we get
    //0 2 >4 1
    //Then we hash them again
    //2 >5
    //Then we hash them again
    //7 

    //Merkle proof for third element is
    // 1, 1, 2

    let merkle_proof: [field;3] = [3,1,2];
    let path_index: [bool;3] = [true,true, false];
    let root: field = 7;
    let is_valid = MerkleTreeForTest::verify_proof(array[2],merkle_proof,path_index,root);
    console.assert(is_valid);

    let wrong_merkle_proof: [field;3] = [3,1,1];
    is_valid = MerkleTreeForTest::verify_proof(array[2],wrong_merkle_proof,path_index,root);
    console.assert(!is_valid);
}
