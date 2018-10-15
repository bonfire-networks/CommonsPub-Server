import * as React from 'react';
import ReactDOM from 'react-dom';

import registerServiceWorker from './registerServiceWorker';
import App from './containers/App/App';
import { injectGlobal } from './themes/styled';

injectGlobal`
    body, html {
        border: 0;
        margin: 0;
        padding: 0;
        width: 100%;
        height: 100%;
    }
    
    * {
      box-sizing: border-box;
    }
`;

ReactDOM.render(<App />, document.getElementById('root'));

registerServiceWorker();
