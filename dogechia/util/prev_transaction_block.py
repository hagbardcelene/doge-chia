from typing import Tuple

from dogechia.consensus.block_record import BlockRecord
from dogechia.consensus.blockchain_interface import BlockchainInterface
from dogechia.util.ints import uint128


def get_prev_transaction_block(
    curr: BlockRecord,
    blocks: BlockchainInterface,
    total_iters_sp: uint128,
) -> Tuple[bool, BlockRecord]:
    prev_transaction_block = curr
    while not curr.is_transaction_block:
        curr = blocks.block_record(curr.prev_hash)
    if total_iters_sp > curr.total_iters:
        prev_transaction_block = curr
        is_transaction_block = True
    else:
        is_transaction_block = False
    return is_transaction_block, prev_transaction_block
