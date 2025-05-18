using ZODA
using BinaryFields
using Test

message_length = 4
block_length = 8
message = rand(BinaryElem16, message_length)

inst = zoda_setup(BinaryElem16, message_length, block_length, message)
queries = [1, 3]
proof = zoda_prove(inst, queries)

data = [inst.encoded[i] for i in queries]
@test zoda_verify(inst, proof, queries, data)
