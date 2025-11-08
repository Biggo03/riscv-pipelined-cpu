`define CHECK(cond, msg, arg1=, arg2=) \
    assert(cond) else begin \
        $error(msg, arg1, arg2); \
        error_cnt++; \
    end

`define TEST_PASS 32'hABCD1234
`define TEST_FAIL 32'hDEADBEEF
