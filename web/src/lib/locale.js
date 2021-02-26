import { StringUtil } from './string-util';
import { grpcLocaleResourceClient } from './grpc';

import {
  FindLocaleResourceRequest
} from "src/pt/proto/locale_resource/locale_resource_service_pb";


let I18N = [];

const TYPE_GROUPS = [
  'IMG',
  'TABLE',
  'LINK',
  'INFO',
  'WARN',
  'REPORT',
  'ERROR',
  'LABEL',
  'TITLE',
  'BUTTON',
  'TAB',
  'MENU',
  'MSG',
  'COLOR',
];

export const IMG = {};
TYPE_GROUPS.map((item) => {
  IMG[item] = {};
});

export const EMR = {};
TYPE_GROUPS.map((item) => {
  EMR[item] = {};
});

export const INV = {};
TYPE_GROUPS.map((item) => {
  INV[item] = {};
});

export const ACC = {};
TYPE_GROUPS.map((item) => {
  ACC[item] = {};
});

export const COMMON = {};
TYPE_GROUPS.map((item) => {
  COMMON[item] = {};
});

export const SYS = {};
TYPE_GROUPS.map((item) => {
  SYS[item] = {};
});

export const QTT = {};
TYPE_GROUPS.map((item) => {
  QTT[item] = {};
});

export const TASK = {};
TYPE_GROUPS.map((item) => {
  TASK[item] = {};
});

const CATEGORIES_MAP = new Map([
  ['IMG', IMG],
  ['EMR', EMR],
  ['INV', INV],
  ['ACC', ACC],
  ['SYS', SYS],
  ['COMMON', COMMON],
  ['QTT', QTT],
  ['TASK', TASK],
]);

export const convertLocaleResource = () => {
  for (let i = 0; i < I18N.length; i++) {
    if (I18N[i].category && CATEGORIES_MAP.has(I18N[i].category)) {
      initCategoryHelper(i, CATEGORIES_MAP.get(I18N[i].category));
    }
  }
};

function initCategoryTypeGroupHelper(i, categoryTypeGroup) {
  const key = I18N[i].key;
  if (key) {
    categoryTypeGroup[key] = I18N[i].value;
  }
}

function initCategoryHelper(i, category) {
  if (I18N[i].typeGroup && TYPE_GROUPS.find((item) => item === I18N[i].typeGroup)) {
    initCategoryTypeGroupHelper(i, category[I18N[i].typeGroup]);
  }
}

export const findLanguage = (companyId, locale) => {
  return new Promise((resolve, reject) => {
    const req = new FindLocaleResourceRequest();
    req.setLocale(locale);
    req.setCompanyId(`${companyId}`);
    grpcLocaleResourceClient.findHandler(req).then(res => {
      I18N = res.toObject().dataList;
      convertLocaleResource();
      resolve(I18N);
      String.prototype.t = function () {
        var str = this.valueOf();
        return T(str);
    };
    }).catch(err => reject(err));
  });
};

const defaultValue = (key) => {
  return key
    .split('_')
    .map((word) => {
      return StringUtil.capitalize(word.toLowerCase());
    })
    .join(' ');
};

export const T = (fullKey) => {
  if (fullKey.includes('.') && !fullKey.includes(' ')) {
    const split = fullKey.split('.');
    if (split.length === 3) {
      const [cate, type, key] = split;
      return CATEGORIES_MAP.get(cate)[type][key] || (log.isDebugMode() ? fullKey : `#${defaultValue(key)}`);
    } else {
      return 'Invalid Key Format';
    }
  } else if (fullKey.includes(' ')) {
    return fullKey;
  } else {
    return COMMON.MSG[fullKey] || `#${fullKey}`;
  }
};
