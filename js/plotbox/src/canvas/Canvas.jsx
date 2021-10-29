import React, {useEffect, useState} from 'react'
import Sketch from 'react-p5';

import {useP5SVG} from 'hooks/p5Hooks';

const Canvas = ({draw}) => {
  const [localP5, setLocalP5] = useState(null);
  useP5SVG(localP5);
  const setup = (p5, canvasParentRef) => {
    console.log(p5, localP5, p5===localP5);
    setLocalP5(p5);
    p5.createCanvas(600, 400, 'svg').parent(canvasParentRef)  
  }
  return <Sketch setup={setup} draw={draw} />;
};

export default Canvas;