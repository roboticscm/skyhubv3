import { Browser } from 'src/lib/browser';

export class SDate {
  static convertMillisecondToDateString(millisecond) {
    if (!millisecond) {
      return '';
    }

    const date = new Date(millisecond);
    return date.toLocaleDateString('vi-VN');
  }

  static convertMillisecondToDateTimeString(millisecond) {
    if (!millisecond) {
      return '';
    }

    const date = new Date(millisecond);
    //safari
    if (Browser.isSafari()) {
      return date.toLocaleString('vi-VN', {
        dateStyle: 'short',
      });
    }

    //other browser
    return (
      date.toLocaleString('vi-VN', {
        dateStyle: 'short',
      }) +
      ', ' +
      date.toLocaleString('vi-VN', {
        timeStyle: 'short',
      })
    );
  }

  static toDateString(date) {
    return date.toLocaleDateString('vi-VN');
  }

  static toDateTimeString(date) {
    return (
      date.toLocaleString('vi-VN', {
        dateStyle: 'short',
      }) +
      ', ' +
      date.toLocaleString('vi-VN', {
        timeStyle: 'short',
      })
    );
  }

  static newDateInMilli() {
    return new Date().valueOf();
  }
}
