import Canvas from "../canvas/Canvas";
import {lineFuncDraw} from "../drawlibs/1-basic"
import {getCMYK} from "../canvas/pallette";

const Sketch = () => {
    const cmyk = getCMYK();
    console.log(cmyk)
    return (
      <>
        <h1>plotbox</h1>
        <Canvas draw={lineFuncDraw({numLines: 155, pallette: cmyk})}/>
      </>
    );
  };

export default Sketch;