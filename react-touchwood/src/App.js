import './App.css';
import TouchWood from './touchwood/TouchWood';
import {IMAGE_ARRAY, QUOTE_HK_ARRAY, QUOTE_EN_ARRAY} from './constants';
import { makeServer } from './kstream/server';

// Mock an API server
if (process.env.NODE_ENV === 'development') {
  makeServer({ environment: 'development' });
} 

function App() {
  return (
    <div className="App">
      <TouchWood images={IMAGE_ARRAY} hk_quotes={QUOTE_HK_ARRAY} en_quotes={QUOTE_EN_ARRAY} />
    </div>
  );
}

export default App;
