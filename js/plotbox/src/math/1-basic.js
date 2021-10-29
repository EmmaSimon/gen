export const inwardSymmetry = (p, max) => (p > (max - 1) / 2 ? max - 1 - p : p);
export const outwardSymmetry = (p, max) =>
    p < (max - 1) / 2 ? (max - 1) / 2 - p : p - (max - 1) / 2;
export const reverseInwardSymmetry = (p, max) => (p < (max - 1) / 2 ? max - 1 - p : p);
export const reverseOutwardSymmetry = (p, max) =>
    p < (max - 1) / 2 ? p + 1 + (max - 1) / 2 : max - p + (max - 1) / 2;

export const squared = (x,y) => x^2 + y^2;
export const cosTimesSin = (x, y) => Math.cos(x) * Math.sin(y);
export const cosPlusSin = (x, y) => Math.cos(x) + Math.sin(y);
export const cosOverSin = (x, y) => Math.cos(x) / Math.sin(y);
export const sinPlusSin = (x, y) => Math.sin(x) + Math.sin(y);