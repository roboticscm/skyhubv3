const JSONbigString = require('json-bigint-x')({ storeAsString: true });

export class SJSON {
  static stringify = (obj) => {
    return JSONbigString.stringify(obj);
  };

  static parse = (json) => {
    return JSONbigString.parse(json);
  };

  static isJson = (str) => {
    try {
      JSON.parse(str);
    } catch (e) {
      return false;
    }
    return true;
  };
}
