export const getGreyscalePallette = ({colors = 4,opacity = 85,buffer=50} = {}) => 
    [...Array(colors).keys()].map(
        i => [(i/colors) * (255 - buffer) + buffer, opacity]
    )

export const getRGB = ({opacity=85}={}) =>
        [[255,0,0, opacity], [0,255,0, opacity], [0,0,255,opacity]]

export const getCMYK = ({opacity=85}={}) =>
        [[0,255,255,opacity], [255,0,255,opacity], [255,255,0,opacity], [0,0,0,opacity] ]