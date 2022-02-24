import { URL_PATH, CLIENT_ID, JWT_SUBJECT, NBF_SECONDS, EXP_SECONDS } from './constants';
import { KJUR } from 'jsrsasign';

// random generation of JWT Secret Key
var JWT_KEY = Math.random().toString(36).substring(2, 10) + Math.random().toString(36).substring(2, 10);
var DEVICE_TOKEN = Math.random().toString(36).substring(2, 10) + Math.random().toString(36).substring(2, 10);

const get_auth_code = () => {
    const secondsSinceEpoch = Math.round(Date.now() / 1000);
    const expSeconds = secondsSinceEpoch + EXP_SECONDS;
    const sHeader = JSON.stringify({
      "alg": "HS256"
      , "typ": "JWT"
    });
    const sPayload = JSON.stringify({
      "iss": CLIENT_ID,
      "sub": JWT_SUBJECT,
      "iat": secondsSinceEpoch,
      "nbf": secondsSinceEpoch - NBF_SECONDS,
      "exp": expSeconds
    });
  
    return KJUR.jws.JWS.sign("HS256", sHeader, sPayload, {b64u: JWT_KEY});
  }

export const submit_kstream = async (data) => {
    const dest_url = process.env.REACT_APP_SITE_DOMAIN + URL_PATH;
    const settings = {
        method: 'POST',
        headers: {
            Accept: 'application/json'
            , 'Content-Type': 'application/json'
            , 'Cache-Control': 'no-cache'
            , 'client_id': CLIENT_ID
            , 'Authorization': 'Bearer ' + get_auth_code()
        }, 
        body: JSON.stringify(data)
    };
    try {
        const fetchResponse = await fetch(dest_url, settings);
        const data = await fetchResponse.json();
        return data;
    } catch (e) {
        return e;
    }    
  }

export const submit_click = (tag_name, tag_value=null) => {
    var now_iso_datetime = (new Date()).toISOString();
    var payload = {
      "token": DEVICE_TOKEN
      , "timestamp": now_iso_datetime
      , "tag": tag_name
    };
    if (tag_value !== null) {
      payload["value"] = tag_value;
    }
    return submit_kstream(payload);
  }

export const submit_geoloc = (position) => {
    var now_iso_datetime = (new Date()).toISOString();
    return submit_kstream({
      "token": DEVICE_TOKEN
      , "timestamp": now_iso_datetime
      , "tag": "GEO_LOC"
      , "latitude": position.coords.latitude
      , "longitude": position.coords.longitude
    });
  }

export const getLocation = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(submit_geoloc);
      console.log("Geolocation is submitted.");
    } else { 
      console.log("Geolocation is not supported by this browser.");
    }
  }

