import React from 'react';
import './App.css';
import Sketch from './Sketch'

const π = Math.PI, τ = π * 2;

const canvasWidth = 768;
const canvasHeight = 432;
const getCircles = () => {
  const rotations = 9
  const outwards = 50;

    return [...Array(rotations).keys()].map(
    i => {
        const angle = (τ*i)/rotations;
        return <circle
            cx={outwards * Math.sin(angle) + (canvasWidth/2)}
            cy={outwards * Math.cos(angle) + (canvasHeight/2)}
            r={100}
            fill="none"
            stroke="black"
        />;
    }
  )
}

const getRectangleTwist = () => {
  const layers = 5;

  const xMargin = canvasWidth / (layers * 2);
  const yMargin = canvasHeight / (layers * 1.33);
  const rectWidth = canvasWidth - (2 * xMargin);
  const rectHeight = canvasHeight - (2 * yMargin);

  let angle = 0;
  let increase = τ / 222;

  let path = `M ${xMargin} ${yMargin}\n`;
  for (let layer = layers; layer >= 0; layer--) {
    for (let side = 0; side < 4; side++) {
      if (side > 1 && layer === 0) {
        continue;
      }
      const fullSideLength = (side % 2 === 0 ? rectWidth : rectHeight);
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
    <g id="outline">
      <path key="outline" d={`M 0 0 L ${canvasWidth} 0 L ${canvasWidth} ${canvasHeight} L 0 ${canvasHeight} L 0 0`} />
    </g>
    <g id="rectSpiral">
      <path key="rectSpiral" d={path} fill="none" stroke="black" />
    </g>
  </>
}

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <Sketch width={canvasWidth} height={canvasHeight} name="rectangle_twist" sketch={getRectangleTwist()}/>
      </header>
    </div>
  );
}

export default App;
