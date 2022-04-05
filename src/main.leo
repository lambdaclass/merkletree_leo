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
