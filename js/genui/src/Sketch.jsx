import React, { useEffect, useRef } from 'react';
import './Sketch.css';

function saveSvg(svg, name) {
    if (svg === null) {
        return;
    }
    svg.setAttribute("xmlns", "http://www.w3.org/2000/svg");
    const svgData = svg.outerHTML;
    const preface = '<?xml version="1.0" standalone="no"?>\r\n';
    const svgBlob = new Blob([preface, svgData], {type:"image/svg+xml;charset=utf-8"});
    const svgUrl = URL.createObjectURL(svgBlob);
    const downloadLink = document.createElement("a");
    downloadLink.href = svgUrl;
    downloadLink.download = `${name}_${Date.now()}.svg`;
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
}

function Sketch(props) {
    const sketchRef = useRef(null);
    const {children, name, height, width} = props;

    return (<>
        <svg 
            className="Sketch"
            id="sketch"
            ref={sketchRef}
            width={width}
            height={height}
            viewBox={`0 0 ${width} ${height}`} 
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            stroke="black"
        >
            <g id="border">
                <path d={
                    'M 0 0 '
                    + `L ${width} 0 `
                    + `L ${width} ${height} `
                    + `L 0 ${height} `
                    + 'L 0 0'} />
            </g>
            <g id={name}>{children}</g>
        </svg>
        <div>
        <button onClick={() => saveSvg(sketchRef.current, name)}>
            Save SVG
        </button>
        </div>
    </>
    );
};



export default Sketch