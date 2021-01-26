import { StringUtil } from 'src/lib/string-util';

import { SJSON } from 'src/lib/sjson';

export class SObject {
  static clone(obj) {
    return SJSON.parse(SJSON.stringify(obj));
  }

  static isEmptyField(obj) {
    if (!obj) return true;

    if (Object.keys(obj)[0]) return false;
    else return true;
  }

  static isEqual(obj1, obj2) {
    if (obj1 === null && obj2 === null) {
      return true;
    } else if ((obj1 === null && obj2 !== null) || (obj1 !== null && obj2 === null)) {
      return false;
    } else {
      return SJSON.stringify(obj1) === SJSON.stringify(obj2);
    }
  }

  static changeFieldsName(obj, fields) {
    for (let field in obj) {
      Object.defineProperty(obj, fields[field], Object.getOwnPropertyDescriptor(obj, field));
      delete obj[field];
    }
  }

  static getEqualRow(arr2, keyValues, keyFields) {
    for (let item of arr2) {
      const keyValues2 = [];
      for (let field of keyFields) {
        keyValues2.push(item[field]);
      }

      const isEqual = SObject.simpleArrayEqual(keyValues, keyValues2);
      if (isEqual) {
        return item;
      }
    }

    return null;
  }

  // two arrays are not the same length
  static getDiffRowObjectArray2(arr1, arr2, keyFields) {
    const addArray = [];
    const editFromArray = [];
    const editToArray = [];
    const removeArray = [];

    // arr1
    for (let i = 0; i < arr1.length; i++) {
      const keyValues = [];
      for (let field of keyFields) {
        keyValues.push(arr1[i][field]);
      }

      const value2 = SObject.getEqualRow(arr2, keyValues, keyFields);
      // this row only in arr1, not in arr2
      if (value2 === null) {
        removeArray.push(arr1[i]);
      } else {
        const isEqual = SObject.simpleObjEqual(arr1[i], value2);

        if (!isEqual) {
          editToArray.push(value2);
        }
      }
    }

    // arr2
    for (let i = 0; i < arr2.length; i++) {
      const keyValues = [];
      for (let field of keyFields) {
        keyValues.push(arr2[i][field]);
      }

      const value1 = SObject.getEqualRow(arr1, keyValues, keyFields);
      // this row only in arr2, not in arr1
      if (value1 === null) {
        addArray.push(arr2[i]);
      } else {
        const isEqual = SObject.simpleObjEqual(arr2[i], value1);
        if (!isEqual) {
          editFromArray.push(value1);
        }
      }
    }

    return {
      addArray,
      editFromArray,
      editToArray,
      removeArray,
    };
  }

  // two arrays are the same length
  static getDiffRowObjectArray(arr1, arr2) {
    if (!arr1) {
      return arr2;
    }

    if (!arr2) {
      return arr1;
    }

    if (arr1.length !== arr2.length) {
      return 'Two arrays are not the same length';
    }

    const result = [];
    for (let i = 0; i < arr1.length; i++) {
      let diff = getDiffFieldsObject(arr1[i], arr2[i]);
      if (!SObject.isEmptyField(diff)) {
        result.push(arr2[i]);
      }
    }

    return result;
  }

  static simpleArrayEqual(arr1, arr2) {
    if (arr1 && arr2 && arr1.length !== arr2.length) {
      return false;
    }

    for (let i = 0; i < arr1.length; i++) {
      if (arr1[i] !== arr2[i]) {
        return false;
      }
    }

    return true;
  }

  static simpleObjEqual(obj1, obj2) {
    if (obj1 && obj2 && obj1.length !== obj2.length) {
      return false;
    }

    for (let field in obj1) {
      if (obj1[field] !== obj2[field]) {
        return false;
      }
    }

    return true;
  }

  static convertFieldsToCamelCase(obj) {
    for (let field in obj) {
      if (field.includes('_')) {
        const newField = StringUtil.snakeToCamelCase(field);
        obj[newField] = obj[field];
        delete obj[field];
      }
    }

    return obj;
  }

  static convertArrayFieldsToCamelCase(array) {
    const result = [];
    for (let row of array) {
      result.push(SObject.convertFieldsToCamelCase(row));
    }

    return result;
  }

  static removeHtmlTagArrayObject(arrObj) {
    if (!arrObj) {
      return arrObj;
    }
    const copyArrObj = this.clone(arrObj);
    for (let row of copyArrObj) {
      for (let field in row) {
        if (typeof row[field] === 'string') {
          row[field] = StringUtil.removeHtmlTag(row[field]);
        }
      }
    }

    return copyArrObj;
  }

  // static itemInArray(array, item) {
  //   for (let i = 0; i < array.length; i++) {
  //     // if (SObject.simpleObjEqual(array[i], item)) {
  //     //   return true;
  //     // }
  //   }
  //
  //   return false;
  // }
  //
  // static distinctObject(arrayObj) {
  //   const distinctObj = [];
  //   if (arrayObj && arrayObj.length < 2) {
  //     return arrayObj;
  //   }
  //
  //   for (let i = 0; i < arrayObj.length; i++) {
  //     if (!SObject.itemInArray(distinctObj, arrayObj[i])) {
  //       distinctObj.push(arrayObj[i]);
  //     }
  //   }
  //
  //   return distinctObj;
  // }

  static distinctArrayObject(data) {
    return Array.from(new Set(data.map((it) => it.index))).map((index) => {
      const ret = data.find((s) => s.index === index);
      delete ret.index;
      return ret;
    });
  }
}

/*!
 * Find the differences between two objects and push to a new object
 * (c) 2019 Chris Ferdinandi & Jascha Brinkmann, MIT License, https://gomakethings.com & https://twitter.com/jaschaio
 * @param  {Object} obj1 The original object
 * @param  {Object} obj2 The object to compare against it
 * @return {Object}      An object of differences between the two
 */
export const getDiffFieldsObject = (obj1, obj2) => {
  // Make sure an object to compare is provided
  if (!obj2 || Object.prototype.toString.call(obj2) !== '[object Object]') {
    return obj1;
  }

  //
  // Variables
  //

  let diffs = {};
  let key;

  //
  // Methods
  //

  /**
   * Check if two arrays are equal
   * @param  {Array}   arr1 The first array
   * @param  {Array}   arr2 The second array
   * @return {Boolean}      If true, both arrays are equal
   */
  const arraysMatch = function(arr1, arr2) {
    // Check if the arrays are the same length
    if (arr1.length !== arr2.length) return false;

    // Check if all items exist and are in the same order
    for (let i = 0; i < arr1.length; i++) {
      if (
        (arr1[i] !== arr2[i] && ((arr1[i] !== null && arr2[i] !== '') || (arr1[i] !== '' && arr2[i] !== null))) ||
        typeof arr1[i] === 'object' ||
        typeof arr2[i] === 'object'
      ) {
        // if (typeof arr1[i] === 'object' || typeof arr2[i] === 'object') {
        const objDiff = getDiffFieldsObject(arr1[i], arr2[i]);
        if (objDiff && Object.keys(objDiff).length > 1) {
          diffs[key] = objDiff;
        }
      } else {
        if (arr1[i] != arr2[i]) return false;
      }
    }

    // Otherwise, return true
    return true;
  };

  /**
   * Compare two items and push non-matches to object
   * @param  {*}      item1 The first item
   * @param  {*}      item2 The second item
   * @param  {String} key   The key in our object
   */
  var compare = function(item1, item2, key) {
    // Get the object type
    var type1 = Object.prototype.toString.call(item1);
    var type2 = Object.prototype.toString.call(item2);

    // If type2 is undefined it has been removed
    if (type2 === '[object Undefined]') {
      diffs[key] = { oldValue: null, newValue: undefined };
      return;
    }

    // If items are different types

    // if (type1 !== type2) {
    //   console.log(type1 === '[object Null]', type2 === '[object String]');
    //   diffs[key] = [item1, item2];
    //   console.log('2', type1, type2);
    //
    //   return;
    // }

    // If an object, compare recursively
    if (type1 === '[object Object]') {
      var objDiff = getDiffFieldsObject(item1, item2);
      if (Object.keys(objDiff).length > 1) {
        diffs[key] = objDiff;
      }
      return;
    }

    // If an array, compare
    if (type1 === '[object Array]') {
      if (!arraysMatch(item1, item2)) {
        diffs[key] = { oldValue: item1, newValue: item2 };
      }
      return;
    }

    // Else if it's a function, convert to a string and compare
    // Otherwise, just compare
    if (type1 === '[object Function]') {
      if (item1.toString() != item2.toString()) {
        diffs[key] = { oldValue: item1, newValue: item2 };
      }
    } else {
      if (!((item1 == null && item2 == '') || (item1 == '' && item2 == null) || item1 == item2)) {
        diffs[key] = { oldValue: item1, newValue: item2 };
      }
    }
  };

  //
  // Compare our objects
  //

  // Loop through the first object
  for (key in obj1) {
    if (obj1.hasOwnProperty(key)) {
      compare(obj1[key], obj2[key], key);
    }
  }

  // Loop through the second object and find missing items
  for (key in obj2) {
    if (obj2.hasOwnProperty(key)) {
      if (
        !obj1[key] &&
        !((obj1[key] == null && obj2[key] == '') || (obj1[key] == '' && obj2[key] == null) || obj1[key] == obj2[key])
      ) {
        diffs[key] = { oldValue: obj1[key], newValue: obj2[key] };
      }
    }
  }

  // Return the object of differences
  return diffs;
};
