import { fromEvent, merge, EMPTY } from 'rxjs';

export const fromEvents = (dom, ...eventNames) => {
  return eventNames.reduce((prev, name) => merge(prev, fromEvent(dom, name)), EMPTY);
};

export const debounceTime = (ms, fn) => {
  let timer;
  return function() {
    clearTimeout(timer);
    let args = Array.prototype.slice.call(arguments);
    args.unshift(this);
    timer = setTimeout(fn.bind.apply(fn, args), ms);
  };
};
