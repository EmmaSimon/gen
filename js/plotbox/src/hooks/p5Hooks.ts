import {useEffect} from 'react';
import {initP5SVG} from '../main/p5svg'

export const useP5SVG = (p5:any) => {
    useEffect(() => {
        if (!p5) {
            return;
        }
        console.log('initing p5-svg', p5);
        initP5SVG(p5);
    }, [p5]);
}
