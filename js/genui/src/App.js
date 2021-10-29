import SimplexNoise from 'simplex-noise';
import React, {useState} from 'react';
import './App.css';
import Sketch from './Sketch'

const π = Math.PI, τ = π * 2;
let seed = 666;

const canvasWidth = 768;
const canvasHeight = 432;

const inchesToPixels = inches => inches * 96
const mmToPixels = mm => mm * 3.7795
const radiansToDegrees = radians => radians * 180 / π;
const degreesToRadians = degrees => degrees * π / 180;

const Circles = () => {
  const rotations = 9
  const outwards = 50;

    return <>{[...Array(rotations).keys()].map(
    i => {
        const angle = (τ*i)/rotations;
        return <circle
            cx={outwards * Math.sin(angle) + (canvasWidth/2)}
            cy={outwards * Math.cos(angle) + (canvasHeight/2)}
            r={100}
            fill="none"
            stroke="black"
        />
      }
    )
  }</>;
}

const RectangleTwist = (props={}) => {
  const layers = 5;

  const xMargin = props.xMargin || canvasWidth / (layers * 2);
  const yMargin = props.yMargin || canvasHeight / (layers * 1.33);
  const drawWidth = props.drawWidth || canvasWidth - (2 * xMargin);
  const drawHeight = props.drawHeight || canvasHeight - (2 * yMargin);

  let angle = 0;
  let increase = τ / 222;

  let path = `M ${xMargin} ${yMargin}\n`;
  for (let layer = layers; layer >= 0; layer--) {
    for (let side = 0; side < 4; side++) {
      if (side > 1 && layer === 0) {
        continue;
      }
      const fullSideLength = (side % 2 === 0 ? drawWidth : drawHeight);
      let lineLength = fullSideLength - ((layers - layer) * ((fullSideLength / layers)));
      lineLength -= (side < 2 || (layer === layers && side === 2) ? 0 : (fullSideLength / layers) / 2);
      lineLength += side % 2 === 0 && layer < layers ? (fullSideLength / layers) / 2 : 0;
      if (layer < layers && side % 2 === 0) {
        // angle += (increase / (layers - layer + 1));
        angle += increase;
        increase += increase / 7;
      } else if (layer < layers) {
        angle -= increase / 7
      }
      const nextX = lineLength * Math.cos(angle + side * τ/4);
      const nextY = lineLength * Math.sin(angle + side * τ/4);
      path = `${path} l ${nextX} ${nextY}\n`;
    }
  }
  return <>
    <g id="rectSpiral">
      <path key="rectSpiral" d={path} fill="none" stroke="black" />
    </g>
  </>
}

const marginalized = ({
  margin: dMargin=10,
  xMargin: dxMargin,
  yMargin: dyMargin,
  topMargin: dTopMargin,
  bottomMargin: dBottomMargin,
  leftMargin: dLeftMargin,
  rightMargin: dRightMargin,
}={}) => Wrapped => props => {
  const {
    width,
    height,
    ...rest
  } = props;
  const {
    margin=dMargin,
    xMargin=dxMargin,
    yMargin=dyMargin,
    topMargin=dTopMargin,
    bottomMargin=dBottomMargin,
    leftMargin=dLeftMargin,
    rightMargin=dRightMargin,
  } = rest;
  const top = topMargin || yMargin || margin;
  const bottom = bottomMargin || yMargin || margin;
  const left = leftMargin || xMargin || margin;
  const right = rightMargin || xMargin || margin;
  const marginedWidth = width - (left + right);
  const marginedHeight = height - (top + bottom);
  return (
    <g transform={`translate(${left} ${top})`}>
      <Wrapped
        width={marginedWidth}
        height={marginedHeight}
        {...rest}
      />
    </g>
  );
}

const arrayed = ({
  rows: dRows=1,
  columns: dColumns=1,
  padding: dPadding=0,
}={}) => Wrapped => props => {
  const {
    width,
    height,
    column,
    row,
    ...rest
  } = props;
  const {
    rows=dRows,
    columns=dColumns,
    padding=dPadding,
  } = rest;
  const rowWidth = (width - (padding * (columns - 1))) / columns;
  const rowHeight = (height - (padding * (rows - 1))) / rows;

  let gArr = [];
  for (let x = 0; x < columns; x++) {
    for (let y = 0; y < rows; y++) {
      gArr = [...gArr, 
        <g
          transform={
            `translate(${
              (x * rowWidth) + (padding * x)
            } ${
              (y * rowHeight) + (padding * y)
            })`}
        >
          <Wrapped
            width={rowWidth}
            height={rowHeight}
            {...rest}
            parentColumn={column}
            parentRow={row}
            column={x}
            row={y}

          />
        </g>
      ]
    }
  }
  return gArr;
}

const IsoCube2D = 
marginalized({margin: 50, leftMargin: 150})(
arrayed({rows: 1, columns: 11})(
props => {
  const {
    width,
    height,
    column=0,
    row=0,
    parentColumn=0,
    parentRow=0,
    seed=666,
    len:explicitLen
  } = props
  const t6th = τ / 6;
  const midX = width / 2;
  const midY = height / 2
  const simp = new SimplexNoise(seed * (parentColumn + 1) / (parentRow + 2) + column * 100 + row * 100)
  const len = explicitLen || width / (2 * Math.sqrt(3));

  let path = '';
  // const skew = τ * simp.noise3D(row, column, seed);
  const skew = 0;
  for (let line = 0; line < 12; line++) {
    const cubeNoise = simp.noise2D((column + (parentColumn * π) + π) * 100, ((line + 1) * π) * ((column + 1) * π));
    const showLine = Math.abs(cubeNoise) < 0.4;

    const rot = (t6th * (line % 6)) + skew;
    
    const toX = len * Math.cos(rot);
    const toY = len * Math.sin(rot);
    if (line < 6 && showLine) {
      // spokes, starting straight up, then around clockwise
      path += `M ${midX} ${midY} l ${toX} ${toY}\n`;
    } else if (showLine) {
      // wheel, starting top right, around clockwise
      const wX = len * Math.cos(rot + (2 * t6th));
      const wY = len * Math.sin(rot + (2 * t6th));
      path += `M ${midX} ${midY} m ${toX} ${toY} l ${wX} ${wY}\n`;
    }
  }
  return <path d={path} />
}));

const GridIsoCube = 
marginalized({margin: 50})(
arrayed({rows: 4, columns: 6})(
props => {
  const {
    width,
    height,
    column=0,
    row=0,
    seed=666,
    len:explicitLen
  } = props
  const t6th = τ / 6;
  const midX = width / 2;
  const midY = height / 2
  const simp = new SimplexNoise(seed + column * 10 + row * 10)
  const len = explicitLen || width / (2 * Math.sqrt(3));

  let path = '';
  // const skew = τ * simp.noise3D(row, column, seed);
  // const skew = (τ/10) * (((row * 6) + column));
  const skew = 0;
  for (let line = 0; line < 12; line++) {
    const cubeNoise = simp.noise3D(line * ((row + 2) / (column + 2)), column * 10, row * 10);
    const showLine = Math.abs(cubeNoise) < 0.2;

    const rot = (t6th * (line % 6)) + skew;
    
    const toX = len * Math.cos(rot);
    const toY = len * Math.sin(rot);
    if (line < 6 && showLine) {
      // spokes, starting straight up, then around clockwise
      path += `M ${midX} ${midY} l ${toX} ${toY}\n`;
    } else if (showLine) {
      // wheel, starting top right, around clockwise
      const wX = len * Math.cos(rot + (2 * t6th));
      const wY = len * Math.sin(rot + (2 * t6th));
      path += `M ${midX} ${midY} m ${toX} ${toY} l ${wX} ${wY}\n`;
    }
  }
  return <path d={path} />
}));

const burnered = Wrapped => ({children, ...props}) => {
  const {width, height} = props;
  return <>
    <g id="burner">
      <circle cx={50} cy={height/2} r={7}/>
      <rect width={width} height={height} rx={15}/>
    </g>
    <Wrapped {...props}/>
  </>;
}

/**
  const segLen = 20;
  const margin = 50;
  // const rows = 6;
  // const columns = 9;
  const rows = 3;
  const columns = 11;
  const padding = 50;
  const totalWidth =
    (segLen * columns * 2 * Math.sqrt(3)) + (margin * 2);
  const totalHeight =
    (segLen * rows * 4) + (margin * 2) + (padding * rows);

  const [seed, setSeed] = useState(666);
 */
const IsoCubeBurners = arrayed({rows: 3, columns: 1, padding: 50})(burnered(IsoCube2D))

/**
  Postcard size is 6in * 4in
 */
const PostcardBack = ({width, height, padding}) => {
  const stampSize = inchesToPixels(1);
  return <>
    <g id="postcard-divider">
      <line x1={width/2} y1={padding} x2={width/2} y2={height - padding} stroke="black" />
    </g>
    <g id="stamp">
      <rect x={width - stampSize - padding} y={padding} height={stampSize} width={stampSize}/>
      <rect x={width - stampSize - padding * 2} y={padding * 2} height={stampSize} width={stampSize}/>
      <rect x={width - stampSize - padding * 3} y={padding * 3} height={stampSize} width={stampSize}/>
    </g>
  </>
}

const ParallelLineRect = ({
  width,
  height,
  lines,
  column=0,
  row=0
}) => {
  const t6th = τ / 50;
  const rotation = radiansToDegrees((column * t6th) + ((column + 2) * row * t6th));
  let path = 'M 0,0 ';
  for (let l = 0; l < lines; l++) {
    path += `v ${l % 2 === 0 ? height : -height} `;
    if (l !== lines - 1) {
      path += `h ${width / lines} `
    }
  }
  
  return <path transform={`rotate(${rotation}, ${width / 2}, ${height / 2})`} d={path}/>;
}

const ArrayedLineRects = marginalized({margin: 50})(arrayed({rows: 3, columns: 4, padding: 10})(ParallelLineRect))

function App() {
  const totalWidth = inchesToPixels(6);
  const totalHeight = inchesToPixels(4);

  const [seed, setSeed] = useState(666);

  return (
    <div className="App">
      {/* <Sketch width={canvasWidth} height={canvasHeight} name="rectangle_twist" sketch={<RectangleTwist/>}/> */}
      <Sketch 
        width={totalWidth}
        height={totalHeight}
        name="linerects"
      >
        <ArrayedLineRects
          width={totalWidth}
          height={totalHeight}
          lines={7}
        />
      </Sketch>
      <button onClick={() => setSeed(Math.random() * 6666)}>
          Rand Seed
      </button>
    </div>
  );
}

export default App;
