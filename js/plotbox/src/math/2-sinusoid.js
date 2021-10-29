import mem from 'memoizee';

import {
    inwardSymmetry,
    outwardSymmetry,
    reverseInwardSymmetry,
    reverseOutwardSymmetry,
} from 'math/1-basic';

export const reversePowCos = mem((x, y, { s=1, w, h }) => {
    const symX = reverseInwardSymmetry(x, w);
    const symY = reverseInwardSymmetry(y, h);
    let v =
        0.00000000000005 *
        s *
        Math.pow(symX * symY, 3) *
        Math.cos(1000 * (2 / symY) * (2 / symX));
    if (Number.isNaN(v)) {
        v = 0;
    }
    return v;
});

export const powCos = mem((x, y, { s=1, w, h }) => {
    const symX = reverseOutwardSymmetry(x, w);
    const symY = reverseOutwardSymmetry(y, h);
    let v =
        0.00000000000005 *
        s *
        Math.pow(symX * symY, 3) *
        Math.cos(1000 * s * (2 / symY) * (2 / symX));
    if (Number.isNaN(v)) {
        v = 0;
    }
    return v;
});