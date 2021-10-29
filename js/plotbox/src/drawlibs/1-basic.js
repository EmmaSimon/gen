import {sinPlusSin, squared} from '../math/1-basic';
import {powCos, reversePowCos} from '../math/2-sinusoid';

const fParam = {};

// lines
const lineDraw = ({numLines = 10, margin = 10, pallette=[[255]]} = {}) => p5 => {
    p5.background(255, 255, 255);
    p5.strokeWeight(1);
    for (let l = 0; l < numLines; l++) {
        const lineSpacing = (p5.width - (margin * 2))/(numLines - 1);
        const x = margin + (l * lineSpacing);
        p5.stroke(...pallette[l%pallette.length]);
        p5.line(x, margin, x, p5.height - margin);
    }
}

const lineFuncDraw = ({
    numLines = 10,
    margin = 10,
    pallette=[[255]],
    f=powCos,
    step=1,
    colorValueSpan=[0, 400],
    scale=3,
} = {}) => p5 => {
    p5.clear();
    p5.background(255, 255, 255);
    p5.strokeWeight(1);
    fParam.w = p5.width - (margin * 2);
    fParam.h = p5.height - (margin * 2);
    fParam.s = scale;

    for (let l = 0; l < numLines; l++) {
        const lineSpacing = (p5.width - (margin * 2))/(numLines - 1);
        const x = (l * lineSpacing);

        let lastMarkedY = 0;
        let y = 0;
        let lastStep = null;
        let colorThreshold = null;
        let colorIndex = null;

        while (y < p5.height - (margin * 2)) {
            const value = f(x, y, fParam);
            // console.log('v', value)
            const nextColorIndex = Math.floor(
                p5.map(value, ...colorValueSpan, 0, pallette.length - 1, true)
            );
            if (nextColorIndex !== colorIndex && colorIndex !== null) {
                p5.stroke(...pallette[colorIndex]);
                p5.line(margin + x, margin + lastMarkedY, margin + x, margin + y);
                lastMarkedY = y;
            }
            colorIndex = nextColorIndex;
            y += step;
        }
        p5.stroke(...pallette[colorIndex]);
        p5.line(margin + x, margin + lastMarkedY, margin + x, p5.height - margin);
    }
}


export { lineDraw, lineFuncDraw }