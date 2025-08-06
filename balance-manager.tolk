const MY_WORKCHAIN = BASECHAIN;
const OP_DEPOSIT = stringCrc32("deposit"); // 23a4c119
const OP_WITHDRAW = stringCrc32("withdraw"); // 94bde220

var balance: int = 0;

fun depositFunds(amount: int) {
    balance += amount;
}

fun withdrawFunds(amount: int) {
    assert(balance >= amount) throw 1002;
    balance -= amount;
}

fun routeInternal(`ctx::sender`: slice, `ctx::value`: int, `ctx::fwd_fee`: int, `ctx::body`: slice) {
    var (op: int, _) = `ctx::body`.loadOpAndQueryId();

    if (op == OP_DEPOSIT) {
        depositFunds(10);
        return;
    }

    if (op == OP_WITHDRAW) {
        withdrawFunds(5);
        return;
    }

    throw 0xffff;
}

fun main(`ctx::value`: int, inMsgFull: cell, `ctx::body`: slice) {
    var s: slice = inMsgFull.beginParse();
    var flags = s.loadMsgFlags();
    if (isBounced(flags)) { return; }

    var (`ctx::sender`: slice, `ctx::fwd_fee`: int) = s.retrieveCtx(MY_WORKCHAIN);
    routeInternal(`ctx::sender`, `ctx::value`, `ctx::fwd_fee`, `ctx::body`);
}
