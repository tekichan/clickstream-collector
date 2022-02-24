import { createServer } from 'miragejs';
import { URL_PATH } from './constants';

export function makeServer({ environment = 'development' } = {}) {
    return createServer({
        routes() {
            this.post(URL_PATH, (schema, request) => {
                return {
                    "response_code": "200"
                    , "message": "Clickstream collected."
                };
            });
        }
    });
}