import { MemoryRouter as Router, Switch, Route } from 'react-router-dom';
// import useScript from '../hooks/useScript';

import './App.global.css';

import Portal from '../containers/Portal';

// require('p5.js-svg');


export default function App() {
  // useScript('p5svg.js');
  return (
    <Router>
      <Switch>
        <Route path="/" component={Portal} />
      </Switch>
    </Router>
  );
}
