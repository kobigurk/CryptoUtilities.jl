module ZODA

using BinaryReedSolomon
using BatchedMerkleTree

export ZODAInstance, zoda_setup, zoda_prove, zoda_verify

"""
    struct ZODAInstance{T}

Object holding the parameters and Merkle root for a ZODA data availability
construction. This is a basic reference implementation based on the
`BinaryReedSolomon` and `BatchedMerkleTree` utilities. It roughly follows the
construction presented in the ZODA paper.
"""
struct ZODAInstance{T}
    rs::ReedSolomonEncoding{T}
    encoded::Vector{T}
    tree::CompleteMerkleTree
    root::MerkleRoot
end

"""
    zoda_setup(T, message_length, block_length, message)

Encode `message` using a Reed--Solomon encoding and create a Merkle tree over the
encoded chunks. Returns a `ZODAInstance` containing the resulting structures.
"""
function zoda_setup(::Type{T}, message_length::Int, block_length::Int, message) where T
    rs = reed_solomon(T, message_length, block_length)
    encoded = encode(rs, message)
    tree = build_merkle_tree(encoded)
    root = get_root(tree)
    return ZODAInstance{T}(rs, encoded, tree, root)
end

"""
    zoda_prove(inst, queries)

Create a batched Merkle proof for the leaf indices in `queries`.
"""
function zoda_prove(inst::ZODAInstance, queries)
    prove(inst.tree, queries)
end

"""
    zoda_verify(inst, proof, queries, leaves)

Verify a batched proof against the instance's Merkle root.
`leaves` should contain the data corresponding to the queried indices.
"""
function zoda_verify(inst::ZODAInstance, proof::BatchedMerkleProof, queries, leaves)
    verify(inst.root, proof; depth=get_depth(inst.tree), leaves, leaf_indices=queries)
end

end # module
