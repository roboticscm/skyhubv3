import { T } from 'src/lib//locale';
import { error } from '../debug';

export class Errors {
  constructor() {
    this.errors = {};
  }

  has(field) {
    return this.errors.hasOwnProperty(field);
  }

  any() {
    return Object.keys(this.errors).length > 0;
  }

  get(field) {
    if (this.errors[field]) {
      return `${T(this.errors[field])}`;
    } else {
      return '';
    }
  }

  record(errors) {
    this.errors = errors;
    let firstError = Object.keys(this.errors)[0];
    if (firstError) {
      const el = document.getElementsByName(firstError)[0];
      if (el) {
        el && el.focus();
      } else {
        error(`Can not find element with id: ${firstError}`);
      }
    }
  }

  clear(field) {
    if (field) {
      delete this.errors[field];
      return;
    }

    this.errors = {};
  }

  clearAll() {
    this.errors = {};
  }
}
