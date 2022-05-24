import poseidon.(Poseidon);

circuit MerkleTree {

    /*
        Generates a root for a merkle tree of 8 elements

        amount_of_leaves, log2_amount_of_leaves and padding
        can be changed to work with merkle tree of different sizes
        
    */
    function generate_root(array: [field;8]) -> field{

        const amount_of_leaves: u32 = 8;
        const log2_amount_leaves: u32 = 3;
        //Computes a merkle root, that we use as a commitment
        let padding = [0field;25];
        //We need to add some padding else, it gets an out of bounds error 
        //Note this makes the calculation really slow, since all paths of branches
        //are "executed" in the circuit
        //TO DO: Generate a small precompiler for macros or a small program to 
        //generate an optimized version of the loops
        let array_of_leaves = [...array, ...padding];

        for i in 0..log2_amount_leaves {
            console.log("Round {} of Hashes", i);
            //For max_options
            for j in 0..amount_of_leaves {
                let step = 2**(i);
                // This is the modulus
                let should_skip = j-(j/2)*2;
                if (((j+1)*step) < 8) && (should_skip == 0){
                    console.log("Hashing: {} {} in position: {}", j*step, (j+1)*step, j*step);
                    array_of_leaves[j*step] = 
                        Poseidon::poseidon_2_1(
                            array_of_leaves[j*step], 
                            array_of_leaves[(j+1)*step]
                        );
                }
            }
        }
        return array_of_leaves[0];
    }
}


// CODE FOR TESTING BELOW

circuit MerkleTreeForTest {
    function dummy_hash_plus_one(value:field) -> field{
        return value+1;
    }

    function dummy_pack_add(a_value:field, another_value:field) -> field{
        return a_value+another_value;
    }

    function dummy_add_hash_2_1(a_value:field, another_value:field) -> field{
        return a_value + another_value;
    }

    function verify_proof(leave:field, proof: [field;3], path_index: [bool;3], root: field) -> bool{
        const amount_of_leaves: u32 = 8;
        const levels: u32 = 3;

        let element = leave;

        for i in 0..levels{
            if path_index[i] {
                element = MerkleTreeForTest::dummy_add_hash_2_1(proof[i],element);
            } else {
                element = MerkleTreeForTest::dummy_add_hash_2_1(element, proof[i]);
            }
        }

        return element == root;
    }

    //This is always the same code as the merkle tree, 
    //but with a dummy hash to test
    function generate_dummy_root(array: [field;8]) -> field{

        const amount_of_leaves: u32 = 8;
        const log2_amount_leaves: u32 = 3;
        //A field to use with mimc
        //Since we don't care about the encryption it can be any const
        const a_field: field = 123123123; 
        let hashed_array = array;

        for i in 0..amount_of_leaves{
            hashed_array[i] = MerkleTreeForTest::dummy_hash_plus_one(array[i]);
        }

        //Computes a merkle root, that we use as a commitment
        let padding = [0field;25];
        //We need to add some padding else, it gets an out of bounds error 
        //Note this makes the calculation really slow, since all paths of branches
        //are "executed" in the circuit
        //TO DO: Generate a small precompiler for macros or a small program to 
        //generate an optimized version of the loops
        let array_of_leaves = [...hashed_array, ...padding];

        for i in 0..log2_amount_leaves {
            console.log("Round {} of Hashes", i);
            //For max_options
            for j in 0..amount_of_leaves {
                let step = 2**(i);
                // This is the modulus
                let should_skip = j-(j/2)*2;
                if (((j+1)*step) < 8) && (should_skip == 0){
                    console.log("Hashing: {} {} in position: {}", j*step, (j+1)*step, j*step);
                    array_of_leaves[j*step] = 
                        MerkleTreeForTest::dummy_hash_plus_one(MerkleTreeForTest::dummy_pack_add(
                            array_of_leaves[j*step], 
                            array_of_leaves[(j+1)*step]));
                }
            }
        }
        return array_of_leaves[0];
    }
}
